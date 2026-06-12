import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bashap/models/match_result.dart';
import 'package:bashap/models/enums.dart';
import 'package:bashap/state/match_state_notifier.dart';
import 'package:bashap/utils/duration_formatter.dart';

class WinnerScreen extends StatelessWidget {
  final MatchResult result;

  const WinnerScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isBlue = result.winner == Corner.blue;
    final accentColor = isBlue
        ? const Color(0xFF0080FF)
        : const Color(0xFFFF4444);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWinnerCard(accentColor),
                  const SizedBox(height: 24),
                  _buildScoresCard(),
                  const SizedBox(height: 24),
                  _buildMatchInfoCard(),
                  const SizedBox(height: 32),
                  _buildNewMatchButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerCard(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'OFFICIAL RESULT',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'WINNER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getDisplayName(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'SIDE: ${result.winner.displayName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreColumn(
              result.blueCorner,
              Corner.blue,
              const Color(0xFF0080FF),
            ),
          ),
          Container(width: 2, height: 80, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: _buildScoreColumn(
              result.redCorner,
              Corner.red,
              const Color(0xFFFF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(dynamic competitor, Corner corner, Color color) {
    final name = competitor.name.trim();
    final displayName = name.isEmpty ? corner.displayName : name;

    return Column(
      children: [
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${competitor.totalScore}',
          style: TextStyle(
            color: color,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'POSITIVE: ${competitor.positiveScore} | MINUS: ${competitor.negativeScore}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'MATCH TIME',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatTimer(result.matchTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(width: 2, height: 60, color: Colors.white.withOpacity(0.1)),
          Expanded(
            child: Column(
              children: [
                Text(
                  'RESOLUTION PATH',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  _getResolutionIcon(result.resolutionMethod),
                  color: Colors.green.shade400,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  result.resolutionMethod.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getResolutionIcon(ResolutionMethod method) {
    switch (method) {
      case ResolutionMethod.pointsDecision:
        return Icons.check_circle;
      case ResolutionMethod.advantage:
        return Icons.trending_up;
      case ResolutionMethod.disqualification:
        return Icons.block;
    }
  }

  String _getDisplayName() {
    final name = result.winnerState.name.trim();

    // If name is empty, show corner name
    if (name.isEmpty) {
      return result.winner.displayName;
    }

    return name;
  }

  Widget _buildNewMatchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final notifier = context.read<MatchStateNotifier>();
          notifier.resetMatch();
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0A1628),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 24),
        label: const Text(
          'NEW MATCH',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
