import 'package:flutter/material.dart';

import 'data/mock_sessions.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WargameClientApp());
}

class WargameClientApp extends StatefulWidget {
  const WargameClientApp({super.key});

  @override
  State<WargameClientApp> createState() => _WargameClientAppState();
}

class _WargameClientAppState extends State<WargameClientApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  int _currentIndex = 0;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wargame Tab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(sessions: mockFinishedSessions),
            SettingsScreen(
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
            ),
          ],
        ),
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
