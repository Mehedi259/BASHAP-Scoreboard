/// Represents the state of a single competitor in a match
class CompetitorState {
  final String name;
  final int positiveScore;
  final int negativeScore;

  const CompetitorState({
    required this.name,
    this.positiveScore = 0,
    this.negativeScore = 0,
  });

  /// Calculate total score as sum of positive and negative scores
  /// Note: Can be negative if negativeScore exceeds positiveScore
  int get totalScore => positiveScore + negativeScore;

  /// Create a copy with optional field updates
  CompetitorState copyWith({
    String? name,
    int? positiveScore,
    int? negativeScore,
  }) {
    return CompetitorState(
      name: name ?? this.name,
      positiveScore: positiveScore ?? this.positiveScore,
      negativeScore: negativeScore ?? this.negativeScore,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'positiveScore': positiveScore,
      'negativeScore': negativeScore,
    };
  }

  /// Create from JSON
  factory CompetitorState.fromJson(Map<String, dynamic> json) {
    return CompetitorState(
      name: json['name'] as String,
      positiveScore: json['positiveScore'] as int,
      negativeScore: json['negativeScore'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompetitorState &&
        other.name == name &&
        other.positiveScore == positiveScore &&
        other.negativeScore == negativeScore;
  }

  @override
  int get hashCode {
    return Object.hash(name, positiveScore, negativeScore);
  }

  @override
  String toString() {
    return 'CompetitorState(name: $name, positive: $positiveScore, negative: $negativeScore, total: $totalScore)';
  }
}
