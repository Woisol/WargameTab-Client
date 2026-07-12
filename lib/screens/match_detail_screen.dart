import 'package:flutter/material.dart';

import '../models/wargame_session.dart';
import '../theme/app_theme.dart';
import '../widgets/match_score_panel.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.session});

  final WargameSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${session.dateLabel} 复盘')),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            MatchScorePanel(session: session, large: true),
            const SizedBox(height: 14),
            _TimePanel(session: session),
            const SizedBox(height: 14),
            _TimelinePanel(session: session),
          ],
        ),
      ),
    );
  }
}

class _TimePanel extends StatelessWidget {
  const _TimePanel({required this.session});

  final WargameSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('比赛时间', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            session.timeRangeLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '总时长：${session.durationDetailLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({required this.session});

  final WargameSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: AppTheme.panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('K/D 时间线', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Expanded(child: _TimelineChart(session: session)),
        ],
      ),
    );
  }
}

class _TimelineChart extends StatelessWidget {
  const _TimelineChart({required this.session});

  final WargameSession session;

  @override
  Widget build(BuildContext context) {
    final durationSeconds = session.duration.inSeconds <= 0
        ? 1
        : session.duration.inSeconds;
    final colors = context.wargameColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - 26;
        final midY = chartHeight / 2;
        final labels = _timelineLabels(durationSeconds);
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: midY,
              child: Container(height: 1, color: colors.line),
            ),
            for (final event in session.events)
              Positioned(
                left: ((event.time.clamp(0, durationSeconds) as num).toDouble() /
                        durationSeconds) *
                    (constraints.maxWidth - 5),
                top: event.type == 'kill' ? midY - 28 : midY + 8,
                child: Container(
                  width: 5,
                  height: 22,
                  decoration: BoxDecoration(
                    color: event.type == 'kill'
                        ? AppColors.kill
                        : AppColors.death,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  for (final label in labels)
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

List<String> _timelineLabels(int seconds) {
  final half = (seconds / 2).round();
  final threeQuarter = (seconds * 3 / 4).round();
  return [
    '0:00',
    _minuteLabel(half),
    _minuteLabel(threeQuarter),
    _minuteLabel(seconds),
  ];
}

String _minuteLabel(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = seconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
