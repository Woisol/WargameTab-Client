import 'dart:async';
import 'dart:convert';

import 'package:client/data/key_value_store.dart';
import 'package:client/data/session_repository.dart';
import 'package:client/models/wargame_session.dart';
import 'package:client/sync/mock_watch_sync_channel.dart';
import 'package:client/sync/watch_sync_channel.dart';
import 'package:client/sync/watch_sync_models.dart';
import 'package:client/sync/watch_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imports valid push, notifies sessions changed, and sends ACK', () async {
    final channel = FakeWatchSyncChannel();
    final repository = SessionRepository(store: MemoryKeyValueStore());
    final changed = <List<WargameSession>>[];
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: changed.add,
    );

    await service.start();
    channel.receive(
      _pushRaw(messageId: 'sync_valid', sessions: [_session('s1')]),
    );
    await _waitForState(service, (state) => state.lastImportedCount == 1);

    final sessions = await repository.loadSessions();
    final ack = jsonDecode(channel.sent.single) as Map<String, dynamic>;

    expect(sessions, hasLength(1));
    expect(sessions.single.sessionId, 's1');
    expect(sessions.single.status, 'synced');
    expect(changed, hasLength(1));
    expect(changed.single.single.sessionId, 's1');
    expect(ack['type'], 'wargame.sessions.ack');
    expect(ack['ackMessageId'], 'sync_valid');
    expect(ack['sessionIds'], ['s1']);
    expect(service.state.lastImportedCount, 1);
    expect(service.state.lastSyncAt, DateTime.fromMillisecondsSinceEpoch(1234));
    expect(service.state.errorMessage, isNull);
  });

  test('ACKs duplicate push while repository keeps one session per id', () async {
    final channel = FakeWatchSyncChannel();
    final repository = SessionRepository(store: MemoryKeyValueStore());
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: (_) {},
    );
    final raw = _pushRaw(
      messageId: 'sync_duplicate',
      sessions: [_session('s1')],
    );

    await service.start();
    channel.receive(raw);
    await _waitForSends(channel, 1);
    channel.receive(raw);
    await _waitForSends(channel, 2);

    final sessions = await repository.loadSessions();
    final firstAck = jsonDecode(channel.sent.first) as Map<String, dynamic>;
    final secondAck = jsonDecode(channel.sent.last) as Map<String, dynamic>;

    expect(sessions, hasLength(1));
    expect(sessions.single.sessionId, 's1');
    expect(channel.sent, hasLength(2));
    expect(firstAck['ackMessageId'], 'sync_duplicate');
    expect(secondAck['ackMessageId'], 'sync_duplicate');
    expect(secondAck['sessionIds'], ['s1']);
    expect(service.state.lastImportedCount, 0);
  });

  test('serializes fast pushes so repository keeps all sessions', () async {
    final channel = FakeWatchSyncChannel();
    final repository = SessionRepository(store: MemoryKeyValueStore());
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: (_) {},
    );

    await service.start();
    channel
      ..receive(
        _pushRaw(messageId: 'sync_fast_1', sessions: [_session('s1')]),
      )
      ..receive(
        _pushRaw(
          messageId: 'sync_fast_2',
          sessions: [_session('s2', startTime: 3000)],
        ),
      );
    await _waitForSends(channel, 2);

    final sessions = await repository.loadSessions();
    final firstAck = jsonDecode(channel.sent.first) as Map<String, dynamic>;
    final secondAck = jsonDecode(channel.sent.last) as Map<String, dynamic>;

    expect(sessions.map((session) => session.sessionId), ['s2', 's1']);
    expect(firstAck['ackMessageId'], 'sync_fast_1');
    expect(secondAck['ackMessageId'], 'sync_fast_2');
  });

  test('invalid message updates error state and does not send ACK', () async {
    final channel = FakeWatchSyncChannel();
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: SessionRepository(store: MemoryKeyValueStore()),
      onSessionsChanged: (_) {},
    );

    await service.start();
    channel.receive('{invalid');
    await _pumpEventQueue();

    expect(service.state.errorMessage, isNotNull);
    expect(channel.sent, isEmpty);
  });

  test('disconnect stops channel and cancels message subscription', () async {
    final channel = FakeWatchSyncChannel();
    final repository = SessionRepository(store: MemoryKeyValueStore());
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: (_) {},
    );

    await service.start();
    await service.disconnect();
    channel.receive(
      _pushRaw(messageId: 'sync_after_stop', sessions: [_session('s1')]),
    );
    await _pumpEventQueue();

    expect(channel.stopCount, 1);
    expect(channel.sent, isEmpty);
    expect(await repository.loadSessions(), isEmpty);
  });

  test('start reuses an in-flight channel start', () async {
    final channel = FakeWatchSyncChannel();
    channel.holdStart = true;
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: SessionRepository(store: MemoryKeyValueStore()),
      onSessionsChanged: (_) {},
    );

    final firstStart = service.start();
    final secondStart = service.start();
    await _pumpEventQueue();

    expect(channel.startCount, 1);

    channel.releaseStart();
    await Future.wait([firstStart, secondStart]);

    expect(channel.startCount, 1);
    expect(service.state.channelReady, isTrue);
  });

  test('disconnect during in-flight start does not mark channel ready', () async {
    final channel = FakeWatchSyncChannel();
    channel.holdStart = true;
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: SessionRepository(store: MemoryKeyValueStore()),
      onSessionsChanged: (_) {},
    );

    final starting = service.start();
    await _pumpEventQueue();
    final stopping = service.disconnect();
    await _pumpEventQueue();

    channel.releaseStart();
    await Future.wait([starting, stopping]);
    await _pumpEventQueue();

    expect(channel.startCount, 1);
    expect(channel.stopCount, 2);
    expect(service.state.channelReady, isFalse);
  });

  test('disconnect before repository write prevents import and ACK', () async {
    final channel = FakeWatchSyncChannel();
    final repository = BlockingLoadSessionRepository(
      store: MemoryKeyValueStore(),
    );
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: (_) {},
    );

    await service.start();
    channel.receive(
      _pushRaw(messageId: 'sync_blocked', sessions: [_session('s1')]),
    );
    await _waitForState(service, (state) => state.syncing);
    await service.disconnect();

    repository.releaseLoad();
    await _pumpEventQueue();

    expect(channel.sent, isEmpty);
    expect(await repository.loadSessions(), isEmpty);
    expect(service.state.channelReady, isFalse);
    expect(service.state.lastImportedCount, 0);
  });

  test('reconnect processing is not blocked by a stale message queue', () async {
    final channel = FakeWatchSyncChannel();
    final repository = BlockingLoadSessionRepository(
      store: MemoryKeyValueStore(),
    );
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: repository,
      onSessionsChanged: (_) {},
    );

    await service.start();
    channel.receive(
      _pushRaw(messageId: 'sync_stale', sessions: [_session('s1')]),
    );
    await _waitForState(service, (state) => state.syncing);
    await service.disconnect();
    await service.start();
    channel.receive(
      _pushRaw(
        messageId: 'sync_after_reconnect',
        sessions: [_session('s2')],
      ),
    );
    await _waitForSends(channel, 1);

    final ack = jsonDecode(channel.sent.single) as Map<String, dynamic>;
    final sessions = await repository.loadSessions();

    expect(ack['ackMessageId'], 'sync_after_reconnect');
    expect(sessions.map((session) => session.sessionId), ['s2']);

    repository.releaseLoad();
  });

  test('stale start error after reconnect does not cancel new subscription', () async {
    final channel = FakeWatchSyncChannel();
    channel
      ..holdStart = true
      ..throwHeldStart = true;
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: SessionRepository(store: MemoryKeyValueStore()),
      onSessionsChanged: (_) {},
    );

    final staleStart = service.start();
    await _pumpEventQueue();
    await service.disconnect();

    channel.holdStart = false;
    channel.throwHeldStart = false;
    await service.start();
    channel.releaseStart();
    await staleStart;
    channel.receive(
      _pushRaw(messageId: 'sync_after_stale_error', sessions: [_session('s1')]),
    );
    await _waitForSends(channel, 1);

    final ack = jsonDecode(channel.sent.single) as Map<String, dynamic>;

    expect(ack['ackMessageId'], 'sync_after_stale_error');
    expect(service.state.channelReady, isTrue);
  });

  test('dispose stops channel and cancels message subscription', () async {
    final channel = FakeWatchSyncChannel();
    final service = WatchSyncService(
      channel: channel,
      sessionRepository: SessionRepository(store: MemoryKeyValueStore()),
      onSessionsChanged: (_) {},
    );

    await service.start();
    service.dispose();
    channel.receive(
      _pushRaw(messageId: 'sync_after_dispose', sessions: [_session('s1')]),
    );
    await _pumpEventQueue();

    expect(channel.stopCount, 1);
    expect(channel.sent, isEmpty);
  });

  test('mock channel throws when ACK payload is protocol-invalid', () async {
    final channel = MockWatchSyncChannel();

    expect(channel.send('{invalid'), throwsFormatException);
    expect(
      channel.send(
        jsonEncode({
          'type': 'unknown',
          'protocolVersion': 1,
          'ackMessageId': 'sync_a',
          'sessionIds': ['s1'],
        }),
      ),
      throwsFormatException,
    );
    expect(
      channel.send(
        jsonEncode({
          'type': 'wargame.sessions.ack',
          'protocolVersion': 2,
          'ackMessageId': 'sync_a',
          'sessionIds': ['s1'],
        }),
      ),
      throwsFormatException,
    );
    expect(
      channel.send(
        jsonEncode({
          'type': 'wargame.sessions.ack',
          'protocolVersion': 1,
          'ackMessageId': '',
          'sessionIds': ['s1'],
        }),
      ),
      throwsFormatException,
    );
  });

  test('mock channel stop cancels pending start and scheduled push', () async {
    final channel = MockWatchSyncChannel();
    final received = <String>[];
    final subscription = channel.messages.listen(received.add);

    final starting = channel.start();
    await channel.stop();
    await starting;
    await _pumpEventQueue();

    expect(channel.state.available, isFalse);
    expect(received, isEmpty);

    await subscription.cancel();
  });
}

