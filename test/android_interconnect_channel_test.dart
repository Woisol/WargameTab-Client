import 'package:client/sync/android_interconnect_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(AndroidInterconnectChannel.channelName);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  test('start reads native diagnosis state', () async {
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      expect(call.method, 'start');
      return {
        'available': false,
        'diagnosing': false,
        'diagnosticMessage': '小米互联 SDK 未接入',
        'lastError': 'interconnect_sdk_missing',
      };
    });
    final channel = AndroidInterconnectChannel(methodChannel: methodChannel);

    await channel.start();

    expect(channel.state.available, isFalse);
    expect(channel.state.diagnosticMessage, '小米互联 SDK 未接入');
    expect(channel.state.lastError, 'interconnect_sdk_missing');
  });

  test('send forwards ACK payload to native channel', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call);
      return null;
    });
    final channel = AndroidInterconnectChannel(methodChannel: methodChannel);

    await channel.send('{"type":"wargame.sessions.ack"}');

    expect(calls, hasLength(1));
    expect(calls.single.method, 'send');
    expect(calls.single.arguments, '{"type":"wargame.sessions.ack"}');
  });

  test('native onMessage emits raw watch payloads', () async {
    messenger.setMockMethodCallHandler(methodChannel, (_) async => null);
    final channel = AndroidInterconnectChannel(methodChannel: methodChannel);
    final messages = <String>[];
    final subscription = channel.messages.listen(messages.add);

    await messenger.handlePlatformMessage(
      AndroidInterconnectChannel.channelName,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('onMessage', '{"type":"wargame.sessions.push"}'),
      ),
      (_) {},
    );
    await Future<void>.delayed(Duration.zero);

    expect(messages, ['{"type":"wargame.sessions.push"}']);
    await subscription.cancel();
  });
}
