import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/session_repository.dart';
import '../models/wargame_session.dart';
import 'interconnect_sync_codec.dart';
import 'watch_sync_channel.dart';
import 'watch_sync_logger.dart';
import 'watch_sync_models.dart';

class WatchSyncService extends ChangeNotifier {
  WatchSyncService({
    required WatchSyncChannel channel,
    InterconnectSyncCodec codec = const InterconnectSyncCodec(),
    WatchSyncLogger? logger,
    required SessionRepository sessionRepository,
    required ValueChanged<List<WargameSession>> onSessionsChanged,
  }) : _channel = channel,
       _codec = codec,
       _logger = logger ?? WatchSyncLogger(),
       _sessionRepository = sessionRepository,
       _onSessionsChanged = onSessionsChanged;

  final WatchSyncChannel _channel;
  final InterconnectSyncCodec _codec;
  final WatchSyncLogger _logger;
  final SessionRepository _sessionRepository;
  final ValueChanged<List<WargameSession>> _onSessionsChanged;

  WatchSyncState _state = const WatchSyncState();
  StreamSubscription<String>? _messageSubscription;
  Future<void>? _startFuture;
  Future<void> _messageQueue = Future<void>.value();
  int _lifecycleToken = 0;
  bool _disposed = false;

  WatchSyncState get state => _state;

  Future<void> start() async {
    if (_disposed || _state.channelReady) {
      _logger.log('start skipped: disposed or already ready');
      return;
    }
    final currentStart = _startFuture;
    if (currentStart != null) {
      return currentStart;
    }

    final token = ++_lifecycleToken;
    _logger.log('start requested', toast: true);
    final startFuture = _start(token);
    _startFuture = startFuture;
    try {
      await startFuture;
    } finally {
      if (identical(_startFuture, startFuture)) {
        _startFuture = null;
      }
    }
  }

  Future<void> disconnect() async {
    final token = ++_lifecycleToken;
    _startFuture = null;
    _messageQueue = Future<void>.value();
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await _channel.stop();
    if (!_isCurrentToken(token)) {
      return;
    }

    _setState(
      WatchSyncState(
        channelReady: false,
        syncing: false,
        lastSyncAt: _state.lastSyncAt,
        lastImportedCount: _state.lastImportedCount,
        diagnosticMessage: _channel.state.diagnosticMessage,
      ),
    );
  }

  Future<void> _start(int token) async {
    StreamSubscription<String>? subscription;
    try {
      subscription = _channel.messages.listen(
        (raw) {
          _logger.log('message received', toast: true);
          _enqueueRawMessage(raw, token);
        },
        onError: (Object error) {
          if (!_isCurrentToken(token)) {
            return;
          }

          _setState(
            WatchSyncState(
              channelReady: _channel.state.available,
              syncing: false,
              lastSyncAt: _state.lastSyncAt,
              lastImportedCount: _state.lastImportedCount,
              errorMessage: error.toString(),
              diagnosticMessage: _channel.state.diagnosticMessage,
            ),
          );
          _logger.log('channel error: $error', toast: true);
        },
      );
      _messageSubscription = subscription;
      await _channel.start();
      _logger.log(
        'channel started: available=${_channel.state.available}',
        toast: true,
      );
      if (_channel.state.lastError != null) {
        _logger.log(
          'channel reported error: ${_channel.state.lastError}',
          toast: true,
        );
      }
      if (!_isCurrentToken(token)) {
        if (_startFuture == null && !_state.channelReady) {
          await _channel.stop();
        }
        return;
      }

      _setState(
        WatchSyncState(
          channelReady: _channel.state.available,
          syncing: false,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: _channel.state.lastError,
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
    } catch (error) {
      _logger.log('channel start failed: $error', toast: true);
      if (!_isCurrentToken(token)) {
        return;
      }

      await subscription?.cancel();
      if (!_isCurrentToken(token)) {
        return;
      }
      if (identical(_messageSubscription, subscription)) {
        _messageSubscription = null;
      }
      _setState(
        WatchSyncState(
          channelReady: false,
          syncing: false,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: error.toString(),
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
    }
  }

  void _enqueueRawMessage(String raw, int token) {
    _logger.log('queue message bytes=${raw.length}');
    final next = _messageQueue.then((_) async {
      if (!_isCurrentToken(token)) {
        return;
      }

      await _handleRawMessage(raw, token);
    });
    _messageQueue = next.catchError((Object error) {
      if (!_isCurrentToken(token)) {
        return;
      }

      _setState(
        WatchSyncState(
          channelReady: _channel.state.available,
          syncing: false,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: error.toString(),
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
      _logger.log('message queue failed: $error', toast: true);
    });
  }

  Future<void> _handleRawMessage(String raw, int token) async {
    _logger.log('decode push bytes=${raw.length}');
    final payload = _codec.decodePush(raw);
    if (payload == null) {
      if (!_isCurrentToken(token)) {
        return;
      }

      _setState(
        WatchSyncState(
          channelReady: _channel.state.available,
          syncing: false,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: '无法解析手表同步消息',
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
      _logger.log('push rejected by protocol codec', toast: true);
      return;
    }

    if (!_isCurrentToken(token)) {
      return;
    }

    _setState(
      WatchSyncState(
        channelReady: _channel.state.available,
        syncing: true,
        lastSyncAt: _state.lastSyncAt,
        lastImportedCount: _state.lastImportedCount,
        diagnosticMessage: _channel.state.diagnosticMessage,
      ),
    );

    try {
      _logger.log(
        'push accepted id=${payload.messageId} sessions=${payload.sessions.length}',
        toast: true,
      );
      final existingIds = {
        for (final session in await _sessionRepository.loadSessions())
          if (session.sessionId.isNotEmpty) session.sessionId,
      };
      if (!_isCurrentToken(token)) {
        return;
      }

      final importedIds = {
        for (final session in payload.sessions)
          if (session.sessionId.isNotEmpty &&
              !existingIds.contains(session.sessionId))
            session.sessionId,
      };
      final sessions = await _sessionRepository.upsertSyncedSessions(
        payload.sessions,
      );
      if (!_isCurrentToken(token)) {
        return;
      }

      _onSessionsChanged(sessions);
      _logger.log('sessions persisted new=${importedIds.length}');
      await _channel.send(
        _codec.encodeAck(
          ackMessageId: payload.messageId,
          sessionIds: payload.sessions
              .map((session) => session.sessionId)
              .toList(),
        ),
      );
      _logger.log('ack sent id=${payload.messageId}', toast: true);
      if (!_isCurrentToken(token)) {
        return;
      }

      _setState(
        WatchSyncState(
          channelReady: _channel.state.available,
          syncing: false,
          lastSyncAt: DateTime.fromMillisecondsSinceEpoch(payload.lastSyncAt),
          lastImportedCount: importedIds.length,
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
    } catch (error) {
      _logger.log('push handling failed: $error', toast: true);
      if (!_isCurrentToken(token)) {
        return;
      }

      _setState(
        WatchSyncState(
          channelReady: _channel.state.available,
          syncing: false,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: error.toString(),
          diagnosticMessage: _channel.state.diagnosticMessage,
        ),
      );
    }
  }

  bool _isCurrentToken(int token) {
    return !_disposed && _lifecycleToken == token;
  }

  void _setState(WatchSyncState value) {
    if (_disposed) {
      return;
    }

    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _lifecycleToken += 1;
    _disposed = true;
    _startFuture = null;
    _messageQueue = Future<void>.value();
    unawaited(_messageSubscription?.cancel());
    unawaited(_channel.stop());
    super.dispose();
  }
}
