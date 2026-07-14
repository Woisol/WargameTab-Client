import 'package:client/data/client_settings_repository.dart';
import 'package:client/data/key_value_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ClientSettingsRepository defaults to dark theme', () async {
    final repository = ClientSettingsRepository(store: MemoryKeyValueStore());

    expect(await repository.loadThemeMode(), ThemeMode.dark);
  });

  test('ClientSettingsRepository persists theme mode', () async {
    final store = MemoryKeyValueStore();
    final repository = ClientSettingsRepository(store: store);

    await repository.saveThemeMode(ThemeMode.system);

    expect(await repository.loadThemeMode(), ThemeMode.system);
    expect(await store.getString(ClientSettingsRepository.themeModeKey), 'system');
  });

  test('ClientSettingsRepository falls back to dark for invalid values', () async {
    final store = MemoryKeyValueStore();
    await store.setString(ClientSettingsRepository.themeModeKey, 'invalid');

    final repository = ClientSettingsRepository(store: store);

    expect(await repository.loadThemeMode(), ThemeMode.dark);
  });

  test('ClientSettingsRepository persists interconnect debug setting', () async {
    final store = MemoryKeyValueStore();
    final repository = ClientSettingsRepository(store: store);

    expect(await repository.loadInterconnectDebugEnabled(), isFalse);
    await repository.saveInterconnectDebugEnabled(true);

    expect(await repository.loadInterconnectDebugEnabled(), isTrue);
  });

  test('ClientSettingsRepository defaults to system locale', () async {
    final repository = ClientSettingsRepository(store: MemoryKeyValueStore());

    expect(await repository.loadLocaleMode(), ClientLocaleMode.system);
  });

  test('ClientSettingsRepository persists locale modes', () async {
    final store = MemoryKeyValueStore();
    final repository = ClientSettingsRepository(store: store);

    for (final mode in ClientLocaleMode.values) {
      await repository.saveLocaleMode(mode);
      expect(await repository.loadLocaleMode(), mode);
    }
  });

  test('ClientSettingsRepository falls back to system for invalid locale', () async {
    final store = MemoryKeyValueStore();
    await store.setString(ClientSettingsRepository.localeModeKey, 'invalid');

    final repository = ClientSettingsRepository(store: store);

    expect(await repository.loadLocaleMode(), ClientLocaleMode.system);
  });
}
