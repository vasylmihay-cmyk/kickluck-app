import '../domain/fixture.dart';
import '../domain/team.dart';

final mockFixtures = <Fixture>[
  Fixture(
    id: 'm1',
    leagueId: '39',
    league: 'Premier League',
    kickoff: DateTime(2026, 8, 8, 15, 0),
    home: Team(id: 'ars', name: 'Arsenal', shortName: 'ARS'),
    away: Team(id: 'che', name: 'Chelsea', shortName: 'CHE'),
  ),
  Fixture(
    id: 'm2',
    leagueId: '39',
    league: 'Premier League',
    kickoff: DateTime(2026, 8, 8, 17, 30),
    home: Team(id: 'liv', name: 'Liverpool', shortName: 'LIV'),
    away: Team(id: 'eve', name: 'Everton', shortName: 'EVE'),
  ),
  Fixture(
    id: 'm3',
    leagueId: '140',
    league: 'La Liga',
    kickoff: DateTime(2026, 8, 8, 19, 0),
    home: Team(id: 'rma', name: 'Real Madrid', shortName: 'RMA'),
    away: Team(id: 'val', name: 'Valencia', shortName: 'VAL'),
  ),
  Fixture(
    id: 'm4',
    leagueId: '135',
    league: 'Serie A',
    kickoff: DateTime(2026, 8, 8, 20, 45),
    home: Team(id: 'int', name: 'Inter', shortName: 'INT'),
    away: Team(id: 'rom', name: 'Roma', shortName: 'ROM'),
  ),
  Fixture(
    id: 'm5',
    leagueId: '78',
    league: 'Bundesliga',
    kickoff: DateTime(2026, 8, 8, 18, 30),
    home: Team(id: 'bay', name: 'Bayern Munich', shortName: 'BAY'),
    away: Team(id: 'rbl', name: 'RB Leipzig', shortName: 'RBL'),
  ),
];
