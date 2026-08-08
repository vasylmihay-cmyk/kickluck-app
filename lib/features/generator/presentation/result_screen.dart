import 'package:flutter/material.dart';
import '../domain/generation_mode.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/history_entry.dart';
import '../../saved/data/saved_repository.dart';
import '../../saved/domain/saved_combination.dart';
import '../../../shared/id.dart';
import '../../share/presentation/share_card_screen.dart';
import '../domain/generated_pick.dart';
import '../domain/generation_session.dart';
import '../domain/random_engine.dart';

class ResultScreen extends StatefulWidget {
  final GenerationSession session;

  const ResultScreen({
    super.key,
    required this.session,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _engine = RandomEngine();
  final _saved = SavedRepository();
  final _history = HistoryRepository();

  late GenerationSession _session;
  bool _savedOnce = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  void _toggleLock(String fixtureId) {
    setState(() {
      final next = _session.picks.map((pick) {
        if (pick.fixture.id != fixtureId) return pick;
        return pick.copyWith(isLocked: !pick.isLocked);
      }).toList();
      _session = _session.copyWith(picks: next);
    });
  }

  Future<void> _regenerate() async {
    final existing = {
      for (final p in _session.picks) p.fixture.id: p,
    };
    final next = _engine.generateSession(
      fixtures: _session.fixtures,
      mode: _session.requestedMode,
      existing: existing,
    );
    setState(() {
      _session = _session.copyWith(picks: next);
      _savedOnce = false;
    });

    await _history.add(HistoryEntry(
      id: makeId('hist'),
      timestamp: DateTime.now(),
      action: HistoryActionType.regenerated,
      matchCount: next.length,
      modeLabel: _session.requestedMode.label,
    ));
  }

  Future<void> _save() async {
    final item = SavedCombination(
      id: makeId('saved'),
      createdAt: DateTime.now(),
      picks: _session.picks,
    );
    await _saved.save(item);
    await _history.add(HistoryEntry(
      id: makeId('hist'),
      timestamp: DateTime.now(),
      action: HistoryActionType.saved,
      matchCount: _session.picks.length,
      modeLabel: _session.requestedMode.label,
    ));
    if (!mounted) return;
    setState(() => _savedOnce = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to Saved Picks.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allLocked =
        _session.picks.isNotEmpty && _session.picks.every((p) => p.isLocked);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generated',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Text(
              '${_session.picks.length} matches',
              style: TextStyle(color: Colors.white.withValues(alpha: .6)),
            ),
            const SizedBox(height: 14),
            ..._session.picks.map((pick) => _PickCard(
                  pick: pick,
                  onLock: () => _toggleLock(pick.fixture.id),
                )),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: allLocked ? null : _regenerate,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('GENERATE AGAIN'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFF25F36A),
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            if (allLocked) ...[
              const SizedBox(height: 8),
              Text(
                'Unlock at least one pick to regenerate.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: .6)),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _save,
              icon: Icon(_savedOnce ? Icons.bookmark : Icons.bookmark_outline),
              label: Text(_savedOnce ? 'SAVED' : 'SAVE'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareCardScreen(
                    title: 'My Random Football Picks',
                    picks: _session.picks,
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
      ),
    );
  }
}

class _PickCard extends StatelessWidget {
  final GeneratedPick pick;
  final VoidCallback onLock;

  const _PickCard({
    required this.pick,
    required this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111A16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: pick.isLocked
                ? const Color(0xFF25F36A)
                : Colors.white.withValues(alpha: .06),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pick.fixture.home.name} vs ${pick.fixture.away.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
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
            IconButton(
              onPressed: onLock,
              icon: Icon(
                pick.isLocked ? Icons.lock : Icons.lock_open,
                color: pick.isLocked
                    ? const Color(0xFF25F36A)
                    : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
