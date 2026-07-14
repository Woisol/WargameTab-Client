import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/career_stats.dart';
import '../models/wargame_session.dart';
import '../theme/app_theme.dart';
import '../widgets/career_donut_panel.dart';
import '../widgets/match_record_card.dart';
import '../widgets/match_score_panel.dart';
import 'history_screen.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.sessions,
    required this.onDeleteSession,
  });

  final List<WargameSession> sessions;
  final Future<List<WargameSession>> Function(WargameSession session)
  onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final orderedSessions = [...sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final latest = orderedSessions.isEmpty ? null : orderedSessions.first;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverToBoxAdapter(
                child: _Header(count: sessions.length),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: CareerDonutPanel(
                  stats: CareerStats.fromSessions(sessions),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: latest == null
                    ? const _EmptyPanel()
                    : _LatestMatchPanel(
                        latest,
                        onOpenDetail: () => _openDetail(context, latest),
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              sliver: SliverToBoxAdapter(
                child: _HistoryPreviewPanel(
                  sessions: orderedSessions,
                  onOpenDetail: (session) => _openDetail(context, session),
                  onShowMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(
                          sessions: orderedSessions,
                          onDeleteSession: onDeleteSession,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, WargameSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchDetailScreen(
          session: session,
          onDeleteSession: onDeleteSession,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: Text(
        l10n.emptySessions,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          // Expanded(
          // child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wargame Tab',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.homeLoadedSessions(count),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          // ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   decoration: BoxDecoration(
          //     color: colors.surfaceHigh,
          //     borderRadius: BorderRadius.circular(999),
          //     border: Border.all(color: colors.line),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Container(
          //         width: 8,
          //         height: 8,
          //         decoration: const BoxDecoration(
          //           color: AppColors.death,
          //           shape: BoxShape.circle,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       Text(
          //         'MOCK',
          //         style: Theme.of(
          //           context,
          //         ).textTheme.labelLarge?.copyWith(color: AppColors.death),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _LatestMatchPanel extends StatelessWidget {
  const _LatestMatchPanel(this.session, {required this.onOpenDetail});

  final WargameSession session;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.latestMatch, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onOpenDetail,
              child: MatchScorePanel(session: session),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(icon: Icons.schedule_rounded, text: session.startLabel),
              const SizedBox(width: 10),
              _InfoChip(icon: Icons.timer_rounded, text: session.durationLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryPreviewPanel extends StatelessWidget {
  const _HistoryPreviewPanel({
    required this.sessions,
    required this.onOpenDetail,
    required this.onShowMore,
  });

  final List<WargameSession> sessions;
  final ValueChanged<WargameSession> onOpenDetail;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    final previewSessions = sessions.take(4).toList();
    final sessionWidges = [
      _SectionTitle(l10n.history),
      const SizedBox(height: 12),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: previewSessions.length,
        itemBuilder: (context, index) {
          final session = previewSessions[index];
          return MatchRecordCard(
            session: session,
            dense: false,
            index: index,
            onTap: () => onOpenDetail(session),
          );
        },
      ),
    ];
    if (sessions.length > 4) {
      sessionWidges.addAll([
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onShowMore,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(l10n.showMore),
          ),
        ),
      ]);
    }
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sessionWidges,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}
