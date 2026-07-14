import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.interconnectDebugEnabled,
    required this.onInterconnectDebugChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool interconnectDebugEnabled;
  final ValueChanged<bool> onInterconnectDebugChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text('设置', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('先把界面风格确定下来', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.panelDecoration(
              context,
              color: colors.surfaceHigh,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('主题外观', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  '默认深色，可切换为浅色或跟随系统。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('深色'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('浅色'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('跟随系统'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    onThemeModeChanged(selection.first);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('互联调试'),
                  subtitle: const Text('写入 logcat，并在标记为 Toast 的节点显示提示。'),
                  value: interconnectDebugEnabled,
                  onChanged: onInterconnectDebugChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
