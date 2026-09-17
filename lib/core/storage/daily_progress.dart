import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'campaign_progress.dart';

class DailyProgress extends Notifier<String?> {
  static const key = 'daily.completedId';

  @override
  String? build() {
    return ref.watch(sharedPreferencesProvider).getString(key);
  }

  bool isCompleted(String id) => state == id;

  Future<void> markComplete(String id) async {
    if (state == id) return;
    await ref.read(sharedPreferencesProvider).setString(key, id);
    state = id;
  }
}

final dailyProgressProvider =
    NotifierProvider<DailyProgress, String?>(DailyProgress.new);
