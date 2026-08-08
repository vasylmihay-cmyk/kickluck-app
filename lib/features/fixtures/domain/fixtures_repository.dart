import 'fixture.dart';

abstract class FixturesRepository {
  Future<List<Fixture>> getFixtures({
    required DateTime date,
    String? leagueId,
  });
}
