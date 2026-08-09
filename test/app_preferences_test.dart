import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kickluck_mvp/features/settings/data/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('preferences persist theme and language', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences.instance;
    await preferences.load();

    await preferences.setThemeMode(ThemeMode.light);
    await preferences.setLanguage('Русский');

    final raw = await SharedPreferences.getInstance();
    expect(raw.getString('kickluck_theme_mode'), 'light');
    expect(raw.getString('kickluck_language'), 'Русский');
  });
}
