import 'package:flutter/material.dart';

import '../data/client_settings_repository.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.localeMode,
    required this.onLocaleModeChanged,
    required this.interconnectDebugEnabled,
    required this.onInterconnectDebugChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ClientLocaleMode localeMode;
  final ValueChanged<ClientLocaleMode> onLocaleModeChanged;
  final bool interconnectDebugEnabled;
  final ValueChanged<bool> onInterconnectDebugChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.wargameColors;
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Text(l10n.settings, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            l10n.settingsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
                Text(
                  l10n.themeAppearance,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.themeDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text(l10n.darkTheme),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text(l10n.lightTheme),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text(l10n.systemTheme),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    onThemeModeChanged(selection.first);
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ClientLocaleMode>(
                  value: localeMode,
                  decoration: InputDecoration(
                    labelText: l10n.language,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ClientLocaleMode.system,
                      child: Text(l10n.followSystem),
                    ),
                    DropdownMenuItem(
                      value: ClientLocaleMode.zh,
                      child: Text(l10n.chinese),
                    ),
                    DropdownMenuItem(
                      value: ClientLocaleMode.en,
                      child: Text(l10n.english),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onLocaleModeChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.interconnectDebug),
                    subtitle: Text(l10n.interconnectDebugDescription),
                    value: interconnectDebugEnabled,
                    onChanged: onInterconnectDebugChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
