import '../domain/fixture.dart';
import '../domain/team.dart';

class ApiFootballMapper {
  const ApiFootballMapper();

  Fixture mapFixture(Map<String, dynamic> raw) {
    final fixture = Map<String, dynamic>.from(raw['fixture'] as Map);
    final league = Map<String, dynamic>.from(raw['league'] as Map);
    final teams = Map<String, dynamic>.from(raw['teams'] as Map);
    final home = Map<String, dynamic>.from(teams['home'] as Map);
    final away = Map<String, dynamic>.from(teams['away'] as Map);
    final status = Map<String, dynamic>.from(fixture['status'] as Map);

    Team mapTeam(Map<String, dynamic> team) {
      final name = (team['name'] as String?) ?? 'Unknown';
      final words = name
          .split(RegExp(r'\s+'))
          .where((e) => e.isNotEmpty)
          .toList();

      final short = words.length >= 2
          ? '${words[0][0]}${words[1][0]}'.toUpperCase()
          : name.substring(0, name.length < 3 ? name.length : 3).toUpperCase();

      return Team(
        id: '${team['id'] ?? ''}',
        name: name,
        shortName: short,
        logoUrl: team['logo'] as String?,
      );
    }

    return Fixture(
      id: '${fixture['id']}',
      leagueId: '${league['id'] ?? ''}',
      league: (league['name'] as String?) ?? 'Unknown league',
      kickoff: DateTime.parse(fixture['date'] as String),
      home: mapTeam(home),
      away: mapTeam(away),
      status: (status['short'] as String?) ?? 'NS',
    );
  }
}
