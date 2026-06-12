import 'package:bashap/models/competitor_state.dart';
import 'package:bashap/models/enums.dart';

/// Represents the complete result of a finished match
class MatchResult {
  final Corner winner;
  final CompetitorState blueCorner;
  final CompetitorState redCorner;
  final Duration matchTime;
  final ResolutionMethod resolutionMethod;

  const MatchResult({
    required this.winner,
    required this.blueCorner,
    required this.redCorner,
    required this.matchTime,
    required this.resolutionMethod,
  });

  /// Get the winning competitor's state
  CompetitorState get winnerState {
    return winner == Corner.blue ? blueCorner : redCorner;
  }

  /// Get the losing competitor's state
  CompetitorState get loserState {
    return winner == Corner.blue ? redCorner : blueCorner;
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'winner': winner.name,
      'blueCorner': blueCorner.toJson(),
      'redCorner': redCorner.toJson(),
      'matchTimeSeconds': matchTime.inSeconds,
      'resolutionMethod': resolutionMethod.toJson(),
    };
  }

  /// Create from JSON
  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      winner: Corner.values.firstWhere((e) => e.name == json['winner']),
      blueCorner: CompetitorState.fromJson(
        json['blueCorner'] as Map<String, dynamic>,
      ),
      redCorner: CompetitorState.fromJson(
        json['redCorner'] as Map<String, dynamic>,
      ),
      matchTime: Duration(seconds: json['matchTimeSeconds'] as int),
      resolutionMethod: ResolutionMethod.fromJson(
        json['resolutionMethod'] as String,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchResult &&
        other.winner == winner &&
        other.blueCorner == blueCorner &&
        other.redCorner == redCorner &&
        other.matchTime == matchTime &&
        other.resolutionMethod == resolutionMethod;
  }

  @override
  int get hashCode {
    return Object.hash(
      winner,
      blueCorner,
      redCorner,
      matchTime,
      resolutionMethod,
    );
  }

  @override
  String toString() {
    return 'MatchResult(winner: $winner, resolution: $resolutionMethod, time: $matchTime)';
  }
}
