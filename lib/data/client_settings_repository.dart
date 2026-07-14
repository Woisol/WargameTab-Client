import 'package:flutter/material.dart';

import 'key_value_store.dart';

enum ClientLocaleMode { system, zh, en }

class ClientSettingsRepository {
  const ClientSettingsRepository({required this.store});

  static const themeModeKey = 'wargame_client_theme_mode';
  static const localeModeKey = 'wargame_client_locale_mode';
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

  Future<ClientLocaleMode> loadLocaleMode() async {
    final value = await store.getString(localeModeKey);
    return switch (value) {
      'zh' => ClientLocaleMode.zh,
      'en' => ClientLocaleMode.en,
      _ => ClientLocaleMode.system,
    };
  }

  Future<void> saveLocaleMode(ClientLocaleMode mode) async {
    await store.setString(localeModeKey, mode.name);
  }

  Future<bool> loadInterconnectDebugEnabled() async {
    return await store.getString(interconnectDebugEnabledKey) == 'true';
  }

  Future<void> saveInterconnectDebugEnabled(bool enabled) async {
    await store.setString(interconnectDebugEnabledKey, enabled.toString());
  }
}