class BlockingLoadSessionRepository extends SessionRepository {
  BlockingLoadSessionRepository({required KeyValueStore store})
    : super(store: store);

  final Completer<void> _loadGate = Completer<void>();
  bool _blockedFirstLoad = false;

  @override
  Future<List<WargameSession>> loadSessions() async {
    if (!_blockedFirstLoad) {
      _blockedFirstLoad = true;
      await _loadGate.future;
    }
    return super.loadSessions();
  }

  void releaseLoad() {
    if (!_loadGate.isCompleted) {
      _loadGate.complete();
    }
  }
}

class FakeWatchSyncChannel implements WatchSyncChannel {
  final StreamController<String> _messages =
      StreamController<String>.broadcast();
  final List<String> sent = [];
  final List<Completer<void>> _sendWaiters = [];
  WatchSyncChannelState _state = const WatchSyncChannelState();
  bool holdStart = false;
  bool throwHeldStart = false;
  Completer<void>? _startGate;
  int startCount = 0;
  int stopCount = 0;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  WatchSyncChannelState get state => _state;

  @override
  Future<void> start() async {
    startCount += 1;
    if (holdStart) {
      final shouldThrow = throwHeldStart;
      _startGate = Completer<void>();
      await _startGate!.future;
      if (shouldThrow) {
        throw StateError('stale start failed');
      }
    }
    _state = const WatchSyncChannelState(available: true);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    _state = const WatchSyncChannelState();
  }

