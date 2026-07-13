import 'package:flutter/foundation.dart';

import '../data/session_repository.dart';
import '../models/wargame_session.dart';
import 'watch_sync_models.dart';
import 'watch_sync_transport.dart';

class WatchSyncService extends ChangeNotifier {
  WatchSyncService({
    required WatchSyncTransport transport,
    required SessionRepository sessionRepository,
    required ValueChanged<List<WargameSession>> onSessionsChanged,
  })  : _transport = transport,
        _sessionRepository = sessionRepository,
        _onSessionsChanged = onSessionsChanged;

  final WatchSyncTransport _transport;
  final SessionRepository _sessionRepository;
  final ValueChanged<List<WargameSession>> _onSessionsChanged;

  WatchSyncState _state = const WatchSyncState();
  bool _disposed = false;

  WatchSyncState get state => _state;

  Future<void> scanAndConnect() async {
    if (_state.scanning || _state.connected) {
      return;
    }

    _setState(
      WatchSyncState(
        scanning: true,
        device: _state.device,
        lastSyncAt: _state.lastSyncAt,
        lastImportedCount: _state.lastImportedCount,
      ),
    );

    try {
      final devices = await _transport.scan();
      if (devices.isEmpty) {
        _setState(
          WatchSyncState(
            device: _state.device,
            lastSyncAt: _state.lastSyncAt,
            lastImportedCount: _state.lastImportedCount,
            errorMessage: '未发现手表应用',
          ),
        );
        return;
      }

      final device = await _transport.connect(devices.first.deviceId);
      _setState(
        WatchSyncState(
          connected: true,
          device: device,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
        ),
      );
    } catch (error) {
      _setState(
        WatchSyncState(
          device: _state.device,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> disconnect() async {
    if (!_state.connected) {
      return;
    }

    await _transport.disconnect();
    _setState(
      WatchSyncState(
        device: _state.device,
        lastSyncAt: _state.lastSyncAt,
        lastImportedCount: _state.lastImportedCount,
      ),
    );
  }

  Future<void> syncNow() async {
    if (!_state.connected || _state.syncing) {
      return;
    }

    _setState(
      WatchSyncState(
        connected: true,
        syncing: true,
        device: _state.device,
        lastSyncAt: _state.lastSyncAt,
        lastImportedCount: _state.lastImportedCount,
      ),
    );

    try {
      final payload = await _transport.pullSessions();
      final sessions = await _sessionRepository.upsertSyncedSessions(
        payload.sessions,
      );
      await _transport.ackSessions(
        payload.sessions.map((session) => session.sessionId).toList(),
      );
      if (_disposed) {
        return;
      }

      _onSessionsChanged(sessions);
      _setState(
        WatchSyncState(
          connected: true,
          device: _state.device,
          lastSyncAt: DateTime.fromMillisecondsSinceEpoch(payload.lastSyncAt),
          lastImportedCount: payload.sessions.length,
        ),
      );
    } catch (error) {
      _setState(
        WatchSyncState(
          connected: true,
          device: _state.device,
          lastSyncAt: _state.lastSyncAt,
          lastImportedCount: _state.lastImportedCount,
          errorMessage: error.toString(),
        ),
      );
    }
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
    _disposed = true;
    super.dispose();
  }
}
