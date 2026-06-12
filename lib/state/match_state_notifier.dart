import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:bashap/models/competitor_state.dart';
import 'package:bashap/models/enums.dart';
import 'package:bashap/models/match_result.dart';
import 'package:bashap/services/storage_service.dart';

/// Centralized state management for match operations
class MatchStateNotifier extends ChangeNotifier {
  final StorageService _storageService;

  // State properties
  CompetitorState _blueCorner = const CompetitorState(name: 'BLUE CORNER');
  CompetitorState _redCorner = const CompetitorState(name: 'RED CORNER');
  Duration _timerRemaining = const Duration(seconds: 180);
  Duration _timerInitial = const Duration(seconds: 180);
  MatchStatus _matchState = MatchStatus.fresh;
  Corner? _advantage;
  Timer? _timer;

  // Getters
  CompetitorState get blueCorner => _blueCorner;
  CompetitorState get redCorner => _redCorner;
  Duration get timerRemaining => _timerRemaining;
  Duration get timerInitial => _timerInitial;
  MatchStatus get matchState => _matchState;
  Corner? get advantage => _advantage;

  MatchStateNotifier(this._storageService) {
    _loadTimerPreference();
  }

  // Timer configuration and persistence
  Future<void> _loadTimerPreference() async {
    final duration = await _storageService.getTimerPreference();
    if (duration != null) {
      _timerInitial = duration;
      _timerRemaining = duration;
      notifyListeners();
    }
  }

  Future<void> updateTimerConfig(Duration duration) async {
    // Clamp to valid range (0 to 99:59)
    final seconds = duration.inSeconds.clamp(0, 5999);
    final clampedDuration = Duration(seconds: seconds);

    _timerInitial = clampedDuration;
    _timerRemaining = clampedDuration;

    await _storageService.setTimerPreference(clampedDuration);
    notifyListeners();
  }

  // Timer control
  void startTimer() {
    if (_timer != null && _timer!.isActive) {
      return; // Already running
    }

    _matchState = MatchStatus.active;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickTimer();
    });
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;

    if (_matchState == MatchStatus.active) {
      _matchState = MatchStatus.Thoma;
    }
    notifyListeners();
  }

  void _tickTimer() {
    if (_timerRemaining.inSeconds > 0) {
      _timerRemaining = Duration(seconds: _timerRemaining.inSeconds - 1);
      notifyListeners();

      if (_timerRemaining.inSeconds == 0) {
        stopTimer();
      }
    }
  }

  // Competitor name management
  void updateCompetitorName(Corner corner, String name) {
    final trimmedName = name.trim();

    if (corner == Corner.blue) {
      _blueCorner = _blueCorner.copyWith(name: trimmedName);
    } else {
      _redCorner = _redCorner.copyWith(name: trimmedName);
    }

    notifyListeners();
  }

  // Get display name with fallback to default
  String getDisplayName(Corner corner) {
    final competitor = corner == Corner.blue ? _blueCorner : _redCorner;
    final name = competitor.name.trim();

    if (name.isEmpty) {
      return corner == Corner.blue ? 'BLUE CORNER' : 'RED CORNER';
    }

    return name;
  }

  // Score management
  void incrementScore(Corner corner, ScoreType scoreType) {
    if (corner == Corner.blue) {
      if (scoreType == ScoreType.positive) {
        _blueCorner = _blueCorner.copyWith(
          positiveScore: _blueCorner.positiveScore + 1,
        );
      } else {
        _blueCorner = _blueCorner.copyWith(
          negativeScore: _blueCorner.negativeScore + 1,
        );
      }
    } else {
      if (scoreType == ScoreType.positive) {
        _redCorner = _redCorner.copyWith(
          positiveScore: _redCorner.positiveScore + 1,
        );
      } else {
        _redCorner = _redCorner.copyWith(
          negativeScore: _redCorner.negativeScore + 1,
        );
      }
    }

    notifyListeners();
  }

  void decrementScore(Corner corner, ScoreType scoreType) {
    if (corner == Corner.blue) {
      if (scoreType == ScoreType.positive) {
        if (_blueCorner.positiveScore > 0) {
          _blueCorner = _blueCorner.copyWith(
            positiveScore: _blueCorner.positiveScore - 1,
          );
        }
      } else {
        if (_blueCorner.negativeScore > 0) {
          _blueCorner = _blueCorner.copyWith(
            negativeScore: _blueCorner.negativeScore - 1,
          );
        }
      }
    } else {
      if (scoreType == ScoreType.positive) {
        if (_redCorner.positiveScore > 0) {
          _redCorner = _redCorner.copyWith(
            positiveScore: _redCorner.positiveScore - 1,
          );
        }
      } else {
        if (_redCorner.negativeScore > 0) {
          _redCorner = _redCorner.copyWith(
            negativeScore: _redCorner.negativeScore - 1,
          );
        }
      }
    }

    notifyListeners();
  }

  // Advantage management
  void setAdvantage(Corner corner) {
    if (_advantage == corner) {
      // Toggle off if same corner
      _advantage = null;
    } else {
      // Set or transfer advantage
      _advantage = corner;
    }

    notifyListeners();
  }

  // Winner determination
  MatchResult? determineWinner() {
    final blueTotal = _blueCorner.totalScore;
    final redTotal = _redCorner.totalScore;
    final elapsedTime = Duration(
      seconds: _timerInitial.inSeconds - _timerRemaining.inSeconds,
    );

    // Winner by score difference
    if (blueTotal > redTotal) {
      return MatchResult(
        winner: Corner.blue,
        blueCorner: _blueCorner,
        redCorner: _redCorner,
        matchTime: elapsedTime,
        resolutionMethod: ResolutionMethod.pointsDecision,
      );
    } else if (redTotal > blueTotal) {
      return MatchResult(
        winner: Corner.red,
        blueCorner: _blueCorner,
        redCorner: _redCorner,
        matchTime: elapsedTime,
        resolutionMethod: ResolutionMethod.pointsDecision,
      );
    }

    // Tied scores - check advantage
    if (_advantage != null) {
      return MatchResult(
        winner: _advantage!,
        blueCorner: _blueCorner,
        redCorner: _redCorner,
        matchTime: elapsedTime,
        resolutionMethod: ResolutionMethod.advantage,
      );
    }

    // Tied with no advantage - cannot determine winner
    return null;
  }

  // Disqualification
  MatchResult disqualify(Corner corner) {
    stopTimer();
    _matchState = MatchStatus.completed;

    final elapsedTime = Duration(
      seconds: _timerInitial.inSeconds - _timerRemaining.inSeconds,
    );

    // Opponent wins
    final winner = corner == Corner.blue ? Corner.red : Corner.blue;

    final result = MatchResult(
      winner: winner,
      blueCorner: _blueCorner,
      redCorner: _redCorner,
      matchTime: elapsedTime,
      resolutionMethod: ResolutionMethod.disqualification,
    );

    notifyListeners();
    return result;
  }

  // Match reset
  void resetMatch() {
    stopTimer();

    _blueCorner = const CompetitorState(name: 'BLUE CORNER');
    _redCorner = const CompetitorState(name: 'RED CORNER');
    _timerRemaining = _timerInitial;
    _matchState = MatchStatus.fresh;
    _advantage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
