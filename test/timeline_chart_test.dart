import 'package:client/models/wargame_session.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:client/theme/app_theme.dart';
import 'package:client/widgets/timeline_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nearestTimelineEvent returns null for an empty event list', () {
    expect(
      nearestTimelineEvent(
        events: const [],
        pointerX: 30,
        width: 100,
        durationSeconds: 100,
      ),
      isNull,
    );
  });

  test('nearestTimelineEvent selects by horizontal event position', () {
    const events = [
      WargameEvent(eventId: 'early', type: 'kill', time: 10),
      WargameEvent(eventId: 'late', type: 'death', time: 90),
    ];

    expect(
      nearestTimelineEvent(
        events: events,
        pointerX: 87,
        width: 100,
        durationSeconds: 100,
      )?.eventId,
      'late',
    );
  });

  test('nearestTimelineEvent clamps event time to chart bounds', () {
    const events = [
      WargameEvent(eventId: 'before', type: 'kill', time: -10),
      WargameEvent(eventId: 'after', type: 'death', time: 110),
    ];

    expect(
      nearestTimelineEvent(
        events: events,
        pointerX: 0,
        width: 100,
        durationSeconds: 100,
      )?.eventId,
      'before',
    );
    expect(
      nearestTimelineEvent(
        events: events,
        pointerX: 100,
        width: 100,
        durationSeconds: 100,
      )?.eventId,
      'after',
    );
  });

  test('nearestTimelineEvent keeps source order for an exact tie', () {
    const events = [
      const WargameEvent(eventId: 'first', type: 'kill', time: 25),
      const WargameEvent(eventId: 'second', type: 'death', time: 75),
    ];

    expect(
      nearestTimelineEvent(
        events: events,
        pointerX: 50,
        width: 100,
        durationSeconds: 100,
      )?.eventId,
      'first',
    );
  });

  testWidgets('TimelineChart previews the nearest event after a short tap', (
    tester,
  ) async {
    final session = WargameSession(
      sessionId: 'timeline_widget',
      startTime: 0,
      endTime: 60000,
      status: 'finished',
      summary: const WargameSummary(kills: 1, deaths: 0),
      events: const [
        WargameEvent(eventId: 'kill_30', type: 'kill', time: 30),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 180,
            child: TimelineChart(session: session),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TimelineChart));
    await tester.pumpAndSettle();

    expect(find.text('击杀'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('timeline-preview')),
        matching: find.text('00:30'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('TimelineChart keeps unknown event types visible', (tester) async {
    final session = WargameSession(
      sessionId: 'timeline_unknown',
      startTime: 0,
      endTime: 60000,
      status: 'finished',
      summary: const WargameSummary(kills: 0, deaths: 0),
      events: const [
        WargameEvent(eventId: 'assist_30', type: 'assist', time: 30),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 180,
            child: TimelineChart(session: session),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(TimelineChart)),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('assist'), findsOneWidget);

    await gesture.up();
  });
}
