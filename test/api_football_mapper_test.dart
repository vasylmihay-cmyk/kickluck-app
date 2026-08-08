import 'package:flutter_test/flutter_test.dart';
import 'package:kickluck_mvp/features/fixtures/data/api_football_mapper.dart';

void main() {
  test('maps API-Football fixture response into domain Fixture', () {
    const mapper = ApiFootballMapper();

    final fixture = mapper.mapFixture({
      'fixture': {
        'id': 12345,
        'date': '2026-08-08T18:30:00+02:00',
        'status': {'short': 'NS'},
      },
      'league': {
        'id': 39,
        'name': 'Premier League',
      },
      'teams': {
        'home': {
          'id': 1,
          'name': 'Arsenal',
          'logo': 'https://example.test/arsenal.png',
        },
        'away': {
          'id': 2,
          'name': 'Chelsea',
          'logo': 'https://example.test/chelsea.png',
        },
      },
    });

    expect(fixture.id, '12345');
    expect(fixture.leagueId, '39');
    expect(fixture.league, 'Premier League');
    expect(fixture.home.name, 'Arsenal');
    expect(fixture.away.name, 'Chelsea');
    expect(fixture.status, 'NS');
  });
}
