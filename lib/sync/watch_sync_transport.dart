import 'watch_sync_models.dart';

abstract class WatchSyncTransport {
  Future<List<WatchDevice>> scan();

  Future<WatchDevice> connect(String deviceId);

  Future<void> disconnect();

  Future<WatchSyncPayload> pullSessions();

  Future<void> ackSessions(List<String> sessionIds);
}
