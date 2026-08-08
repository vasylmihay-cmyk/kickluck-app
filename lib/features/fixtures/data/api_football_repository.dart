import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../domain/fixture.dart';
import '../domain/fixtures_repository.dart';
import 'api_football_mapper.dart';

class ApiFootballRepository implements FixturesRepository {
  ApiFootballRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _mapper = ApiFootballMapper();

  @override
  Future<List<Fixture>> getFixtures({
    required DateTime date,
    String? leagueId,
  }) async {
    if (!ApiConfig.hasApiFootballKey) {
      throw const ApiException(
        'API_FOOTBALL_KEY is missing. Run with --dart-define=API_FOOTBALL_KEY=...',
      );
    }

    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');

    final query = <String, String>{
      'date': '$y-$m-$d',
      'timezone': 'Europe/Budapest',
      if (leagueId != null && leagueId.isNotEmpty) 'league': leagueId,
    };

    final uri = Uri.parse(
      '${ApiConfig.apiFootballBaseUrl}/fixtures',
    ).replace(queryParameters: query);

    http.Response response;
    try {
      response = await _client
          .get(
            uri,
            headers: {
              'x-apisports-key': ApiConfig.apiFootballKey,
            },
          )
          .timeout(const Duration(seconds: 12));
    } on Exception {
      throw const ApiException(
        'Could not reach the football data service.',
      );
    }

    if (response.statusCode == 429) {
      throw const ApiRateLimitException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Football data service returned ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException('Unexpected football API response.');
    }

    final errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      throw ApiException('Football API error: ${errors.values.join(', ')}');
    }
    if (errors is List && errors.isNotEmpty) {
      throw ApiException('Football API error: ${errors.join(', ')}');
    }

    final rawItems = decoded['response'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map>()
        .map((raw) => _mapper.mapFixture(Map<String, dynamic>.from(raw)))
        .where((fixture) => fixture.status == 'NS' || fixture.status == 'TBD')
        .toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
  }

}
