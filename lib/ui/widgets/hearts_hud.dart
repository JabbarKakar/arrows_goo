import 'package:flutter/material.dart';

import '../../game/session/play_state.dart';

class HeartsHud extends StatelessWidget {
  const HeartsHud({super.key, required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < PlayState.maxHearts; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              i < hearts
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              key: Key('heart_$i'),
              color: const Color(0xFFE76F51),
            ),
          ),
      ],
    );
  }
}
