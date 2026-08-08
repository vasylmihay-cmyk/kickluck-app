import '../domain/fixture.dart';
import '../domain/fixtures_repository.dart';
import 'mock_fixtures.dart';

class MockFixturesRepository implements FixturesRepository {
  @override
  Future<List<Fixture>> getFixtures({
    required DateTime date,
    String? leagueId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return mockFixtures
        .where((f) => leagueId == null || leagueId.isEmpty || f.leagueId == leagueId)
        .toList();
  }
}
