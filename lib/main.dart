import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/client_settings_repository.dart';
import 'data/key_value_store.dart';
import 'data/mock_sessions.dart';
import 'data/session_repository.dart';
import 'models/wargame_session.dart';
import 'screens/device_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'sync/android_interconnect_channel.dart';
import 'sync/mock_watch_sync_channel.dart';
import 'sync/watch_sync_channel.dart';
import 'sync/watch_sync_logger.dart';
import 'sync/watch_sync_service.dart';
import 'theme/app_theme.dart';

const _watchSyncChannelMode = String.fromEnvironment(
  'WARGAME_SYNC_CHANNEL',
  defaultValue: 'auto',
);

List<WargameSession> seedSessionsForChannelMode(
  String mode, {
  required bool isDebug,
}) {
  final useMockData = mode == 'mock' || (mode == 'auto' && isDebug);
  return useMockData ? mockFinishedSessions : const [];
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final store = SharedPreferencesKeyValueStore(preferences);

  runApp(
      WargameClientApp(
        sessionRepository: SessionRepository(
          store: store,
          seedSessions: seedSessionsForChannelMode(
            _watchSyncChannelMode,
            isDebug: kDebugMode,
          ),
        ),
      settingsRepository: ClientSettingsRepository(store: store),
      watchSyncChannel: _createWatchSyncChannel(),
    ),
  );
}

WatchSyncChannel _createWatchSyncChannel() {
  if (_watchSyncChannelMode == 'mock') {
    return MockWatchSyncChannel();
  }

  if (_watchSyncChannelMode == 'android' || !kDebugMode) {
    return AndroidInterconnectChannel();
  }

  return MockWatchSyncChannel();
}

class WargameClientApp extends StatefulWidget {
  const WargameClientApp({
    super.key,
    this.sessionRepository,
    this.settingsRepository,
    this.watchSyncChannel,
  });

  final SessionRepository? sessionRepository;
  final ClientSettingsRepository? settingsRepository;
  final WatchSyncChannel? watchSyncChannel;

  @override
  State<WargameClientApp> createState() => _WargameClientAppState();
}

class _WargameClientAppState extends State<WargameClientApp> {
  late final KeyValueStore _fallbackStore;
  late final SessionRepository _sessionRepository;
  late final ClientSettingsRepository _settingsRepository;
  late final WatchSyncLogger _watchSyncLogger;
  late final WatchSyncService _watchSyncService;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _interconnectDebugEnabled = false;
  int _currentIndex = 0;
  List<WargameSession> _sessions = const [];
  bool _loaded = false;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _fallbackStore = MemoryKeyValueStore();
    _sessionRepository =
        widget.sessionRepository ??
        SessionRepository(
          store: _fallbackStore,
          seedSessions: seedSessionsForChannelMode(
            _watchSyncChannelMode,
            isDebug: kDebugMode,
          ),
        );
    _settingsRepository =
        widget.settingsRepository ??
        ClientSettingsRepository(store: _fallbackStore);
    _watchSyncLogger = WatchSyncLogger(
      onToast: (message) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
    _watchSyncService = WatchSyncService(
      channel: widget.watchSyncChannel ?? _createWatchSyncChannel(),
      logger: _watchSyncLogger,
      sessionRepository: _sessionRepository,
      onSessionsChanged: _setSessions,
    );
    unawaited(_watchSyncService.start());
    _loadInitialState();
    _loadInterconnectDebugSetting();
  }

  Future<void> _loadInitialState() async {
    final themeMode = await _settingsRepository.loadThemeMode();
    final sessions = await _sessionRepository.loadSessions();
    if (!mounted) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
      _sessions = sessions;
      _loaded = true;
    });
  }

  Future<void> _loadInterconnectDebugSetting() async {
    final enabled = await _settingsRepository.loadInterconnectDebugEnabled();
    if (!mounted) {
      return;
    }

    setState(() {
      _interconnectDebugEnabled = enabled;
    });
    _watchSyncLogger.setDebug(enabled);
  }

  @override
  void dispose() {
    _watchSyncService.dispose();
    super.dispose();
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    _settingsRepository.saveThemeMode(mode);
  }

  void _setInterconnectDebugEnabled(bool enabled) {
    setState(() {
      _interconnectDebugEnabled = enabled;
    });
    _watchSyncLogger.setDebug(enabled);
    _settingsRepository.saveInterconnectDebugEnabled(enabled);
  }

  void _setSessions(List<WargameSession> sessions) {
    setState(() {
      _sessions = sessions;
    });
  }

  Future<List<WargameSession>> _deleteSession(WargameSession session) async {
    final sessions = await _sessionRepository.deleteSession(session.sessionId);
    if (mounted) {
      _setSessions(sessions);
    }

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wargame Tab',
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: Scaffold(
        body: _loaded
            ? IndexedStack(
                index: _currentIndex,
                children: [
                  HomeScreen(
                    sessions: _sessions,
                    onDeleteSession: _deleteSession,
                  ),
                  DeviceScreen(syncService: _watchSyncService),
                  SettingsScreen(
                    themeMode: _themeMode,
                    onThemeModeChanged: _setThemeMode,
                    interconnectDebugEnabled: _interconnectDebugEnabled,
                    onInterconnectDebugChanged: _setInterconnectDebugEnabled,
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(Icons.watch_outlined),
              selectedIcon: Icon(Icons.watch_rounded),
              label: '设备',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
