import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/saved_combination.dart';

class SavedRepository {
  static const _key = 'kickluck_saved_combinations';

  Future<List<SavedCombination>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final items = raw
        .map((e) => SavedCombination.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map),
            ))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> save(SavedCombination combination) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final next = [
      combination,
      ...items.where((e) => e.id != combination.id),
    ];
    await prefs.setStringList(
      _key,
      next.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    await prefs.setStringList(
      _key,
      items
          .where((e) => e.id != id)
          .map((e) => jsonEncode(e.toJson()))
          .toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
