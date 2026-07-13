import 'package:flutter/material.dart';

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
    final state = widget.syncService.state;
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('设备', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            '配对通道用于接收手表自动发送的已完成对局。',
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
                Text('同步摘要', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                _SyncRow(
                  label: '最近同步',
                  value: _lastSyncLabel(state.lastSyncAt),
                ),
                _SyncRow(label: '本次写入', value: '${state.lastImportedCount} 场'),
                _SyncRow(
                  label: '通道状态',
                  value: state.channelReady ? '等待手表发送' : '尚未启用',
                ),
                if (state.diagnosticMessage != null)
                  _SyncRow(label: '诊断通道', value: state.diagnosticMessage!),
                if (state.errorMessage != null)
                  _SyncRow(label: '状态', value: state.errorMessage!),
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
                      ready ? '通道已启用' : '配对通道',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.syncing
                          ? '正在写入手表发送的数据'
                          : ready
                          ? '等待手表发送'
                          : '启用后接收已配对手表的数据',
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
                  label: Text(ready ? '停用通道' : '启用通道'),
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
                Text('诊断通道', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  state.diagnosticMessage ?? (ready ? '配对通道运行中' : '等待手表发送'),
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

String _lastSyncLabel(DateTime? value) {
  if (value == null) {
    return '从未同步';
  }

  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '今天 $hour:$minute';
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
