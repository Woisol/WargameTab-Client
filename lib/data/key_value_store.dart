import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

class SharedPreferencesKeyValueStore implements KeyValueStore {
  const SharedPreferencesKeyValueStore(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<String?> getString(String key) async {
    return preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await preferences.setString(key, value);
  }
}

class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> getString(String key) async {
    return _values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }
}
