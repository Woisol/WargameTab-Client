import 'package:flutter/material.dart';

import '../models/wargame_session.dart';
import '../theme/app_theme.dart';
import '../widgets/match_record_card.dart';
import 'match_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.sessions,
    required this.onDeleteSession,
  });

  final List<WargameSession> sessions;
  final Future<List<WargameSession>> Function(WargameSession session)
  onDeleteSession;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<WargameSession> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = [...widget.sessions];
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessions != widget.sessions) {
      _sessions = [...widget.sessions];
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedSessions = [..._sessions]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部对局'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${orderedSessions.length} 场',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.death),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          itemCount: orderedSessions.length,
          itemBuilder: (context, index) {
            return MatchRecordCard(
              session: orderedSessions[index],
              index: index,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MatchDetailScreen(
                      session: orderedSessions[index],
                      onDeleteSession: _deleteSession,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<WargameSession>> _deleteSession(WargameSession session) async {
    final remaining = await widget.onDeleteSession(session);
    if (mounted) {
      setState(() {
        _sessions = [...remaining];
      });
    }
    return remaining;
  }
}
