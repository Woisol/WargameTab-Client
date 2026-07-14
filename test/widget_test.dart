import 'package:client/main.dart';
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
    await tester.pumpWidget(const WargameClientApp());
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

    await tester.tap(find.byType(MatchRecordCard).first);
    await tester.pumpAndSettle();

    expect(find.text('2026-07-10 复盘'), findsOneWidget);
  });

  testWidgets('show more opens the full history list', (tester) async {
    await tester.pumpWidget(const WargameClientApp());
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
    await tester.pumpWidget(const WargameClientApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();

    expect(find.text('主题外观'), findsOneWidget);
    expect(find.text('深色'), findsOneWidget);
    expect(find.text('浅色'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
  });

  testWidgets('device tab exposes the automatically started paired channel', (
    tester,
  ) async {
    await tester.pumpWidget(const WargameClientApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('设备'));
    await tester.pumpAndSettle();

    expect(find.text('通道已启用'), findsOneWidget);
    expect(find.text('停用通道'), findsOneWidget);
    expect(find.text('等待手表发送'), findsOneWidget);
    expect(find.text('同步摘要'), findsOneWidget);
  });

  testWidgets('automatically started mock channel imports synced sessions', (
    tester,
  ) async {
    await tester.pumpWidget(const WargameClientApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('设备'));
    await tester.pumpAndSettle();

    expect(find.text('通道已启用'), findsOneWidget);
    expect(find.text('2 场'), findsOneWidget);
  });
}
