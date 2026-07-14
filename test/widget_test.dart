import 'package:client/main.dart';
import 'package:client/data/client_settings_repository.dart';
import 'package:client/data/key_value_store.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:client/models/wargame_session.dart';
import 'package:client/screens/match_detail_screen.dart';
import 'package:client/theme/app_theme.dart';
import 'package:client/sync/watch_sync_channel.dart';
import 'package:client/widgets/match_score_panel.dart';
import 'package:client/widgets/match_record_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release channel modes do not seed mock sessions', () {
    expect(seedSessionsForChannelMode('android', isDebug: false), isEmpty);
    expect(seedSessionsForChannelMode('auto', isDebug: false), isEmpty);
    expect(
      seedSessionsForChannelMode('mock', isDebug: false),
      isNotEmpty,
    );
    expect(
      seedSessionsForChannelMode('auto', isDebug: true),
      isNotEmpty,
    );
  });

  testWidgets('home renders mock career summary and latest match', (
    tester,
  ) async {
    await _pumpChineseApp(tester, watchSyncChannel: _NoopWatchSyncChannel());
    await tester.pumpAndSettle();

    expect(find.text('Wargame Tab'), findsOneWidget);
    expect(find.text('生涯战绩'), findsOneWidget);
    expect(find.text('KPM'), findsOneWidget);
    expect(find.text('总时长'), findsOneWidget);
    expect(find.text('平均击杀'), findsOneWidget);
    expect(find.text('最近一场'), findsOneWidget);

    final outerScrollable = find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.physics is BouncingScrollPhysics,
    );

    await tester.scrollUntilVisible(
      find.text('历史对局'),
      240,
      scrollable: outerScrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('历史对局'), findsOneWidget);
    expect(find.byType(MatchRecordCard), findsNWidgets(4));

    await tester.scrollUntilVisible(
      find.byType(MatchRecordCard).first,
      180,
      scrollable: outerScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MatchRecordCard).first);
    await tester.pumpAndSettle();

    expect(find.text('2026-07-10 复盘'), findsOneWidget);
  });

  testWidgets('show more opens the full history list', (tester) async {
    await _pumpChineseApp(tester, watchSyncChannel: _NoopWatchSyncChannel());
    await tester.pumpAndSettle();

    final outerScrollable = find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.physics is BouncingScrollPhysics,
    );

    await tester.scrollUntilVisible(
      find.text('展示更多'),
      240,
      scrollable: outerScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('展示更多'));
    await tester.pumpAndSettle();

    expect(find.text('全部对局'), findsOneWidget);
    expect(find.text('7 场'), findsOneWidget);
  });

  testWidgets('settings tab exposes theme mode choices', (tester) async {
    await _pumpChineseApp(tester, watchSyncChannel: _NoopWatchSyncChannel());
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('主题外观'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(find.text('浅色'), findsOneWidget);
    expect(find.text('跟随系统'), findsAtLeastNWidgets(1));
    expect(find.text('互联调试'), findsOneWidget);
  });

  testWidgets('settings tab exposes language choices and switches to English', (
    tester,
  ) async {
    await _pumpChineseApp(tester, watchSyncChannel: _NoopWatchSyncChannel());

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<ClientLocaleMode>));
    await tester.pumpAndSettle();

    expect(find.text('跟随系统'), findsAtLeastNWidgets(1));
    expect(find.text('中文'), findsAtLeastNWidgets(1));
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsAtLeastNWidgets(1));
    expect(find.text('Language'), findsAtLeastNWidgets(1));
  });

  testWidgets('latest match score panel opens its detail screen', (tester) async {
    await _pumpChineseApp(tester, watchSyncChannel: _NoopWatchSyncChannel());

    final outerScrollable = find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.physics is BouncingScrollPhysics,
    );
    await tester.scrollUntilVisible(
      find.byType(MatchScorePanel),
      240,
      scrollable: outerScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(MatchScorePanel).first);
    await tester.pumpAndSettle();

    expect(find.text('2026-07-10 复盘'), findsOneWidget);
  });

  testWidgets('device tab exposes the automatically started paired channel', (
    tester,
  ) async {
    await _pumpChineseApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('设备'));
    await tester.pumpAndSettle();

    expect(find.text('通道已启用'), findsOneWidget);
    expect(find.text('停用通道'), findsOneWidget);
    expect(find.text('等待手表发送'), findsAtLeastNWidgets(1));
    expect(find.text('同步摘要'), findsOneWidget);
  });

  testWidgets('automatically started mock channel imports synced sessions', (
    tester,
  ) async {
    await _pumpChineseApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('设备'));
    await tester.pumpAndSettle();

    expect(find.text('通道已启用'), findsOneWidget);
    expect(find.text('2 场'), findsOneWidget);
  });

  testWidgets('match detail delete menu requires confirmation', (tester) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: MatchDetailScreen(
          session: _widgetSession(),
          onDeleteSession: (_) async {
            deleted = true;
            return const <WargameSession>[];
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('删除'), findsOneWidget);
    await tester.tap(find.text('删除'));
    await tester.pumpAndSettle();

    expect(find.text('删除对局'), findsOneWidget);
    expect(find.text('确认删除这场对局？'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });
}

Future<void> _pumpChineseApp(
  WidgetTester tester, {
  WatchSyncChannel? watchSyncChannel,
}) async {
  final store = MemoryKeyValueStore();
  await store.setString(ClientSettingsRepository.localeModeKey, 'zh');
  await tester.pumpWidget(
    WargameClientApp(
      settingsRepository: ClientSettingsRepository(store: store),
      watchSyncChannel: watchSyncChannel,
    ),
  );
  await tester.pumpAndSettle();
}

class _NoopWatchSyncChannel implements WatchSyncChannel {
  @override
  Stream<String> get messages => Stream<String>.empty();

  @override
  WatchSyncChannelState get state =>
      const WatchSyncChannelState(available: true);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> send(String raw) async {}
}

WargameSession _widgetSession() {
  return WargameSession(
    sessionId: 'widget_session',
    startTime: 1752057600000,
    endTime: 1752057900000,
    status: 'finished',
    summary: const WargameSummary(kills: 2, deaths: 1),
    events: const [],
  );
}
