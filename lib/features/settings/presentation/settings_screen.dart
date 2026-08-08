import 'package:flutter/material.dart';
import '../../history/data/history_repository.dart';
import '../../fixtures/data/cached_fixtures_repository.dart';
import '../../fixtures/data/fixtures_repository_factory.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _history = HistoryRepository();
  late final CachedFixturesRepository? _cache;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    final repo = createFixturesRepository();
    _cache = repo is CachedFixturesRepository ? repo : null;
  }

  Future<void> _clearFixtureCache() async {
    await _cache?.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fixture cache cleared.')),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This removes History only. Saved Picks will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _history.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History cleared.')),
      );
    }
  }

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _Tile(
            title: 'Language',
            subtitle: _language,
            trailing: DropdownButton<String>(
              value: _language,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Русский', child: Text('Русский')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _language = value);
              },
            ),
          ),
          const SizedBox(height: 10),
          const _Tile(
            title: 'About KickLuck',
            subtitle: 'Football entertainment randomizer',
            trailing: Icon(Icons.info_outline),
          ),
          const SizedBox(height: 10),
          const _Tile(
            title: 'Privacy',
            subtitle: 'Local Saved Picks and History in MVP',
            trailing: Icon(Icons.privacy_tip_outlined),
          ),
          const SizedBox(height: 10),
          _Tile(
            title: 'Clear History',
            subtitle: 'Saved Picks are not deleted',
            trailing: IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
          ),
          const SizedBox(height: 10),
          _Tile(
            title: 'Clear Fixture Cache',
            subtitle: 'Forces fresh football data next time',
            trailing: IconButton(
              onPressed: _clearFixtureCache,
              icon: const Icon(Icons.cached_outlined),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'KickLuck v0.9.0',
            style: TextStyle(color: Colors.white.withValues(alpha: .5)),
          ),
        ],
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
        color: const Color(0xFF111A16),
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
                    color: Colors.white.withValues(alpha: .6),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
