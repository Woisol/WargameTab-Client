import 'package:client/data/key_value_store.dart';
import 'package:client/data/session_repository.dart';
import 'package:client/models/wargame_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WargameSession round trips watch-shaped json', () {
    final session = WargameSession.fromJson({
      'sessionId': 'session_a',
      'startTime': 1752057600000,
      'endTime': 1752057900000,
      'status': 'finished',
      'summary': {'kills': 2, 'deaths': 1},
      'events': [
        {
          'eventId': 'event_k',
          'type': 'kill',
          'time': 12,
          'meta': {'actionSource': 'manual'},
        },
        {
          'eventId': 'event_d',
          'type': 'death',
          'time': 30,
          'meta': {'actionSource': 'click'},
        },
      ],
    });

    expect(session.sessionId, 'session_a');
    expect(session.kills, 2);
    expect(session.deaths, 1);
    expect(session.events.last.meta['actionSource'], 'click');
    expect(session.toJson(), {
      'sessionId': 'session_a',
      'startTime': 1752057600000,
      'endTime': 1752057900000,
      'status': 'finished',
      'summary': {'kills': 2, 'deaths': 1},
      'events': [
        {
          'eventId': 'event_k',
          'type': 'kill',
          'time': 12,
          'meta': {'actionSource': 'manual'},
        },
        {
          'eventId': 'event_d',
          'type': 'death',
          'time': 30,
          'meta': {'actionSource': 'click'},
        },
      ],
    });
  });

  test('SessionRepository loads seeded sessions once and dedupes imports', () async {
    final store = MemoryKeyValueStore();
    final repository = SessionRepository(
      store: store,
      seedSessions: [
        _session('session_old', 1000, kills: 1),
        _session('session_replace', 2000, kills: 2),
      ],
    );

    expect(await repository.loadSessions(), hasLength(2));

    await repository.upsertSyncedSessions([
      _session('session_replace', 3000, kills: 5),
      _session('session_new', 4000, deaths: 2),
    ]);

    final sessions = await repository.loadSessions();

    expect(sessions.map((item) => item.sessionId), [
      'session_new',
      'session_replace',
      'session_old',
    ]);
    expect(sessions[1].kills, 5);
    expect(sessions[1].status, 'synced');
    expect(await store.getString(SessionRepository.sessionsKey), isNotNull);
  });

  test('SessionRepository deletes one session and persists the remaining sessions', () async {
    final repository = SessionRepository(store: MemoryKeyValueStore());
    await repository.saveSessions([
      _session('session_keep', 1000, kills: 1),
      _session('session_remove', 2000, kills: 2),
    ]);

    final remaining = await repository.deleteSession('session_remove');

    expect(remaining.map((item) => item.sessionId), ['session_keep']);
    expect((await repository.loadSessions()).map((item) => item.sessionId), [
      'session_keep',
    ]);
  });
}

WargameSession _session(
  String id,
  int startTime, {
  int kills = 0,
  int deaths = 0,
}) {
  return WargameSession(
    sessionId: id,
    startTime: startTime,
    endTime: startTime + 60000,
    status: 'finished',
    summary: WargameSummary(kills: kills, deaths: deaths),
    events: const [],
  );
}
