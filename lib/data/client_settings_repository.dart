import 'package:flutter/material.dart';

import 'key_value_store.dart';

class ClientSettingsRepository {
  const ClientSettingsRepository({required this.store});

  static const themeModeKey = 'wargame_client_theme_mode';
  static const interconnectDebugEnabledKey =
      'wargame_client_interconnect_debug';

  final KeyValueStore store;

  Future<ThemeMode> loadThemeMode() async {
    final value = await store.getString(themeModeKey);
    if (value == 'light') {
      return ThemeMode.light;
    }
    if (value == 'system') {
      return ThemeMode.system;
    }
    return ThemeMode.dark;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await store.setString(themeModeKey, mode.name);
  }

  Future<bool> loadInterconnectDebugEnabled() async {
    return await store.getString(interconnectDebugEnabledKey) == 'true';
  }

  Future<void> saveInterconnectDebugEnabled(bool enabled) async {
    await store.setString(interconnectDebugEnabledKey, enabled.toString());
  }
}
