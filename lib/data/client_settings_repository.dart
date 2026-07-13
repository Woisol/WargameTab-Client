import 'package:flutter/material.dart';

import 'key_value_store.dart';

class ClientSettingsRepository {
  const ClientSettingsRepository({required this.store});

  static const themeModeKey = 'wargame_client_theme_mode';

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
}
