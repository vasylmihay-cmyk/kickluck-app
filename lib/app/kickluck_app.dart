import 'package:flutter/material.dart';
import '../features/generator/presentation/home_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/saved/presentation/saved_screen.dart';
import '../features/settings/data/app_preferences.dart';
import '../features/settings/presentation/settings_screen.dart';

class KickLuckApp extends StatefulWidget {
  const KickLuckApp({super.key});

  @override
  State<KickLuckApp> createState() => _KickLuckAppState();
}

class _KickLuckAppState extends State<KickLuckApp> {
  final _preferences = AppPreferences.instance;

  @override
  void initState() {
    super.initState();
    _preferences.load();
  }

  ThemeData _theme(Brightness brightness) {
    const green = Color(0xFF25F36A);
    final dark = brightness == Brightness.dark;
    final background = dark ? const Color(0xFF07100C) : const Color(0xFFF3F7F4);
    final surface = dark ? const Color(0xFF111A16) : Colors.white;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: green,
        brightness: brightness,
        primary: green,
        surface: surface,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: green.withValues(alpha: .18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _preferences,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KickLuck',
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: _preferences.themeMode,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    SavedScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
