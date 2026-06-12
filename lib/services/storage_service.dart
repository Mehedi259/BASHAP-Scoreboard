import 'package:bashap/models/match_result.dart';

/// Abstract interface for local storage operations
abstract class StorageService {
  /// Get the user's preferred timer configuration
  /// Returns null if no preference has been saved
  Future<Duration?> getTimerPreference();

  /// Save the user's timer configuration preference
  Future<void> setTimerPreference(Duration duration);

  /// Get the list of completed match results
  /// Returns empty list if no history exists
  Future<List<MatchResult>> getMatchHistory();

  /// Save a completed match result to history
  Future<void> saveMatchResult(MatchResult result);
}
