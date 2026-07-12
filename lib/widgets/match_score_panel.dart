import 'package:flutter/material.dart';

import '../models/wargame_session.dart';
import '../theme/app_theme.dart';

class MatchScorePanel extends StatelessWidget {
  const MatchScorePanel({super.key, required this.session, this.large = false});

  final WargameSession session;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final height = large ? 206.0 : 176.0;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: AppTheme.panelDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: _ScoreWing(
              letter: 'K',
              value: session.kills,
              color: AppColors.kill,
              large: large,
            ),
          ),
          SizedBox(
            width: large ? 168 : 128,
            child: _KdCore(session: session, large: large),
          ),
          Expanded(
            child: _ScoreWing(
              letter: 'D',
              value: session.deaths,
              color: AppColors.death,
              large: large,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreWing extends StatelessWidget {
  const _ScoreWing({
    required this.letter,
    required this.value,
    required this.color,
    required this.large,
  });

  final String letter;
  final int value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          letter,
          style: TextStyle(
            color: color.withAlpha(31),
            fontSize: large ? 112 : 92,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 620),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toStringAsFixed(0),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: context.wargameColors.text,
                fontSize: large ? 70 : 56,
                fontWeight: FontWeight.w400,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _KdCore extends StatelessWidget {
  const _KdCore({required this.session, required this.large});

  final WargameSession session;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: session.kdRatio),
          duration: const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              animatedValue.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: context.wargameColors.text,
                fontSize: large ? 72 : 58,
                fontWeight: FontWeight.w900,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        ClipPath(
          clipper: const _KdMarkerClipper(),
          child: Container(
            height: large ? 14 : 10,
            width: large ? 104 : 82,
            color: context.wargameColors.line,
          ),
        ),
      ],
    );
  }
}

class _KdMarkerClipper extends CustomClipper<Path> {
  const _KdMarkerClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
