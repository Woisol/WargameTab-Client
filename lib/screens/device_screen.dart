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
            '蓝牙同步入口，当前使用 mock transport。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _ConnectionPanel(
            state: state,
            onToggleConnection: state.connected
                ? widget.syncService.disconnect
                : widget.syncService.scanAndConnect,
            onSyncNow: widget.syncService.syncNow,
          ),
          const SizedBox(height: 14),
          _WatchCard(state: state),
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
                _SyncRow(label: '数据源', value: state.device?.name ?? '未连接'),
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

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({
    required this.state,
    required this.onToggleConnection,
    required this.onSyncNow,
  });

  final WatchSyncState state;
  final VoidCallback onToggleConnection;
  final VoidCallback onSyncNow;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final busy = state.scanning || state.syncing;
    final connected = state.connected;
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
                  color: (connected ? AppColors.death : colors.background)
                      .withAlpha(connected ? 41 : 255),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: connected ? AppColors.death : colors.line,
                  ),
                ),
                child: Icon(
                  connected
                      ? Icons.watch_rounded
                      : Icons.watch_off_outlined,
                  color: connected ? AppColors.death : colors.muted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connected
                          ? '${state.device?.name ?? 'Wargame Watch'} 已连接'
                          : '未连接手表',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      connected
                          ? '信号 ${state.device?.rssi ?? 0} dBm · 电量 ${state.device?.batteryPercent ?? 0}%'
                          : state.scanning
                              ? '正在扫描附近的手表应用'
                              : '扫描附近的手表应用',
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
                  onPressed: busy ? null : onToggleConnection,
                  icon: Icon(
                    connected
                        ? Icons.bluetooth_disabled_rounded
                        : Icons.bluetooth_searching_rounded,
                  ),
                  label: Text(
                    connected
                        ? '断开连接'
                        : state.scanning
                            ? '扫描中'
                            : '扫描连接',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 54,
                height: 52,
                child: IconButton.filledTonal(
                  onPressed: connected && !busy ? onSyncNow : null,
                  icon: state.syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatchCard extends StatelessWidget {
  const _WatchCard({required this.state});

  final WatchSyncState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final connected = state.connected;
    final device = state.device;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.panelDecoration(context),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 44,
            decoration: BoxDecoration(
              color: connected ? AppColors.kill : AppColors.death,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device?.name ?? 'Wargame Tab Watch',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  connected
                      ? '已配对 · 可手动同步'
                      : device == null
                          ? '尚未扫描 · 点击上方连接'
                          : '最近发现 · 点击上方连接',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            connected ? Icons.link_rounded : Icons.bluetooth_rounded,
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
