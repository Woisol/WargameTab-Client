import 'package:client/main.dart';
import 'package:client/widgets/match_record_card.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(find.text('历史对局'), findsOneWidget);
    expect(find.byType(MatchRecordCard), findsNWidgets(4));

    await tester.tap(find.byType(MatchRecordCard).first);
    await tester.pumpAndSettle();

    expect(find.text('2026-07-10 复盘'), findsOneWidget);
  });

  testWidgets('show more opens the full history list', (tester) async {
    await tester.pumpWidget(const WargameClientApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('展示更多'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
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
}
