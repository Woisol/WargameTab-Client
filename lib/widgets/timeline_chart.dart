import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/wargame_session.dart';
import '../theme/app_theme.dart';

WargameEvent? nearestTimelineEvent({
  required List<WargameEvent> events,
  required double pointerX,
  required double width,
  required int durationSeconds,
}) {
  if (events.isEmpty) {
    return null;
  }

  final duration = durationSeconds <= 0 ? 1 : durationSeconds;
  final trackWidth = math.max(0.0, width - 5.0).toDouble();
  WargameEvent? nearest;
  var nearestDistance = double.infinity;

  for (final event in events) {
    final seconds = event.time.clamp(0, duration) as num;
    final eventX = seconds.toDouble() / duration * trackWidth + 2.5;
    final distance = (eventX - pointerX).abs();
    if (distance < nearestDistance) {
      nearest = event;
      nearestDistance = distance;
    }
  }

  return nearest;
}

String timelineEventLabel(AppLocalizations l10n, WargameEvent event) {
  switch (event.type) {
    case 'kill':
      return l10n.eventKill;
    case 'death':
      return l10n.eventDeath;
    default:
      return event.type.isEmpty ? l10n.unknownEvent : event.type;
  }
}

class TimelineChart extends StatefulWidget {
  const TimelineChart({super.key, required this.session});

  final WargameSession session;

  @override
  State<TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<TimelineChart> {
  WargameEvent? _previewEvent;

  void _previewAt(double pointerX, double width, int durationSeconds) {
    final event = nearestTimelineEvent(
      events: widget.session.events,
      pointerX: pointerX,
      width: width,
      durationSeconds: durationSeconds,
    );
    if (_previewEvent != event) {
      setState(() {
        _previewEvent = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationSeconds = widget.session.duration.inSeconds <= 0
        ? 1
        : widget.session.duration.inSeconds;
    final l10n = AppLocalizations.of(context);
    final colors = context.wargameColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = math
            .max(0.0, constraints.maxHeight - 26.0)
            .toDouble();
        final midY = chartHeight / 2;
        final labels = _timelineLabels(durationSeconds);
        final previewEvent = _previewEvent;
        final previewLeft = previewEvent == null
            ? null
            : _previewLeft(previewEvent, constraints.maxWidth, durationSeconds);
        final previewX = previewEvent == null
            ? null
            : _eventCenterX(
                previewEvent,
                constraints.maxWidth,
                durationSeconds,
              );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _previewAt(
              details.localPosition.dx,
              constraints.maxWidth,
              durationSeconds,
            );
          },
          onLongPressStart: (details) {
            _previewAt(
              details.localPosition.dx,
              constraints.maxWidth,
              durationSeconds,
            );
          },
          onLongPressMoveUpdate: (details) {
            _previewAt(
              details.localPosition.dx,
              constraints.maxWidth,
              durationSeconds,
            );
          },
          onLongPressEnd: (_) {
            setState(() {
              _previewEvent = null;
            });
          },
          onLongPressCancel: () {
            setState(() {
              _previewEvent = null;
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: midY,
                child: Container(height: 1, color: colors.line),
              ),
              for (final event in widget.session.events)
                Positioned(
                  left: _eventLeft(
                    event,
                    constraints.maxWidth,
                    durationSeconds,
                  ),
                  top: event.type == 'kill' ? midY - 28 : midY + 8,
                  child: Container(
                    width: 5,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _eventColor(event, colors),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              if (previewEvent != null && previewX != null)
                Positioned(
                  left: previewX,
                  top: -50,
                  bottom: 26,
                  child: Container(
                    width: 1,
                    color: _eventColor(previewEvent, colors),
                  ),
                ),
              if (previewEvent != null && previewLeft != null)
                Positioned(
                  left: previewLeft,
                  top: -50,
                  child: Container(
                    key: const Key('timeline-preview'),
                    width: math.min(132.0, constraints.maxWidth).toDouble(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: AppTheme.panelDecoration(
                      context,
                      color: colors.surfaceHigh,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timelineEventLabel(l10n, previewEvent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _minuteLabel(
                            (previewEvent.time.clamp(0, durationSeconds) as num)
                                .toInt(),
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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
          ),
        );
      },
    );
  }
}

double _eventLeft(WargameEvent event, double width, int durationSeconds) {
  return (((event.time.clamp(0, durationSeconds) as num).toDouble() /
              durationSeconds) *
          math.max(0.0, width - 5.0))
      .toDouble();
}

double _eventCenterX(WargameEvent event, double width, int durationSeconds) {
  return _eventLeft(event, width, durationSeconds) + 2.5;
}

double _previewLeft(WargameEvent event, double width, int durationSeconds) {
  final popupWidth = math.min(132.0, width).toDouble();
  final maxLeft = math.max(0.0, width - popupWidth).toDouble();
  return (_eventCenterX(event, width, durationSeconds) - popupWidth / 2)
      .clamp(0.0, maxLeft)
      .toDouble();
}

Color _eventColor(WargameEvent event, WargameColors colors) {
  switch (event.type) {
    case 'kill':
      return AppColors.kill;
    case 'death':
      return AppColors.death;
    default:
      return colors.muted;
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
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = seconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
