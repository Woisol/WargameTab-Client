import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedStat extends StatelessWidget {
  const AnimatedStat({
    super.key,
    required this.label,
    required this.value,
    this.suffix = '',
    this.color,
    this.decimals = 0,
  });

  final String label;
  final double value;
  final String suffix;
  final Color? color;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 720),
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${animatedValue.toStringAsFixed(decimals)}$suffix',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color ?? colors.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
