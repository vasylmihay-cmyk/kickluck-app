import '../../../core/network/api_config.dart';
import '../domain/fixtures_repository.dart';
import 'api_football_repository.dart';
import 'cached_fixtures_repository.dart';
import 'mock_fixtures_repository.dart';

FixturesRepository createFixturesRepository() {
  final base = ApiConfig.hasApiFootballKey
      ? ApiFootballRepository()
      : MockFixturesRepository();

  return CachedFixturesRepository(remote: base);
}
