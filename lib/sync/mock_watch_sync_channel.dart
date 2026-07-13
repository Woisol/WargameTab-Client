import 'dart:async';
import 'dart:convert';

import '../models/wargame_session.dart';
import 'watch_sync_channel.dart';

class MockWatchSyncChannel implements WatchSyncChannel {
  MockWatchSyncChannel();

  final StreamController<String> _messages =
      StreamController<String>.broadcast();
  final Set<String> _ackedSessionIds = {};
  WatchSyncChannelState _state = const WatchSyncChannelState();
  int _lifecycleToken = 0;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  WatchSyncChannelState get state => _state;

  @override
  Future<void> start() async {
    final token = ++_lifecycleToken;
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (token != _lifecycleToken) {
      return;
    }

    _state = const WatchSyncChannelState(
      available: true,
      diagnosticMessage: '已启用本地模拟配对通道',
    );
    scheduleMicrotask(() {
      if (token != _lifecycleToken) {
        return;
      }

      final sessions = _mockSyncSessions
          .where((session) => !_ackedSessionIds.contains(session.sessionId))
          .toList();
      if (sessions.isNotEmpty && !_messages.isClosed) {
        _messages.add(_pushRaw(sessions));
      }
    });
  }

  @override
  Future<void> stop() async {
    _lifecycleToken += 1;
    _state = const WatchSyncChannelState();
  }

  @override
  Future<void> send(String raw) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('模拟通道无法解析 ACK');
    }

    final payload = Map<String, dynamic>.from(decoded);
    final ackMessageId = payload['ackMessageId'];
    final sessionIds = payload['sessionIds'];
    if (payload['type'] != 'wargame.sessions.ack' ||
        payload['protocolVersion'] != 1 ||
        ackMessageId is! String ||
        ackMessageId.isEmpty ||
        sessionIds is! List) {
      throw const FormatException('模拟通道无法解析 ACK');
    }

    _ackedSessionIds.addAll(sessionIds.whereType<String>());
  }
}

String _pushRaw(List<WargameSession> sessions) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return jsonEncode({
    'type': 'wargame.sessions.push',
    'protocolVersion': 1,
    'messageId': 'mock_sync_$now',
    'deviceId': 'mock_paired_watch',
    'appVersion': '1.0.0',
    'createdAt': now,
    'sessions': sessions.map((session) => session.toJson()).toList(),
  });
}

final _mockSyncSessions = <WargameSession>[
  _session(
    id: 'session_20260712_sync_alpha',
    start: DateTime(2026, 7, 12, 18, 22),
    minutes: 41,
    kills: 16,
    deaths: 6,
  ),
  _session(
    id: 'session_20260711_sync_bridge',
    start: DateTime(2026, 7, 11, 9, 36),
    minutes: 57,
    kills: 19,
    deaths: 8,
  ),
];

WargameSession _session({
  required String id,
  required DateTime start,
  required int minutes,
  required int kills,
  required int deaths,
}) {
  return WargameSession(
    sessionId: id,
    startTime: start.millisecondsSinceEpoch,
    endTime: start.add(Duration(minutes: minutes)).millisecondsSinceEpoch,
    status: 'finished',
    summary: WargameSummary(kills: kills, deaths: deaths),
    events: [
      for (var index = 0; index < kills; index += 1)
        WargameEvent(
          eventId: '${id}_kill_$index',
          type: 'kill',
          time: 60 + index * 117,
        ),
      for (var index = 0; index < deaths; index += 1)
        WargameEvent(
          eventId: '${id}_death_$index',
          type: 'death',
          time: 150 + index * 241,
        ),
    ],
  );
}
