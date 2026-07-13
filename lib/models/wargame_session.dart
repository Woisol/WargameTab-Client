class WargameSession {
  const WargameSession({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.summary,
    required this.events,
  });

  factory WargameSession.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'];
    final eventsJson = json['events'];

    return WargameSession(
      sessionId: _stringValue(json['sessionId'] ?? json['session_id']),
      startTime: _intValue(json['startTime'] ?? json['start_time']),
      endTime: _intValue(json['endTime'] ?? json['end_time']),
      status: _stringValue(json['status'], fallback: 'finished'),
      summary: summaryJson is Map
          ? WargameSummary.fromJson(Map<String, dynamic>.from(summaryJson))
          : const WargameSummary(kills: 0, deaths: 0),
      events: eventsJson is List
          ? eventsJson
                .whereType<Map>()
                .map(
                  (item) =>
                      WargameEvent.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }

  final String sessionId;
  final int startTime;
  final int endTime;
  final String status;
  final WargameSummary summary;
  final List<WargameEvent> events;

  Map<String, Object?> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'summary': summary.toJson(),
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  WargameSession copyWith({
    String? sessionId,
    int? startTime,
    int? endTime,
    String? status,
    WargameSummary? summary,
    List<WargameEvent>? events,
  }) {
    return WargameSession(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      events: events ?? this.events,
    );
  }

  DateTime get startedAt => DateTime.fromMillisecondsSinceEpoch(startTime);

  DateTime get endedAt => DateTime.fromMillisecondsSinceEpoch(endTime);

  int get kills => summary.kills;

  int get deaths => summary.deaths;

  double get kdRatio => deaths == 0 ? kills.toDouble() : kills / deaths;

  Duration get duration => endedAt.difference(startedAt);

  String get kdLabel => kdRatio.toStringAsFixed(2);

  String get startLabel {
    final month = _twoDigits(startedAt.month);
    final day = _twoDigits(startedAt.day);
    final hour = _twoDigits(startedAt.hour);
    final minute = _twoDigits(startedAt.minute);
    return '$month/$day $hour:$minute';
  }

  String get dateLabel {
    final month = _twoDigits(startedAt.month);
    final day = _twoDigits(startedAt.day);
    return '${startedAt.year}-$month-$day';
  }

  String get timeRangeLabel {
    return '${_clockLabel(startedAt)} - ${_clockLabel(endedAt)}';
  }

  String get durationLabel {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get durationDetailLabel {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes 分钟 $seconds 秒';
  }

  String get heroTag => 'match-$sessionId';
}

class WargameSummary {
  const WargameSummary({required this.kills, required this.deaths});

  factory WargameSummary.fromJson(Map<String, dynamic> json) {
    return WargameSummary(
      kills: _intValue(json['kills']),
      deaths: _intValue(json['deaths']),
    );
  }

  final int kills;
  final int deaths;

  Map<String, Object?> toJson() {
    return {'kills': kills, 'deaths': deaths};
  }
}

class WargameEvent {
  const WargameEvent({
    required this.eventId,
    required this.type,
    required this.time,
    this.meta = const {'actionSource': 'manual'},
  });

  factory WargameEvent.fromJson(Map<String, dynamic> json) {
    final metaJson = json['meta'];

    return WargameEvent(
      eventId: _stringValue(json['eventId'] ?? json['event_id']),
      type: _stringValue(json['type']),
      time: _intValue(json['time']),
      meta: metaJson is Map
          ? metaJson.map(
              (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
            )
          : const {'actionSource': 'manual'},
    );
  }

  final String eventId;
  final String type;
  final int time;
  final Map<String, String> meta;

  Map<String, Object?> toJson() {
    return {'eventId': eventId, 'type': type, 'time': time, 'meta': meta};
  }
}

int _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

String _stringValue(Object? value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  return fallback;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _clockLabel(DateTime value) {
  final hour = _twoDigits(value.hour);
  final minute = _twoDigits(value.minute);
  final second = _twoDigits(value.second);
  return '$hour:$minute:$second';
}
