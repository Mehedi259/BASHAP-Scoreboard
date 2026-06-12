import 'package:flutter/material.dart';
import 'package:bashap/utils/duration_formatter.dart';

Future<Duration?> showTimerConfigDialog(
  BuildContext context,
  Duration currentDuration,
) {
  return showDialog<Duration>(
    context: context,
    builder: (context) => TimerConfigDialog(currentDuration: currentDuration),
  );
}

class TimerConfigDialog extends StatefulWidget {
  final Duration currentDuration;

  const TimerConfigDialog({super.key, required this.currentDuration});

  @override
  State<TimerConfigDialog> createState() => _TimerConfigDialogState();
}

class _TimerConfigDialogState extends State<TimerConfigDialog> {
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.currentDuration;
  }

  void _adjustTime(int seconds) {
    setState(() {
      final newSeconds = (_selectedDuration.inSeconds + seconds).clamp(0, 5999);
      _selectedDuration = Duration(seconds: newSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Configure Timer',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer display
          Text(
            formatTimer(_selectedDuration),
            style: const TextStyle(
              color: Color(0xFF0080FF),
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 24),
          // Adjustment buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAdjustButton('-1m', () => _adjustTime(-60)),
              _buildAdjustButton('-15s', () => _adjustTime(-15)),
              _buildAdjustButton('+15s', () => _adjustTime(15)),
              _buildAdjustButton('+1m', () => _adjustTime(60)),
            ],
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedDuration),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0080FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
