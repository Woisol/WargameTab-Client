class WargameSession {
  const WargameSession({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.summary,
    required this.events,
  });

  final String sessionId;
  final int startTime;
  final int endTime;
  final String status;
  final WargameSummary summary;
  final List<WargameEvent> events;

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

}

class WargameSummary {
  const WargameSummary({required this.kills, required this.deaths});

  final int kills;
  final int deaths;
}

class WargameEvent {
  const WargameEvent({
    required this.eventId,
    required this.type,
    required this.time,
    this.meta = const {'actionSource': 'manual'},
  });

  final String eventId;
  final String type;
  final int time;
  final Map<String, String> meta;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String _clockLabel(DateTime value) {
  final hour = _twoDigits(value.hour);
  final minute = _twoDigits(value.minute);
  final second = _twoDigits(value.second);
  return '$hour:$minute:$second';
}
