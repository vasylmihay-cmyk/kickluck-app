class ApiConfig {
  static const apiFootballKey = String.fromEnvironment(
    'API_FOOTBALL_KEY',
    defaultValue: '',
  );

  static const apiFootballBaseUrl =
      'https://v3.football.api-sports.io';

  static bool get hasApiFootballKey => apiFootballKey.trim().isNotEmpty;
}
