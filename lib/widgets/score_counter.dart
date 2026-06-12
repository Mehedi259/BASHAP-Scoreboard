import 'package:flutter/material.dart';

class ScoreCounter extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ScoreCounter({
    super.key,
    required this.label,
    required this.score,
    required this.color,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus button
            Material(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(Icons.remove, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Score display
            Container(
              constraints: BoxConstraints(minWidth: 80),
              child: Text(
                score.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Plus button
            Material(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(Icons.add, color: color, size: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
