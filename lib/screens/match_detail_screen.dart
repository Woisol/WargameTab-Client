import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/wargame_session.dart';
import '../theme/app_theme.dart';
import '../widgets/match_score_panel.dart';
import '../widgets/timeline_chart.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({
    super.key,
    required this.session,
    required this.onDeleteSession,
  });

  final WargameSession session;
  final Future<List<WargameSession>> Function(WargameSession session)
  onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchReview(session.dateLabel)),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.moreActions,
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 10),
                    Text(l10n.delete),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Hero(
              tag: session.heroTag,
              child: Material(
                color: Colors.transparent,
                child: MatchScorePanel(session: session, large: true),
              ),
            ),
            const SizedBox(height: 14),
            _TimePanel(session: session),
            const SizedBox(height: 14),
            _TimelinePanel(session: session),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteMatch),
        content: Text(AppLocalizations.of(context).confirmDeleteMatch),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await onDeleteSession(session);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).deleteFailed)),
        );
      }
    }
  }
}

class _TimePanel extends StatelessWidget {
  const _TimePanel({required this.session});

  final WargameSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.matchTime, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(
            session.timeRangeLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.durationDetail(
              session.duration.inMinutes,
              session.duration.inSeconds.remainder(60),
            ),
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
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 210,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: AppTheme.panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.timeline, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          Expanded(child: TimelineChart(session: session)),
        ],
      ),
    );
  }
}
