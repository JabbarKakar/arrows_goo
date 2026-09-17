import 'package:flutter/material.dart';

class TutorialCoach extends StatelessWidget {
  const TutorialCoach({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      key: const Key('tutorial_overlay'),
      color: colors.surface,
      elevation: 3,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tap an arrow that can reach the edge.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Long-press to preview its path.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextButton(
              key: const Key('tutorial_got_it'),
              onPressed: onDismiss,
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
