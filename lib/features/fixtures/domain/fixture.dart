import 'team.dart';

class Fixture {
  final String id;
  final String leagueId;
  final String league;
  final DateTime kickoff;
  final Team home;
  final Team away;
  final String status;

  const Fixture({
    required this.id,
    this.leagueId = '',
    required this.league,
    required this.kickoff,
    required this.home,
    required this.away,
    this.status = 'NS',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'leagueId': leagueId,
        'league': league,
        'kickoff': kickoff.toIso8601String(),
        'home': home.toJson(),
        'away': away.toJson(),
        'status': status,
      };

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: json['id'] as String,
      leagueId: json['leagueId'] as String? ?? '',
      league: json['league'] as String,
      kickoff: DateTime.parse(json['kickoff'] as String),
      home: Team.fromJson(Map<String, dynamic>.from(json['home'] as Map)),
      away: Team.fromJson(Map<String, dynamic>.from(json['away'] as Map)),
      status: json['status'] as String? ?? 'NS',
    );
  }
}
