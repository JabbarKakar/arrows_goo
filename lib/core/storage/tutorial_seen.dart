import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'campaign_progress.dart';

class TutorialSeen extends Notifier<bool> {
  static const key = 'tutorial.seen';

  @override
  bool build() {
    return ref.watch(sharedPreferencesProvider).getBool(key) ?? false;
  }

  Future<void> markSeen() async {
    if (state) return;
    await ref.read(sharedPreferencesProvider).setBool(key, true);
    state = true;
  }
}

final tutorialSeenProvider =
    NotifierProvider<TutorialSeen, bool>(TutorialSeen.new);
