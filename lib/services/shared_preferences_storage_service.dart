import 'dart:convert';
import 'package:bashap/models/match_result.dart';
import 'package:bashap/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation of StorageService using SharedPreferences
class SharedPreferencesStorageService implements StorageService {
  static const String _timerPreferenceKey = 'timer_preference_seconds';
  static const String _matchHistoryKey = 'match_history';
  static const int _defaultTimerSeconds = 180; // 3 minutes

  @override
  Future<Duration?> getTimerPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seconds = prefs.getInt(_timerPreferenceKey);

      if (seconds == null) {
        return Duration(seconds: _defaultTimerSeconds);
      }

      return Duration(seconds: seconds);
    } catch (e) {
      // If error occurs, return default
      return Duration(seconds: _defaultTimerSeconds);
    }
  }

  @override
  Future<void> setTimerPreference(Duration duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_timerPreferenceKey, duration.inSeconds);
    } catch (e) {
      // Silently fail - persistence is not critical
      print('Failed to save timer preference: $e');
    }
  }

  @override
  Future<List<MatchResult>> getMatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_matchHistoryKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => MatchResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to load match history: $e');
      return [];
    }
  }

  @override
  Future<void> saveMatchResult(MatchResult result) async {
    try {
      final history = await getMatchHistory();
      history.add(result);

      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        history.map((result) => result.toJson()).toList(),
      );

      await prefs.setString(_matchHistoryKey, jsonString);
    } catch (e) {
      print('Failed to save match result: $e');
    }
  }
}
