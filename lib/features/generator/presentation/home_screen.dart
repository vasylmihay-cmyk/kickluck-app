import 'package:flutter/material.dart';
import '../../fixtures/data/fixtures_repository_factory.dart';
import '../../fixtures/domain/fixture.dart';
import '../../fixtures/domain/fixtures_repository.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/history_entry.dart';
import '../../../shared/id.dart';
import '../domain/generation_mode.dart';
import '../domain/generation_session.dart';
import '../domain/random_engine.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FixturesRepository _fixturesRepository;
  final _engine = RandomEngine();
  final _history = HistoryRepository();

  DateTime _selectedDate = DateTime.now();
  String? _leagueId;
  List<Fixture> _fixtures = const [];
  final Set<String> _selectedIds = {};
  GenerationMode _mode = GenerationMode.oneXTwo;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fixturesRepository = createFixturesRepository();
    _loadFixtures();
  }

  List<Fixture> get _selectedFixtures =>
      _fixtures.where((f) => _selectedIds.contains(f.id)).toList();

  Map<String, String> get _leagues {
    final result = <String, String>{};
    for (final fixture in _fixtures) {
      if (fixture.leagueId.isNotEmpty) {
        result[fixture.leagueId] = fixture.league;
      }
    }
    return result;
  }

  Future<void> _loadFixtures() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _fixturesRepository.getFixtures(
        date: _selectedDate,
        leagueId: _leagueId,
      );
      if (!mounted) return;
      setState(() {
        _fixtures = items;
        _selectedIds.removeWhere(
          (id) => !_fixtures.any((f) => f.id == id),
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _toggleFixture(Fixture fixture) {
    setState(() {
      if (_selectedIds.contains(fixture.id)) {
        _selectedIds.remove(fixture.id);
      } else if (_selectedIds.length < 5) {
        _selectedIds.add(fixture.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can select up to 5 matches.')),
        );
      }
    });
  }

  Future<void> _changeDate(int deltaDays) async {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
      _leagueId = null;
      _selectedIds.clear();
    });
    await _loadFixtures();
  }

  Future<void> _setLeague(String? value) async {
    setState(() {
      _leagueId = value;
      _selectedIds.clear();
    });
    await _loadFixtures();
  }

  Future<void> _generate() async {
    if (_selectedFixtures.isEmpty) return;

    final picks = _engine.generateSession(
      fixtures: _selectedFixtures,
      mode: _mode,
      existing: const {},
    );

    final session = GenerationSession(
      id: makeId('gen'),
      createdAt: DateTime.now(),
      requestedMode: _mode,
      fixtures: _selectedFixtures,
      picks: picks,
    );

    await _history.add(HistoryEntry(
      id: makeId('hist'),
      timestamp: DateTime.now(),
      action: HistoryActionType.generated,
      matchCount: picks.length,
      modeLabel: _mode.label,
    ));

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(session: session),
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    if (sameDay(_selectedDate, now)) return 'Today';
    if (sameDay(_selectedDate, now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }
    return '${_selectedDate.day.toString().padLeft(2, '0')}.'
        '${_selectedDate.month.toString().padLeft(2, '0')}.'
        '${_selectedDate.year}';
  }

  Widget _teamLogo(String? url, String shortName) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.white10,
        child: Text(
          shortName.substring(0, shortName.length < 2 ? shortName.length : 2),
          style: const TextStyle(fontSize: 10),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.white10,
      child: ClipOval(
        child: Image.network(
          url,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text(
            shortName.substring(0, shortName.length < 2 ? shortName.length : 2),
            style: const TextStyle(fontSize: 10),
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
          'KICKLUCK',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFixtures,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const Text(
                'Let luck pick.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Real fixtures. Random scenarios.',
                style: TextStyle(color: Colors.white.withValues(alpha: .65)),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  IconButton(
                    onPressed: () => _changeDate(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _dateLabel(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeDate(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              if (!_loading && _fixtures.isNotEmpty) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _leagueId ?? '',
                  decoration: const InputDecoration(
                    labelText: 'League',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('All leagues'),
                    ),
                    ..._leagues.entries.map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (value) => _setLeague(
                    value == null || value.isEmpty ? null : value,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GenerationMode.values.map((mode) {
                  return ChoiceChip(
                    label: Text(mode.label),
                    selected: _mode == mode,
                    onSelected: (_) => setState(() => _mode = mode),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _ErrorState(
                  message: _error!,
                  onRetry: _loadFixtures,
                )
              else if (_fixtures.isEmpty)
                const _EmptyState()
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_fixtures.length} upcoming matches',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('${_selectedIds.length}/5 selected'),
                  ],
                ),
                const SizedBox(height: 10),
                ..._fixtures.map((fixture) {
                  final selected = _selectedIds.contains(fixture.id);
                  final time = TimeOfDay.fromDateTime(
                    fixture.kickoff.toLocal(),
                  ).format(context);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: const Color(0xFF111A16),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _toggleFixture(fixture),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selected,
                                onChanged: (_) => _toggleFixture(fixture),
                              ),
                              const SizedBox(width: 4),
                              _teamLogo(
                                fixture.home.logoUrl,
                                fixture.home.shortName,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fixture.league,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: .5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${fixture.home.name} vs ${fixture.away.name}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: .55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _teamLogo(
                                fixture.away.logoUrl,
                                fixture.away.shortName,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _selectedIds.isEmpty ? null : _generate,
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('GENERATE'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF25F36A),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111A16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Could not load matches',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: .6)),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111A16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_soccer_outlined, size: 38),
          const SizedBox(height: 12),
          const Text(
            'No upcoming matches',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another date or remove the league filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: .6)),
          ),
        ],
      ),
    );
  }
}
