import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bashap/models/enums.dart';
import 'package:bashap/state/match_state_notifier.dart';
import 'package:bashap/utils/duration_formatter.dart';
import 'package:bashap/widgets/score_counter.dart';
import 'package:bashap/widgets/disqualification_dialog.dart';
import 'package:bashap/widgets/reset_confirmation_dialog.dart';
import 'package:bashap/widgets/timer_config_dialog.dart';
import 'package:bashap/screens/winner_screen.dart';

class ScoreboardScreen extends StatelessWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Consumer<MatchStateNotifier>(
        builder: (context, notifier, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildTimerHeader(context, notifier),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildMatchControls(context, notifier),
                              const SizedBox(height: 24),
                              if (isMobile)
                                _buildMobileLayout(context, notifier)
                              else
                                _buildDesktopLayout(context, notifier),
                              const SizedBox(height: 24),
                              _buildDetermineWinnerButton(context, notifier),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerHeader(BuildContext context, MatchStateNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatTimer(notifier.timerRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () async {
              final newDuration = await showTimerConfigDialog(
                context,
                notifier.timerInitial,
              );
              if (newDuration != null) {
                notifier.updateTimerConfig(newDuration);
              }
            },
            icon: const Icon(Icons.settings, color: Colors.white70),
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchControls(
    BuildContext context,
    MatchStateNotifier notifier,
  ) {
    final isActive = notifier.matchState == MatchStatus.active;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Start/Stop button
        ElevatedButton.icon(
          onPressed: isActive ? notifier.stopTimer : notifier.startTimer,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(isActive ? Icons.pause : Icons.play_arrow, size: 28),
          label: Text(
            isActive ? 'THOMA' : 'AKHAE',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        // Reset button
        IconButton(
          onPressed: () async {
            final confirmed = await showResetConfirmationDialog(context);
            if (confirmed == true) {
              notifier.resetMatch();
            }
          },
          icon: const Icon(Icons.refresh, color: Colors.white70),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, MatchStateNotifier notifier) {
    return Column(
      children: [
        _buildCompetitorSection(context, notifier, Corner.blue),
        const SizedBox(height: 24),
        _buildCompetitorSection(context, notifier, Corner.red),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    MatchStateNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCompetitorSection(context, notifier, Corner.blue),
        ),
        const SizedBox(width: 24),
        Expanded(child: _buildCompetitorSection(context, notifier, Corner.red)),
      ],
    );
  }

  Widget _buildCompetitorSection(
    BuildContext context,
    MatchStateNotifier notifier,
    Corner corner,
  ) {
    final isBlue = corner == Corner.blue;
    final competitor = isBlue ? notifier.blueCorner : notifier.redCorner;
    final accentColor = isBlue
        ? const Color(0xFF0080FF)
        : const Color(0xFFFF4444);
    final hasAdvantage = notifier.advantage == corner;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Corner indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: accentColor, size: 24),
              const SizedBox(width: 8),
              Text(
                corner.displayName,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name input
          TextFormField(
            key: ValueKey('${corner.name}_reset_${notifier.resetCounter}'),
            initialValue: competitor.name,
            onChanged: (value) => notifier.updateCompetitorName(corner, value),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'ENTER NAME...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accentColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Positive score
          ScoreCounter(
            label: 'POINTS',
            score: competitor.positiveScore,
            color: accentColor,
            onIncrement: () =>
                notifier.incrementScore(corner, ScoreType.positive),
            onDecrement: () =>
                notifier.decrementScore(corner, ScoreType.positive),
          ),
          const SizedBox(height: 24),
          // Negative score
          ScoreCounter(
            label: 'MINUS POINTS',
            score: competitor.negativeScore,
            color: Colors.orange,
            onIncrement: () =>
                notifier.incrementScore(corner, ScoreType.negative),
            onDecrement: () =>
                notifier.decrementScore(corner, ScoreType.negative),
          ),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final opponentName = notifier.getDisplayName(
                      corner == Corner.blue ? Corner.red : Corner.blue,
                    );
                    final confirmed = await showDisqualificationDialog(
                      context,
                      opponentName,
                    );
                    if (confirmed == true) {
                      final result = notifier.disqualify(corner);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WinnerScreen(result: result),
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.block, size: 20),
                  label: const Text('DISQUALIFY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => notifier.setAdvantage(corner),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasAdvantage
                        ? accentColor
                        : Colors.white.withOpacity(0.1),
                    foregroundColor: hasAdvantage
                        ? Colors.white
                        : Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    hasAdvantage ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                  ),
                  label: const Text('ADVANTAGE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetermineWinnerButton(
    BuildContext context,
    MatchStateNotifier notifier,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final result = notifier.determineWinner();
          if (result == null) {
            // Show error - tiebreaker needed
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1A2332),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Tiebreaker Required',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Match is tied. Please assign advantage to determine winner.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WinnerScreen(result: result),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A1628),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.emoji_events, size: 28),
        label: const Text(
          'DETERMINE WINNER',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
