import 'package:flutter/material.dart';

import '../models/wargame_session.dart';
import '../theme/app_theme.dart';

class MatchRecordCard extends StatelessWidget {
  const MatchRecordCard({
    super.key,
    required this.session,
    this.dense = false,
    this.index = 0,
    this.onTap,
  });

  final WargameSession session;
  final bool dense;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final card = Container(
      margin: EdgeInsets.only(bottom: dense ? 10 : 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: AppTheme.panelDecoration(context),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(dense ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 34,
                        decoration: BoxDecoration(
                          color: session.kills >= session.deaths
                              ? AppColors.kill
                              : AppColors.death,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.startLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '持续 ${session.durationLabel}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.death,
                      ),
                    ],
                  ),
                  SizedBox(height: dense ? 12 : 16),
                  Row(
                    children: [
                      _CompactMetric(
                        label: 'K',
                        value: '${session.kills}',
                        color: AppColors.kill,
                      ),
                      _CompactMetric(
                        label: 'D',
                        value: '${session.deaths}',
                        color: AppColors.death,
                      ),
                      _CompactMetric(
                        label: 'KD',
                        value: session.kdLabel,
                        color: colors.text,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Hero(tag: session.heroTag, child: card),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  const _CompactMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.wargameColors.muted,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
