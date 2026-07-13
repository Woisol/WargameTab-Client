import '../models/wargame_session.dart';

class WatchSyncPayload {
  const WatchSyncPayload({
    this.messageId = '',
    required this.protocolVersion,
    required this.deviceId,
    required this.appVersion,
    required this.lastSyncAt,
    required this.sessions,
  });

  final String messageId;
  final int protocolVersion;
  final String deviceId;
  final String appVersion;
  final int lastSyncAt;
  final List<WargameSession> sessions;
}

class WatchSyncState {
  const WatchSyncState({
    this.channelReady = false,
    this.syncing = false,
    this.lastSyncAt,
    this.lastImportedCount = 0,
    this.errorMessage,
    this.diagnosticMessage,
  });

  final bool channelReady;
  final bool syncing;
  final DateTime? lastSyncAt;
  final int lastImportedCount;
  final String? errorMessage;
  final String? diagnosticMessage;
}
