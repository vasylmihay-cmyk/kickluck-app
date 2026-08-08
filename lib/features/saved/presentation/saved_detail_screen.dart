import 'package:flutter/material.dart';
import '../../generator/domain/generation_mode.dart';
import '../../generator/domain/generation_session.dart';
import '../../generator/domain/random_engine.dart';
import '../../generator/presentation/result_screen.dart';
import '../../share/presentation/share_card_screen.dart';
import '../domain/saved_combination.dart';

class SavedDetailScreen extends StatelessWidget {
  final SavedCombination item;

  const SavedDetailScreen({
    super.key,
    required this.item,
  });

  Future<void> _regenerate(BuildContext context) async {
    if (item.picks.isEmpty) return;
    final engine = RandomEngine();
    final fixtures = item.picks.map((e) => e.fixture).toList();

    final mode = item.picks
            .map((e) => e.mode)
            .toSet()
            .length ==
        1
        ? item.picks.first.mode
        : GenerationMode.randomMix;

    final picks = engine.generateSession(
      fixtures: fixtures,
      mode: mode,
      existing: const {},
    );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          session: GenerationSession(
            id: 'regen_${DateTime.now().microsecondsSinceEpoch}',
            createdAt: DateTime.now(),
            requestedMode: mode,
            fixtures: fixtures,
            picks: picks,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Pick',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            '${item.picks.length} matches',
            style: TextStyle(color: Colors.white.withValues(alpha: .6)),
          ),
          const SizedBox(height: 12),
          ...item.picks.map(
            (pick) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111A16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pick.fixture.home.name} vs ${pick.fixture.away.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pick.mode.label}: ${pick.outcome}',
                    style: const TextStyle(
                      color: Color(0xFF25F36A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _regenerate(context),
            icon: const Icon(Icons.casino_outlined),
            label: const Text('REGENERATE'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: const Color(0xFF25F36A),
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShareCardScreen(
                  title: 'My Random Football Picks',
                  picks: item.picks,
                ),
              ),
            ),
            icon: const Icon(Icons.share_outlined),
            label: const Text('SHARE'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}
