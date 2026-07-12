import 'wargame_session.dart';

class CareerStats {
  const CareerStats({
    required this.totalKills,
    required this.totalDeaths,
    required this.totalDuration,
    required this.matchCount,
    required this.averageKills,
    required this.bestKills,
  });

  factory CareerStats.fromSessions(List<WargameSession> sessions) {
    // 后续接入真实同步后，这里对应的聚合结果应在同步完成时持久化更新。
    final totalKills = sessions.fold(0, (total, item) => total + item.kills);
    final totalDeaths = sessions.fold(0, (total, item) => total + item.deaths);
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (total, item) => total + item.duration,
    );
    final bestKills = sessions.fold(
      0,
      (best, item) => item.kills > best ? item.kills : best,
    );

    return CareerStats(
      totalKills: totalKills,
      totalDeaths: totalDeaths,
      totalDuration: totalDuration,
      matchCount: sessions.length,
      averageKills: sessions.isEmpty ? 0 : totalKills / sessions.length,
      bestKills: bestKills,
    );
  }

  final int totalKills;
  final int totalDeaths;
  final Duration totalDuration;
  final int matchCount;
  final double averageKills;
  final int bestKills;

  double get kdRatio =>
      totalDeaths == 0 ? totalKills.toDouble() : totalKills / totalDeaths;

  double get kpm {
    final minutes = totalDuration.inSeconds / 60;
    if (minutes <= 0) {
      return 0;
    }
    return totalKills / minutes;
  }

  String get kdLabel => kdRatio.toStringAsFixed(2);

  String get kpmLabel => kpm.toStringAsFixed(2);

  String get averageKillsLabel => averageKills.toStringAsFixed(1);

  String get totalDurationLabel {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
