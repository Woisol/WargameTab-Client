import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/sync_message_localizer.dart';
import '../sync/watch_sync_models.dart';
import '../sync/watch_sync_service.dart';
import '../theme/app_theme.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.syncService});

  final WatchSyncService syncService;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  @override
  void initState() {
    super.initState();
    widget.syncService.addListener(_handleSyncChanged);
  }

  @override
  void didUpdateWidget(covariant DeviceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.syncService != widget.syncService) {
      oldWidget.syncService.removeListener(_handleSyncChanged);
      widget.syncService.addListener(_handleSyncChanged);
    }
  }

  @override
  void dispose() {
    widget.syncService.removeListener(_handleSyncChanged);
    super.dispose();
  }

  void _handleSyncChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    final state = widget.syncService.state;
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(l10n.device, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            l10n.deviceDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _ChannelPanel(
            state: state,
            onToggleChannel: state.channelReady
                ? widget.syncService.disconnect
                : widget.syncService.start,
          ),
          const SizedBox(height: 14),
          _ChannelStatusCard(state: state),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.panelDecoration(
              context,
              color: colors.surfaceHigh,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.syncSummary, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                _SyncRow(
                  label: l10n.lastSync,
                  value: _lastSyncLabel(l10n, state.lastSyncAt),
                ),
                _SyncRow(
                  label: l10n.writtenMatches,
                  value: l10n.importedMatches(state.lastImportedCount),
                ),
                _SyncRow(
                  label: l10n.channelStatus,
                  value: state.channelReady
                      ? l10n.waitingWatch
                      : l10n.channelNotEnabled,
                ),
                if (state.diagnosticMessage != null)
                  _SyncRow(
                    label: l10n.diagnosticChannel,
                    value: localizedSyncMessage(l10n, state.diagnosticMessage!),
                  ),
                if (state.errorMessage != null)
                  _SyncRow(
                    label: l10n.status,
                    value: localizedSyncMessage(l10n, state.errorMessage!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelPanel extends StatelessWidget {
  const _ChannelPanel({required this.state, required this.onToggleChannel});

  final WatchSyncState state;
  final VoidCallback onToggleChannel;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    final busy = state.syncing;
    final ready = state.channelReady;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context, color: colors.surfaceHigh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (ready ? AppColors.kill : colors.background).withAlpha(
                    ready ? 41 : 255,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ready ? AppColors.kill : colors.line,
                  ),
                ),
                child: Icon(
                  ready ? Icons.hub_rounded : Icons.hub_outlined,
                  color: ready ? AppColors.kill : colors.muted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ready ? l10n.channelEnabled : l10n.pairingChannel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.syncing
                          ? l10n.writingWatchData
                          : ready
                          ? l10n.waitingWatch
                          : l10n.deviceDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : onToggleChannel,
                  icon: Icon(
                    ready ? Icons.link_off_rounded : Icons.link_rounded,
                  ),
                  label: Text(
                    ready ? l10n.disableChannel : l10n.enableChannel,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelStatusCard extends StatelessWidget {
  const _ChannelStatusCard({required this.state});

  final WatchSyncState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    final ready = state.channelReady;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 44,
            decoration: BoxDecoration(
              color: ready ? AppColors.kill : AppColors.death,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.diagnosticChannel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  state.diagnosticMessage ??
                      (ready ? l10n.channelRunning : l10n.waitingWatch),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            ready ? Icons.link_rounded : Icons.link_off_rounded,
            color: colors.muted,
          ),
        ],
      ),
    );
  }
}

String _lastSyncLabel(AppLocalizations l10n, DateTime? value) {
  if (value == null) {
    return l10n.neverSynced;
  }

  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return l10n.todayAt('$hour:$minute');
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
