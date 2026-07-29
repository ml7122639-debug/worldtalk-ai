import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/app_models.dart';

/// Simple local history service using SharedPreferences.
/// For production: replace with sqflite or Firestore for better querying.
class HistoryService {
  static const _historyKey = 'translation_history';

  /// Save a translation result to local history
  static Future<void> saveTranslation(TranslationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Prepend — newest first, max 100
    history.insert(0, result);
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    final json = history.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_historyKey, json);
  }

  /// Get all saved translations (newest first)
  static Future<List<TranslationResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];

    return raw
        .map((s) => TranslationResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// Delete a specific history item by ID
  static Future<void> deleteItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((t) => t.id == id);

    final json = history.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_historyKey, json);
  }

  /// Clear all history
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Get count of translations today (for rate limiting)
  static Future<int> getTodayCount() async {
    final history = await getHistory();
    final today = DateTime.now();
    return history.where((t) =>
        t.timestamp.year == today.year &&
        t.timestamp.month == today.month &&
        t.timestamp.day == today.day).length;
  }
}
