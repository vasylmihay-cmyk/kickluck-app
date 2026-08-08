import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/history_entry.dart';

class HistoryRepository {
  static const _key = 'kickluck_history';

  Future<List<HistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const [];
    final items = raw
        .map((e) => HistoryEntry.fromJson(
              Map<String, dynamic>.from(jsonDecode(e) as Map),
            ))
        .toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> add(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final next = [entry, ...items].take(200).toList();
    await prefs.setStringList(
      _key,
      next.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
