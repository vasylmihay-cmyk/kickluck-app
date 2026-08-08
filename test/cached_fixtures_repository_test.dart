import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kickluck_mvp/features/fixtures/data/cached_fixtures_repository.dart';
import 'package:kickluck_mvp/features/fixtures/data/mock_fixtures.dart';
import 'package:kickluck_mvp/features/fixtures/domain/fixture.dart';
import 'package:kickluck_mvp/features/fixtures/domain/fixtures_repository.dart';

class _FakeRepository implements FixturesRepository {
  _FakeRepository(this.result);

  final List<Fixture> result;
  int calls = 0;

  @override
  Future<List<Fixture>> getFixtures({
    required DateTime date,
    String? leagueId,
  }) async {
    calls += 1;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('corrupt fresh cache is ignored and remote data is fetched', () async {
    final date = DateTime(2026, 8, 8);
    SharedPreferences.setMockInitialValues({
      'fixtures_cache_2026_08_08_all': '{broken-json',
      'fixtures_cache_2026_08_08_all_saved_at':
          DateTime.now().millisecondsSinceEpoch,
    });

    final remote = _FakeRepository([mockFixtures.first]);
    final repo = CachedFixturesRepository(remote: remote);

    final items = await repo.getFixtures(date: date);

    expect(remote.calls, 1);
    expect(items, hasLength(1));
    expect(items.single.id, mockFixtures.first.id);
  });
}
