import 'package:flutter/material.dart';
import '../../fixtures/data/cached_fixtures_repository.dart';
import '../../fixtures/data/fixtures_repository_factory.dart';
import '../../history/data/history_repository.dart';
import '../../saved/data/saved_repository.dart';
import '../data/app_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _history = HistoryRepository();
  final _saved = SavedRepository();
  final _preferences = AppPreferences.instance;
  late final CachedFixturesRepository? _cache;

  @override
  void initState() {
    super.initState();
    final repo = createFixturesRepository();
    _cache = repo is CachedFixturesRepository ? repo : null;
    _preferences.load();
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    String action = 'Clear',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _clearFixtureCache() async {
    await _cache?.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fixture cache cleared.')),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await _confirm(
      title: 'Clear history?',
      message: 'This removes History only. Saved Picks will remain.',
    );
    if (!confirmed) return;
    await _history.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History cleared.')),
    );
  }

  Future<void> _clearSaved() async {
    final confirmed = await _confirm(
      title: 'Clear Saved Picks?',
      message: 'All saved combinations will be removed. This cannot be undone.',
    );
    if (!confirmed) return;
    await _saved.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved Picks cleared.')),
    );
  }

  void _showInfo(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: _preferences,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            const _SectionTitle('Preferences'),
            _Tile(
              title: 'Theme',
              subtitle: _themeLabel(_preferences.themeMode),
              trailing: DropdownButton<ThemeMode>(
                value: _preferences.themeMode,
                underline: const SizedBox.shrink(),
                items: ThemeMode.values
                    .map(
                      (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(_themeLabel(mode)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) _preferences.setThemeMode(value);
                },
              ),
            ),
            const SizedBox(height: 10),
            _Tile(
              title: 'Language',
              subtitle: _preferences.language,
              trailing: DropdownButton<String>(
                value: _preferences.language,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'Русский', child: Text('Русский')),
                ],
                onChanged: (value) {
                  if (value != null) _preferences.setLanguage(value);
                },
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Data'),
            _ActionTile(
              title: 'Clear History',
              subtitle: 'Saved Picks are not deleted',
              icon: Icons.delete_sweep_outlined,
              onTap: _clearHistory,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              title: 'Clear Saved Picks',
              subtitle: 'Remove all saved combinations',
              icon: Icons.bookmark_remove_outlined,
              onTap: _clearSaved,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              title: 'Clear Fixture Cache',
              subtitle: 'Forces fresh football data next time',
              icon: Icons.cached_outlined,
              onTap: _clearFixtureCache,
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Legal & safety'),
            _ActionTile(
              title: 'Responsible use',
              subtitle: 'Entertainment only — not betting advice',
              icon: Icons.shield_outlined,
              onTap: () => _showInfo(
                'Responsible use',
                'KickLuck is an entertainment randomizer. It does not predict match outcomes, guarantee results, or provide betting or financial advice. Never risk money you cannot afford to lose, and follow the laws and age restrictions where you live.',
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              title: 'Privacy Policy',
              subtitle: 'How KickLuck handles app data',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _showInfo(
                'Privacy Policy',
                'KickLuck stores Saved Picks, History, preferences and fixture cache locally on your device in this version. Football fixture data is requested from the configured football data provider. KickLuck does not require an account for the MVP.',
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              title: 'Terms of Use',
              subtitle: 'Rules for using KickLuck',
              icon: Icons.description_outlined,
              onTap: () => _showInfo(
                'Terms of Use',
                'KickLuck is provided for entertainment. Random picks may be inaccurate, incomplete or unsuitable for any decision involving money. By using the app, you remain responsible for your own decisions and for complying with applicable laws.',
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Support'),
            _ActionTile(
              title: 'About KickLuck',
              subtitle: 'Football entertainment randomizer',
              icon: Icons.info_outline,
              onTap: () => _showInfo(
                'About KickLuck',
                'KickLuck turns real football fixtures into random football scenarios. Choose matches, choose a mode, generate a combination, save it or share it — no prediction claims, just football and luck.',
              ),
            ),
            const SizedBox(height: 10),
            _ActionTile(
              title: 'Contact / Feedback',
              subtitle: 'Feedback details for the first public release',
              icon: Icons.feedback_outlined,
              onTap: () => _showInfo(
                'Contact / Feedback',
                'For the first public release, the official support contact will be listed on the KickLuck Google Play page. Until then, use the project feedback channel used for testing.',
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'KickLuck v0.9.1 (10)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _Tile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
