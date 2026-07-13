import 'dart:async';

abstract class WatchSyncChannel {
  Stream<String> get messages;

  WatchSyncChannelState get state;

  Future<void> start();

  Future<void> stop();

  Future<void> send(String raw);
}

class WatchSyncChannelState {
  const WatchSyncChannelState({
    this.available = false,
    this.diagnosing = false,
    this.diagnosticMessage,
    this.lastError,
  });

  final bool available;
  final bool diagnosing;
  final String? diagnosticMessage;
  final String? lastError;
}
