// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wargame Tab';

  @override
  String get navHome => 'Home';

  @override
  String get navDevice => 'Device';

  @override
  String get navSettings => 'Settings';

  @override
  String homeLoadedSessions(int count) {
    return 'Loaded $count watch matches';
  }

  @override
  String get emptySessions => 'No match records';

  @override
  String get careerStats => 'Career stats';

  @override
  String get kpm => 'KPM';

  @override
  String get totalDuration => 'Total time';

  @override
  String get totalMatches => 'Matches';

  @override
  String get averageKills => 'Average kills';

  @override
  String get bestKills => 'Best kills';

  @override
  String get latestMatch => 'Latest match';

  @override
  String get history => 'Match history';

  @override
  String get showMore => 'Show more';

  @override
  String get device => 'Device';

  @override
  String get deviceDescription =>
      'The paired channel receives completed matches sent automatically by the watch.';

  @override
  String get syncSummary => 'Sync summary';

  @override
  String get lastSync => 'Last sync';

  @override
  String get writtenMatches => 'Written';

  @override
  String get androidChannelWaiting => 'Waiting to enable Android interconnect';

  @override
  String get androidChannelRequested => 'Android interconnect enable requested';

  @override
  String get androidChannelUnavailable =>
      'Android interconnect is not registered';

  @override
  String get androidChannelStopped => 'Android interconnect stopped';

  @override
  String get mockChannelEnabled => 'Local mock pairing channel enabled';

  @override
  String get invalidWatchMessage => 'Could not parse watch sync message';

  @override
  String get invalidMockAck => 'Mock channel could not parse ACK';

  @override
  String importedMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
      zero: '0 matches',
    );
    return '$_temp0';
  }

  @override
  String get channelStatus => 'Channel status';

  @override
  String get waitingWatch => 'Waiting for watch';

  @override
  String get channelNotEnabled => 'Not enabled';

  @override
  String get diagnosticChannel => 'Diagnostic channel';

  @override
  String get status => 'Status';

  @override
  String get channelEnabled => 'Channel enabled';

  @override
  String get pairingChannel => 'Paired channel';

  @override
  String get writingWatchData => 'Writing data sent by the watch';

  @override
  String get enableChannel => 'Enable channel';

  @override
  String get disableChannel => 'Disable channel';

  @override
  String get channelRunning => 'Paired channel is running';

  @override
  String get neverSynced => 'Never synced';

  @override
  String todayAt(String time) {
    return 'Today $time';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Set the interface style';

  @override
  String get themeAppearance => 'Theme appearance';

  @override
  String get themeDescription =>
      'Dark by default; switch to light or follow the system.';

  @override
  String get darkTheme => 'Dark';

  @override
  String get lightTheme => 'Light';

  @override
  String get systemTheme => 'System';

  @override
  String get interconnectDebug => 'Interconnect debug';

  @override
  String get interconnectDebugDescription =>
      'Write to logcat and show marked Toast messages.';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow system';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get allMatches => 'All matches';

  @override
  String matchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
      zero: '0 matches',
    );
    return '$_temp0';
  }

  @override
  String matchReview(String date) {
    return '$date review';
  }

  @override
  String get moreActions => 'More actions';

  @override
  String get delete => 'Delete';

  @override
  String get deleteMatch => 'Delete match';

  @override
  String get confirmDeleteMatch => 'Delete this match?';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get matchTime => 'Match time';

  @override
  String durationDetail(int minutes, int seconds) {
    return 'Total time: ${minutes}m ${seconds}s';
  }

  @override
  String get timeline => 'K/D timeline';

  @override
  String get eventKill => 'Kill';

  @override
  String get eventDeath => 'Death';

  @override
  String get unknownEvent => 'Unknown event';
}
