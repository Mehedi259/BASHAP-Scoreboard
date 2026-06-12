/// Represents which corner a competitor is assigned to
enum Corner {
  blue,
  red;

  String get displayName {
    switch (this) {
      case Corner.blue:
        return 'BLUE CORNER';
      case Corner.red:
        return 'RED CORNER';
    }
  }
}

/// Type of score being tracked
enum ScoreType { positive, negative }

/// Current state of the match
enum MatchStatus {
  fresh, // Initial state, match not started
  active, // Match in progress, timer running
  Thoma, // Match Thoma, timer stopped
  completed, // Match finished
}

/// How the winner was determined
enum ResolutionMethod {
  pointsDecision,
  advantage,
  disqualification;

  String get displayName {
    switch (this) {
      case ResolutionMethod.pointsDecision:
        return 'POINTS DECISION';
      case ResolutionMethod.advantage:
        return 'ADVANTAGE';
      case ResolutionMethod.disqualification:
        return 'DISQUALIFICATION';
    }
  }

  String toJson() {
    return name;
  }

  static ResolutionMethod fromJson(String json) {
    return ResolutionMethod.values.firstWhere((e) => e.name == json);
  }
}
