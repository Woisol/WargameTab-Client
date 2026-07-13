import '../models/wargame_session.dart';
import 'watch_sync_models.dart';
import 'watch_sync_transport.dart';

class MockWatchSyncTransport implements WatchSyncTransport {
  MockWatchSyncTransport();

  static const _device = WatchDevice(
    deviceId: 'vela-watch-devkit',
    name: 'Wargame Tab Watch',
    rssi: -48,
    batteryPercent: 78,
  );

  bool _connected = false;
  final Set<String> _ackedSessionIds = {};

  @override
  Future<List<WatchDevice>> scan() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    return const [_device];
  }

  @override
  Future<WatchDevice> connect(String deviceId) async {
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (deviceId != _device.deviceId) {
      throw StateError('未找到指定手表');
    }

    _connected = true;
    return _device;
  }

  @override
  Future<void> disconnect() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _connected = false;
  }

  @override
  Future<WatchSyncPayload> pullSessions() async {
    if (!_connected) {
      throw StateError('手表未连接');
    }

    await Future<void>.delayed(const Duration(milliseconds: 560));
    final sessions = _mockSyncSessions
        .where((session) => !_ackedSessionIds.contains(session.sessionId))
        .toList();
    return WatchSyncPayload(
      protocolVersion: 1,
      deviceId: _device.deviceId,
      appVersion: '1.0.0',
      lastSyncAt: DateTime.now().millisecondsSinceEpoch,
      sessions: sessions,
    );
  }

  @override
  Future<void> ackSessions(List<String> sessionIds) async {
    if (!_connected) {
      throw StateError('手表未连接');
    }

    await Future<void>.delayed(const Duration(milliseconds: 180));
    _ackedSessionIds.addAll(sessionIds);
  }
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
