import '../models/wargame_session.dart';

class WatchDevice {
  const WatchDevice({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.batteryPercent,
  });

  final String deviceId;
  final String name;
  final int rssi;
  final int batteryPercent;
}

class WatchSyncPayload {
  const WatchSyncPayload({
    required this.protocolVersion,
    required this.deviceId,
    required this.appVersion,
    required this.lastSyncAt,
    required this.sessions,
  });

  final int protocolVersion;
  final String deviceId;
  final String appVersion;
  final int lastSyncAt;
  final List<WargameSession> sessions;
}

class WatchSyncState {
  const WatchSyncState({
    this.scanning = false,
    this.connected = false,
    this.syncing = false,
    this.device,
    this.lastSyncAt,
    this.lastImportedCount = 0,
    this.errorMessage,
  });

  final bool scanning;
  final bool connected;
  final bool syncing;
  final WatchDevice? device;
  final DateTime? lastSyncAt;
  final int lastImportedCount;
  final String? errorMessage;
}
