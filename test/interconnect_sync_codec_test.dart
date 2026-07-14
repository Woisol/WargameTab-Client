import 'dart:convert';

import 'package:client/sync/interconnect_sync_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = InterconnectSyncCodec();

  test('decodePush parses watch-shaped sessions into WatchSyncPayload', () {
    final payload = codec.decodePush(
      jsonEncode({
        'type': 'wargame.sessions.push',
        'protocolVersion': 1,
        'messageId': 'sync_a',
        'deviceId': 'watch_a',
        'appVersion': '1.2.3',
        'lastSyncAt': 1752057999000,
        'createdAt': 1752058000000,
        'sessions': [
          {
            'sessionId': 'session_a',
            'startTime': 1752057600000,
            'endTime': 1752057900000,
            'status': 'finished',
            'summary': {'kills': 3, 'deaths': 1},
            'events': [
              {
                'eventId': 'event_kill',
                'type': 'kill',
                'time': 120,
                'meta': {'actionSource': 'manual'},
              },
            ],
          },
          {
            'sessionId': '',
            'startTime': 1752057600000,
            'endTime': 1752057900000,
            'status': 'finished',
            'summary': {'kills': 1, 'deaths': 0},
            'events': const [],
          },
        ],
      }),
    );

    expect(payload, isNotNull);
    expect(payload!.protocolVersion, 1);
    expect(payload.messageId, 'sync_a');
    expect(payload.deviceId, 'watch_a');
    expect(payload.appVersion, '1.2.3');
    expect(payload.lastSyncAt, 1752057999000);
    expect(payload.sessions, hasLength(1));
    expect(payload.sessions.single.sessionId, 'session_a');
    expect(payload.sessions.single.kills, 3);
    expect(payload.sessions.single.events.single.meta['actionSource'], 'manual');
  });

  test('decodePush falls back to createdAt when lastSyncAt is missing', () {
    final payload = codec.decodePush(
      jsonEncode({
        'type': 'wargame.sessions.push',
        'protocolVersion': 1,
        'messageId': 'sync_created_at',
        'deviceId': 'watch_a',
        'createdAt': 1752058000000,
        'sessions': [_validSessionJson()],
      }),
    );

    expect(payload, isNotNull);
    expect(payload!.lastSyncAt, 1752058000000);
    expect(payload.appVersion, '');
  });

  test('decodePush rejects missing or empty messageId', () {
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 1,
          'sessions': const [],
        }),
      ),
      isNull,
    );
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 1,
          'messageId': '',
          'sessions': const [],
        }),
      ),
      isNull,
    );
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 1,
          'messageId': 'sync_empty',
          'sessions': const [],
        }),
      ),
      isNull,
    );
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 1,
          'messageId': 'sync_ongoing',
          'sessions': [
            {
              'sessionId': 'ongoing',
              'status': 'ongoing',
              'summary': {'kills': 1, 'deaths': 0},
              'events': const [],
            },
          ],
        }),
      ),
      isNull,
    );
  });

  test('decodePush rejects invalid push payloads', () {
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'unknown',
          'protocolVersion': 1,
          'messageId': 'sync_unknown',
          'sessions': const [],
        }),
      ),
      isNull,
    );
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 2,
          'messageId': 'sync_v2',
          'sessions': const [],
        }),
      ),
      isNull,
    );
    expect(codec.decodePush('{invalid'), isNull);
    expect(
      codec.decodePush(
        jsonEncode({
          'type': 'wargame.sessions.push',
          'protocolVersion': 1,
          'messageId': 'sync_missing_sessions',
        }),
      ),
      isNull,
    );
  });

  test('encodeAck encodes protocol ack and filters empty session ids', () {
    final payload = codec.decodePush(
      jsonEncode({
        'type': 'wargame.sessions.push',
        'protocolVersion': 1,
        'messageId': 'sync_a',
        'sessions': [_validSessionJson()],
      }),
    );
    final raw = codec.encodeAck(
      ackMessageId: payload!.messageId,
      sessionIds: ['session_a', '', 'session_b'],
    );
    final ack = jsonDecode(raw) as Map<String, dynamic>;

    expect(ack['type'], 'wargame.sessions.ack');
    expect(ack['protocolVersion'], 1);
    expect(ack['messageId'], isA<String>());
    expect((ack['messageId'] as String).startsWith('ack_'), isTrue);
    expect(ack['ackMessageId'], 'sync_a');
    expect(ack['sessionIds'], ['session_a', 'session_b']);
    expect(ack['savedAt'], isA<int>());
  });
}

Map<String, dynamic> _validSessionJson() {
  return {
    'sessionId': 'session_codec',
    'startTime': 1752057600000,
    'endTime': 1752057900000,
    'status': 'finished',
    'summary': {'kills': 1, 'deaths': 0},
    'events': const [],
  };
}
