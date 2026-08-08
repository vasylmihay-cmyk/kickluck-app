import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/fixture.dart';
import '../domain/fixtures_repository.dart';

class CachedFixturesRepository implements FixturesRepository {
  CachedFixturesRepository({
    required this.remote,
    this.ttl = const Duration(minutes: 20),
  });

  final FixturesRepository remote;
  final Duration ttl;

  String _key(DateTime date, String? leagueId) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return 'fixtures_cache_${y}_${m}_${d}_${leagueId ?? "all"}';
  }

  String _timeKey(DateTime date, String? leagueId) =>
      '${_key(date, leagueId)}_saved_at';

  @override
  Future<List<Fixture>> getFixtures({
    required DateTime date,
    String? leagueId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(date, leagueId);
    final timeKey = _timeKey(date, leagueId);

    final cachedRaw = prefs.getString(key);
    final cachedAtMs = prefs.getInt(timeKey);

    if (cachedRaw != null && cachedAtMs != null) {
      final age = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(cachedAtMs),
      );
      if (age <= ttl) {
        final cached = _decodeCache(cachedRaw);
        if (cached != null) return cached;
      }
    }

    try {
      final fresh = await remote.getFixtures(
        date: date,
        leagueId: leagueId,
      );

      await prefs.setString(
        key,
        jsonEncode(fresh.map((e) => e.toJson()).toList()),
      );
      await prefs.setInt(
        timeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return fresh;
    } catch (_) {
      // Graceful stale-cache fallback. Corrupt cache is ignored so the
      // original remote error remains visible instead of a JSON parse error.
      if (cachedRaw != null) {
        final cached = _decodeCache(cachedRaw);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  List<Fixture>? _decodeCache(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map>()
          .map((e) => Fixture.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
          (k) => k.startsWith('fixtures_cache_'),
        );
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
