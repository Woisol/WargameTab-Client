import '../models/wargame_session.dart';

final mockFinishedSessions = <WargameSession>[
  _session(
    id: 'session_20260710_night',
    start: DateTime(2026, 7, 10, 20, 34),
    minutes: 52,
    kills: 18,
    deaths: 5,
    synced: true,
  ),
  _session(
    id: 'session_20260706_factory',
    start: DateTime(2026, 7, 6, 15, 12),
    minutes: 43,
    kills: 12,
    deaths: 7,
    synced: true,
  ),
  _session(
    id: 'session_20260629_valley',
    start: DateTime(2026, 6, 29, 10, 18),
    minutes: 68,
    kills: 21,
    deaths: 9,
  ),
  _session(
    id: 'session_20260621_warehouse',
    start: DateTime(2026, 6, 21, 19, 45),
    minutes: 35,
    kills: 9,
    deaths: 4,
    synced: true,
  ),
  _session(
    id: 'session_20260612_hill',
    start: DateTime(2026, 6, 12, 8, 40),
    minutes: 74,
    kills: 24,
    deaths: 11,
  ),
  _session(
    id: 'session_20260601_city',
    start: DateTime(2026, 6, 1, 16, 6),
    minutes: 48,
    kills: 15,
    deaths: 6,
    synced: true,
  ),
  _session(
    id: 'session_20260522_training',
    start: DateTime(2026, 5, 22, 13, 28),
    minutes: 29,
    kills: 7,
    deaths: 2,
    synced: true,
  ),
];

WargameSession _session({
  required String id,
  required DateTime start,
  required int minutes,
  required int kills,
  required int deaths,
  bool synced = false,
}) {
  return WargameSession(
    sessionId: id,
    startTime: start.millisecondsSinceEpoch,
    endTime: start.add(Duration(minutes: minutes)).millisecondsSinceEpoch,
    status: synced ? 'synced' : 'finished',
    summary: WargameSummary(kills: kills, deaths: deaths),
    events: [
      for (var index = 0; index < kills; index += 1)
        WargameEvent(
          eventId: '${id}_kill_$index',
          type: 'kill',
          time: 90 + index * 103,
        ),
      for (var index = 0; index < deaths; index += 1)
        WargameEvent(
          eventId: '${id}_death_$index',
          type: 'death',
          time: 180 + index * 211,
        ),
    ],
  );
}
