import 'package:flutter/material.dart';

Future<bool?> showDisqualificationDialog(
  BuildContext context,
  String cornerName,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => DisqualificationDialog(cornerName: cornerName),
  );
}

class DisqualificationDialog extends StatelessWidget {
  final String cornerName;

  const DisqualificationDialog({super.key, required this.cornerName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A2332),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade700, width: 2),
      ),
      title: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.red.shade400, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'DISQUALIFY PLAYER?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action will terminate the match immediately and award the victory to the $cornerName. This decision is official and will be permanently logged in the tournament history.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('RETURN TO MATCH'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('CONFIRM DISQUALIFICATION'),
        ),
      ],
    );
  }
}
