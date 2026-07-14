// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Wargame Tab';

  @override
  String get navHome => '首页';

  @override
  String get navDevice => '设备';

  @override
  String get navSettings => '设置';

  @override
  String homeLoadedSessions(int count) {
    return '已载入 $count 场手表记录';
  }

  @override
  String get emptySessions => '暂无对局记录';

  @override
  String get careerStats => '生涯战绩';

  @override
  String get kpm => 'KPM';

  @override
  String get totalDuration => '总时长';

  @override
  String get totalMatches => '总局数';

  @override
  String get averageKills => '平均击杀';

  @override
  String get bestKills => '最高击杀';

  @override
  String get latestMatch => '最近一场';

  @override
  String get history => '历史对局';

  @override
  String get showMore => '展示更多';

  @override
  String get device => '设备';

  @override
  String get deviceDescription => '配对通道用于接收手表自动发送的已完成对局。';

  @override
  String get syncSummary => '同步摘要';

  @override
  String get lastSync => '最近同步';

  @override
  String get writtenMatches => '本次写入';

  @override
  String get androidChannelWaiting => '等待启用 Android 互联通道';

  @override
  String get androidChannelRequested => 'Android 互联通道已请求启用';

  @override
  String get androidChannelUnavailable => 'Android 互联通道未注册';

  @override
  String get androidChannelStopped => 'Android 互联通道已停用';

  @override
  String get mockChannelEnabled => '已启用本地模拟配对通道';

  @override
  String get invalidWatchMessage => '无法解析手表同步消息';

  @override
  String get invalidMockAck => '模拟通道无法解析 ACK';

  @override
  String importedMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 场',
      zero: '0 场',
    );
    return '$_temp0';
  }

  @override
  String get channelStatus => '通道状态';

  @override
  String get waitingWatch => '等待手表发送';

  @override
  String get channelNotEnabled => '尚未启用';

  @override
  String get diagnosticChannel => '诊断通道';

  @override
  String get status => '状态';

  @override
  String get channelEnabled => '通道已启用';

  @override
  String get pairingChannel => '配对通道';

  @override
  String get writingWatchData => '正在写入手表发送的数据';

  @override
  String get enableChannel => '启用通道';

  @override
  String get disableChannel => '停用通道';

  @override
  String get channelRunning => '配对通道运行中';

  @override
  String get neverSynced => '从未同步';

  @override
  String todayAt(String time) {
    return '今天 $time';
  }

  @override
  String get settings => '设置';

  @override
  String get settingsSubtitle => '先把界面风格确定下来';

  @override
  String get themeAppearance => '主题外观';

  @override
  String get themeDescription => '默认深色，可切换为浅色或跟随系统。';

  @override
  String get darkTheme => '深色';

  @override
  String get lightTheme => '浅色';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get interconnectDebug => '互联调试';

  @override
  String get interconnectDebugDescription => '写入 logcat，并在标记为 Toast 的节点显示提示。';

  @override
  String get language => '语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get allMatches => '全部对局';

  @override
  String matchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 场',
      zero: '0 场',
    );
    return '$_temp0';
  }

  @override
  String matchReview(String date) {
    return '$date 复盘';
  }

  @override
  String get moreActions => '更多操作';

  @override
  String get delete => '删除';

  @override
  String get deleteMatch => '删除对局';

  @override
  String get confirmDeleteMatch => '确认删除这场对局？';

  @override
  String get cancel => '取消';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get matchTime => '比赛时间';

  @override
  String durationDetail(int minutes, int seconds) {
    return '总时长：$minutes 分钟 $seconds 秒';
  }

  @override
  String get timeline => 'K/D 时间线';

  @override
  String get eventKill => '击杀';

  @override
  String get eventDeath => '死亡';

  @override
  String get unknownEvent => '未知事件';
}
