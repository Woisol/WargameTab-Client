import 'dart:convert';

import '../models/wargame_session.dart';
import 'watch_sync_models.dart';

class InterconnectSyncCodec {
  const InterconnectSyncCodec();

  static const _protocolVersion = 1;
  static const _pushType = 'wargame.sessions.push';
  static const _ackType = 'wargame.sessions.ack';

  WatchSyncPayload? decodePush(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }

      final payload = Map<String, dynamic>.from(decoded);
      final sessionsJson = payload['sessions'];
      final messageId = payload['messageId'];
      final deviceId = payload['deviceId'];
      final appVersion = payload['appVersion'];
      final lastSyncAt = payload['lastSyncAt'];
      final createdAt = payload['createdAt'];
      if (payload['type'] != _pushType ||
          payload['protocolVersion'] != _protocolVersion ||
          messageId is! String ||
          messageId.isEmpty ||
          sessionsJson is! List) {
        return null;
      }

      final sessions = <WargameSession>[];
      for (final item in sessionsJson) {
        if (item is! Map || item['status'] != 'finished') {
          continue;
        }

        final session = WargameSession.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (session.sessionId.isNotEmpty && session.status == 'finished') {
          sessions.add(session);
        }
      }

      var syncTime = 0;
      if (lastSyncAt is num) {
        syncTime = lastSyncAt.toInt();
      } else if (createdAt is num) {
        syncTime = createdAt.toInt();
      }

      if (sessions.isEmpty) {
        return null;
      }

      return WatchSyncPayload(
        messageId: messageId,
        protocolVersion: _protocolVersion,
        deviceId: deviceId is String ? deviceId : '',
        appVersion: appVersion is String ? appVersion : '',
        lastSyncAt: syncTime,
        sessions: sessions,
      );
    } catch (_) {
      return null;
    }
  }

  String encodeAck({
    required String ackMessageId,
    required List<String> sessionIds,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;

    return jsonEncode({
      'type': _ackType,
      'protocolVersion': _protocolVersion,
      'messageId': 'ack_$now',
      'ackMessageId': ackMessageId,
      'sessionIds': sessionIds
          .where((sessionId) => sessionId.isNotEmpty)
          .toList(),
      'savedAt': now,
    });
  }
}
