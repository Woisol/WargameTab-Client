import 'dart:convert';

import '../models/wargame_session.dart';
import 'key_value_store.dart';

class SessionRepository {
  const SessionRepository({required this.store, this.seedSessions = const []});

  static const sessionsKey = 'wargame_client_sessions';

  final KeyValueStore store;
  final List<WargameSession> seedSessions;

  Future<List<WargameSession>> loadSessions() async {
    final raw = await store.getString(sessionsKey);
    if (raw == null || raw.isEmpty) {
      final seeded = [...seedSessions]
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      if (seeded.isNotEmpty) {
        await saveSessions(seeded);
      }
      return seeded;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      final sessions =
          decoded
              .whereType<Map>()
              .map(
                (item) =>
                    WargameSession.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((item) => item.sessionId.isNotEmpty)
              .toList()
            ..sort((a, b) => b.startTime.compareTo(a.startTime));
      return sessions;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<WargameSession> sessions) async {
    final ordered = [...sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    await store.setString(
      sessionsKey,
      jsonEncode(ordered.map((session) => session.toJson()).toList()),
    );
  }

  Future<List<WargameSession>> deleteSession(String sessionId) async {
    if (sessionId.isEmpty) {
      return loadSessions();
    }

    final sessions = await loadSessions();
    final remaining = sessions
        .where((session) => session.sessionId != sessionId)
        .toList();
    await saveSessions(remaining);
    return remaining;
  }

  Future<List<WargameSession>> upsertSyncedSessions(
    List<WargameSession> incoming,
  ) async {
    final byId = <String, WargameSession>{
      for (final session in await loadSessions()) session.sessionId: session,
    };

    for (final session in incoming) {
      if (session.sessionId.isNotEmpty) {
        byId[session.sessionId] = session.copyWith(status: 'synced');
      }
    }

    final sessions = byId.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    await saveSessions(sessions);
    return sessions;
  }
}
