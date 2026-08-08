import 'package:flutter/material.dart';
import '../../generator/domain/generation_mode.dart';
import '../data/saved_repository.dart';
import '../domain/saved_combination.dart';
import 'saved_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _repo = SavedRepository();
  late Future<List<SavedCombination>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _repo.getAll();
  }

  Future<void> _delete(String id) async {
    await _repo.delete(id);
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Picks',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<SavedCombination>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return const Center(
              child: Text('No saved combinations yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111A16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.picks.length} matches',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...item.picks.take(3).map(
                          (pick) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${pick.fixture.home.shortName}-${pick.fixture.away.shortName} · ${pick.mode.label}: ${pick.outcome}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .72),
                              ),
                            ),
                          ),
                        ),
                    if (item.picks.length > 3)
                      Text(
                        '+${item.picks.length - 3} more',
                        style: const TextStyle(color: Color(0xFF25F36A)),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SavedDetailScreen(item: item),
                              ),
                            );
                            if (mounted) setState(_reload);
                          },
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('View'),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _delete(item.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
