import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Wargame Tab'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get navHome;

  /// No description provided for @navDevice.
  ///
  /// In zh, this message translates to:
  /// **'设备'**
  String get navDevice;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @homeLoadedSessions.
  ///
  /// In zh, this message translates to:
  /// **'已载入 {count} 场手表记录'**
  String homeLoadedSessions(int count);

  /// No description provided for @emptySessions.
  ///
  /// In zh, this message translates to:
  /// **'暂无对局记录'**
  String get emptySessions;

  /// No description provided for @careerStats.
  ///
  /// In zh, this message translates to:
  /// **'生涯战绩'**
  String get careerStats;

  /// No description provided for @kpm.
  ///
  /// In zh, this message translates to:
  /// **'KPM'**
  String get kpm;

  /// No description provided for @totalDuration.
  ///
  /// In zh, this message translates to:
  /// **'总时长'**
  String get totalDuration;

  /// No description provided for @totalMatches.
  ///
  /// In zh, this message translates to:
  /// **'总局数'**
  String get totalMatches;

  /// No description provided for @averageKills.
  ///
  /// In zh, this message translates to:
  /// **'平均击杀'**
  String get averageKills;

  /// No description provided for @bestKills.
  ///
  /// In zh, this message translates to:
  /// **'最高击杀'**
  String get bestKills;

  /// No description provided for @latestMatch.
  ///
  /// In zh, this message translates to:
  /// **'最近一场'**
  String get latestMatch;

  /// No description provided for @history.
  ///
  /// In zh, this message translates to:
  /// **'历史对局'**
  String get history;

  /// No description provided for @showMore.
  ///
  /// In zh, this message translates to:
  /// **'展示更多'**
  String get showMore;

  /// No description provided for @device.
  ///
  /// In zh, this message translates to:
  /// **'设备'**
  String get device;

  /// No description provided for @deviceDescription.
  ///
  /// In zh, this message translates to:
  /// **'配对通道用于接收手表自动发送的已完成对局。'**
  String get deviceDescription;

  /// No description provided for @syncSummary.
  ///
  /// In zh, this message translates to:
  /// **'同步摘要'**
  String get syncSummary;

  /// No description provided for @lastSync.
  ///
  /// In zh, this message translates to:
  /// **'最近同步'**
  String get lastSync;

  /// No description provided for @writtenMatches.
  ///
  /// In zh, this message translates to:
  /// **'本次写入'**
  String get writtenMatches;

  /// No description provided for @androidChannelWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待启用 Android 互联通道'**
  String get androidChannelWaiting;

  /// No description provided for @androidChannelRequested.
  ///
  /// In zh, this message translates to:
  /// **'Android 互联通道已请求启用'**
  String get androidChannelRequested;

  /// No description provided for @androidChannelUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Android 互联通道未注册'**
  String get androidChannelUnavailable;

  /// No description provided for @androidChannelStopped.
  ///
  /// In zh, this message translates to:
  /// **'Android 互联通道已停用'**
  String get androidChannelStopped;

  /// No description provided for @mockChannelEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已启用本地模拟配对通道'**
  String get mockChannelEnabled;

  /// No description provided for @invalidWatchMessage.
  ///
  /// In zh, this message translates to:
  /// **'无法解析手表同步消息'**
  String get invalidWatchMessage;

  /// No description provided for @invalidMockAck.
  ///
  /// In zh, this message translates to:
  /// **'模拟通道无法解析 ACK'**
  String get invalidMockAck;

  /// No description provided for @importedMatches.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0 {0 场} other {{count} 场}}'**
  String importedMatches(int count);

  /// No description provided for @channelStatus.
  ///
  /// In zh, this message translates to:
  /// **'通道状态'**
  String get channelStatus;

  /// No description provided for @waitingWatch.
  ///
  /// In zh, this message translates to:
  /// **'等待手表发送'**
  String get waitingWatch;

  /// No description provided for @channelNotEnabled.
  ///
  /// In zh, this message translates to:
  /// **'尚未启用'**
  String get channelNotEnabled;

  /// No description provided for @diagnosticChannel.
  ///
  /// In zh, this message translates to:
  /// **'诊断通道'**
  String get diagnosticChannel;

  /// No description provided for @status.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// No description provided for @channelEnabled.
  ///
  /// In zh, this message translates to:
  /// **'通道已启用'**
  String get channelEnabled;

  /// No description provided for @pairingChannel.
  ///
  /// In zh, this message translates to:
  /// **'配对通道'**
  String get pairingChannel;

  /// No description provided for @writingWatchData.
  ///
  /// In zh, this message translates to:
  /// **'正在写入手表发送的数据'**
  String get writingWatchData;

  /// No description provided for @enableChannel.
  ///
  /// In zh, this message translates to:
  /// **'启用通道'**
  String get enableChannel;

  /// No description provided for @disableChannel.
  ///
  /// In zh, this message translates to:
  /// **'停用通道'**
  String get disableChannel;

  /// No description provided for @channelRunning.
  ///
  /// In zh, this message translates to:
  /// **'配对通道运行中'**
  String get channelRunning;

  /// No description provided for @neverSynced.
  ///
  /// In zh, this message translates to:
  /// **'从未同步'**
  String get neverSynced;

  /// No description provided for @todayAt.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time}'**
  String todayAt(String time);

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'先把界面风格确定下来'**
  String get settingsSubtitle;

  /// No description provided for @themeAppearance.
  ///
  /// In zh, this message translates to:
  /// **'主题外观'**
  String get themeAppearance;

  /// No description provided for @themeDescription.
  ///
  /// In zh, this message translates to:
  /// **'默认深色，可切换为浅色或跟随系统。'**
  String get themeDescription;

  /// No description provided for @darkTheme.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get systemTheme;

  /// No description provided for @interconnectDebug.
  ///
  /// In zh, this message translates to:
  /// **'互联调试'**
  String get interconnectDebug;

  /// No description provided for @interconnectDebugDescription.
  ///
  /// In zh, this message translates to:
  /// **'写入 logcat，并在标记为 Toast 的节点显示提示。'**
  String get interconnectDebugDescription;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @allMatches.
  ///
  /// In zh, this message translates to:
  /// **'全部对局'**
  String get allMatches;

  /// No description provided for @matchCount.
  ///
  /// In zh, this message translates to:
  /// **'{count, plural, =0 {0 场} other {{count} 场}}'**
  String matchCount(int count);

  /// No description provided for @matchReview.
  ///
  /// In zh, this message translates to:
  /// **'{date} 复盘'**
  String matchReview(String date);

  /// No description provided for @moreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get moreActions;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @deleteMatch.
  ///
  /// In zh, this message translates to:
  /// **'删除对局'**
  String get deleteMatch;

  /// No description provided for @confirmDeleteMatch.
  ///
  /// In zh, this message translates to:
  /// **'确认删除这场对局？'**
  String get confirmDeleteMatch;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get deleteFailed;

  /// No description provided for @matchTime.
  ///
  /// In zh, this message translates to:
  /// **'比赛时间'**
  String get matchTime;

  /// No description provided for @durationDetail.
  ///
  /// In zh, this message translates to:
  /// **'总时长：{minutes} 分钟 {seconds} 秒'**
  String durationDetail(int minutes, int seconds);

  /// No description provided for @timeline.
  ///
  /// In zh, this message translates to:
  /// **'K/D 时间线'**
  String get timeline;

  /// No description provided for @eventKill.
  ///
  /// In zh, this message translates to:
  /// **'击杀'**
  String get eventKill;

  /// No description provided for @eventDeath.
  ///
  /// In zh, this message translates to:
  /// **'死亡'**
  String get eventDeath;

  /// No description provided for @unknownEvent.
  ///
  /// In zh, this message translates to:
  /// **'未知事件'**
  String get unknownEvent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
