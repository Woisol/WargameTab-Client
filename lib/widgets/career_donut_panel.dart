import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/career_stats.dart';
import '../theme/app_theme.dart';

class CareerDonutPanel extends StatelessWidget {
  const CareerDonutPanel({super.key, required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('生涯战绩', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SideValue(
                  label: 'K',
                  value: '${stats.totalKills}',
                  color: AppColors.kill,
                ),
              ),
              SizedBox(
                width: 156,
                height: 156,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(156),
                      painter: _CareerDonutPainter(
                        kills: stats.totalKills,
                        deaths: stats.totalDeaths,
                        trackColor: colors.line,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          stats.kdLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(fontSize: 42),
                        ),
                        Text(
                          'KD',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _SideValue(
                  label: 'D',
                  value: '${stats.totalDeaths}',
                  color: AppColors.death,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 860
                  ? 4
                  : width >= 540
                  ? 3
                  : 2;
              final metrics = [
                _DetailMetric(label: 'KPM', value: stats.kpmLabel),
                _DetailMetric(label: '总时长', value: stats.totalDurationLabel),
                _DetailMetric(label: '总局数', value: '${stats.matchCount}'),
                _DetailMetric(label: '平均击杀', value: stats.averageKillsLabel),
                _DetailMetric(label: '最高击杀', value: '${stats.bestKills}'),
              ];
              return GridView.builder(
                itemCount: metrics.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 64,
                ),
                itemBuilder: (context, index) => metrics[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SideValue extends StatelessWidget {
  const _SideValue({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CareerDonutPainter extends CustomPainter {
  const _CareerDonutPainter({
    required this.kills,
    required this.deaths,
    required this.trackColor,
  });

  final int kills;
  final int deaths;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final rect = Offset.zero & size;
    final total = kills + deaths;
    final killRatio = total == 0 ? 0.5 : kills / total;
    final deathRatio = 1 - killRatio;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    paint.color = trackColor;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      math.pi * 2,
      false,
      paint,
    );

    paint.color = AppColors.kill;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      math.pi * 2 * killRatio,
      false,
      paint,
    );

    paint.color = AppColors.death;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2 + math.pi * 2 * killRatio,
      math.pi * 2 * deathRatio,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CareerDonutPainter oldDelegate) {
    return kills != oldDelegate.kills ||
        deaths != oldDelegate.deaths ||
        trackColor != oldDelegate.trackColor;
  }
}