  @override
  Future<void> send(String raw) async {
    sent.add(raw);
    for (final waiter in _sendWaiters.where((item) => !item.isCompleted)) {
      waiter.complete();
    }
    _sendWaiters.clear();
  }

  Future<void> waitForSends(int count) {
    if (sent.length >= count) {
      return Future<void>.value();
    }

    final waiter = Completer<void>();
    _sendWaiters.add(waiter);
    return waiter.future;
  }

  void releaseStart() {
    _startGate?.complete();
    holdStart = false;
  }

  void receive(String raw) {
    _messages.add(raw);
  }
}

String _pushRaw({
  required String messageId,
  required List<WargameSession> sessions,
}) {
  return jsonEncode({
    'type': 'wargame.sessions.push',
    'protocolVersion': 1,
    'messageId': messageId,
    'deviceId': 'watch_a',
    'createdAt': 1234,
    'sessions': sessions.map((session) => session.toJson()).toList(),
  });
}

WargameSession _session(String id, {int startTime = 1000}) {
  return WargameSession(
    sessionId: id,
    startTime: startTime,
    endTime: startTime + 1000,
    status: 'finished',
    summary: const WargameSummary(kills: 1, deaths: 0),
    events: const [],
  );
}

Future<void> _pumpEventQueue() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Future<void> _waitForSends(FakeWatchSyncChannel channel, int count) async {
  while (channel.sent.length < count) {
    await channel.waitForSends(count).timeout(_testTimeout);
    await _pumpEventQueue();
  }
}

Future<void> _waitForState(
  WatchSyncService service,
  bool Function(WatchSyncState state) matches,
) async {
  if (matches(service.state)) {
    return;
  }

  final completer = Completer<void>();
  void listener() {
    if (matches(service.state) && !completer.isCompleted) {
      completer.complete();
    }
  }

  service.addListener(listener);
  try {
    if (matches(service.state)) {
      return;
    }
    await completer.future.timeout(_testTimeout);
    await _pumpEventQueue();
  } finally {
    service.removeListener(listener);
  }
}

const _testTimeout = Duration(seconds: 1);
