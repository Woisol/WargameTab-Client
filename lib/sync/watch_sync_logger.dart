import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

typedef WatchSyncLogCallback = void Function(String message);

class WatchSyncLogger {
  WatchSyncLogger({
    bool debug = false,
    this.onLog,
    this.onToast,
  }) : _debug = debug;

  final WatchSyncLogCallback? onLog;
  final WatchSyncLogCallback? onToast;
  bool _debug;

  bool get debug => _debug;

  void setDebug(bool value) {
    _debug = value;
  }

  void log(String message, {bool toast = false}) {
    final formatted = '[WargameSync] $message';
    developer.log(formatted, name: 'WargameSync');
    debugPrint(formatted);
    onLog?.call(message);

    if (_debug && toast) {
      onToast?.call(message);
    }
  }
}
