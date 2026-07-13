import 'dart:async';

import 'package:flutter/services.dart';

import 'watch_sync_channel.dart';

class AndroidInterconnectChannel implements WatchSyncChannel {
  AndroidInterconnectChannel({MethodChannel? methodChannel})
    : _methodChannel =
          methodChannel ??
          const MethodChannel(AndroidInterconnectChannel.channelName) {
    _methodChannel.setMethodCallHandler(_handleNativeCall);
  }

  static const channelName = 'com.woisol.wargametab/interconnect';

  final MethodChannel _methodChannel;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();
  WatchSyncChannelState _state = const WatchSyncChannelState(
    diagnosticMessage: '等待启用 Android 互联通道',
  );

  @override
  Stream<String> get messages => _messages.stream;

  @override
  WatchSyncChannelState get state => _state;

  @override
  Future<void> start() async {
    try {
      final result = await _methodChannel.invokeMethod<Object?>('start');
      _state = _stateFromNativeResult(
        result,
        fallbackDiagnostic: 'Android 互联通道已请求启用',
      );
    } on PlatformException catch (error) {
      _state = WatchSyncChannelState(
        available: false,
        lastError: error.message ?? error.code,
        diagnosticMessage: error.details?.toString() ?? error.code,
      );
    } on MissingPluginException catch (error) {
      _state = WatchSyncChannelState(
        available: false,
        lastError: error.message,
        diagnosticMessage: 'Android 互联通道未注册',
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      final result = await _methodChannel.invokeMethod<Object?>('stop');
      _state = _stateFromNativeResult(
        result,
        fallbackDiagnostic: 'Android 互联通道已停用',
      );
    } on PlatformException catch (error) {
      _state = WatchSyncChannelState(
        available: false,
        lastError: error.message ?? error.code,
        diagnosticMessage: error.details?.toString() ?? error.code,
      );
    } on MissingPluginException catch (error) {
      _state = WatchSyncChannelState(
        available: false,
        lastError: error.message,
        diagnosticMessage: 'Android 互联通道未注册',
      );
    }
  }

  @override
  Future<void> send(String raw) async {
    try {
      await _methodChannel.invokeMethod<void>('send', raw);
    } on PlatformException catch (error) {
      _state = WatchSyncChannelState(
        available: _state.available,
        lastError: error.message ?? error.code,
        diagnosticMessage:
            error.details?.toString() ?? _state.diagnosticMessage,
      );
      rethrow;
    } on MissingPluginException catch (error) {
      _state = WatchSyncChannelState(
        available: false,
        lastError: error.message,
        diagnosticMessage: 'Android 互联通道未注册',
      );
      rethrow;
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onMessage':
        final raw = call.arguments;
        if (raw is String && raw.isNotEmpty && !_messages.isClosed) {
          _messages.add(raw);
        }
        return null;
      default:
        throw MissingPluginException(
          'Unknown native interconnect callback: ${call.method}',
        );
    }
  }

  WatchSyncChannelState _stateFromNativeResult(
    Object? value, {
    required String? fallbackDiagnostic,
  }) {
    if (value is! Map) {
      return WatchSyncChannelState(diagnosticMessage: fallbackDiagnostic);
    }

    final payload = Map<Object?, Object?>.from(value);
    final available = payload['available'];
    final diagnosing = payload['diagnosing'];
    final diagnosticMessage = payload['diagnosticMessage'];
    final lastError = payload['lastError'];

    return WatchSyncChannelState(
      available: available is bool && available,
      diagnosing: diagnosing is bool && diagnosing,
      diagnosticMessage: diagnosticMessage is String
          ? diagnosticMessage
          : fallbackDiagnostic,
      lastError: lastError is String ? lastError : null,
    );
  }
}
