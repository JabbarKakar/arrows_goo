import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('sharedPreferencesProvider must be overridden');
});

class CampaignProgress extends Notifier<int> {
  static const key = 'campaign.currentLevel';

  @override
  int build() {
    return ref.watch(sharedPreferencesProvider).getInt(key) ?? 1;
  }

  Future<void> completeLevel(int level) async {
    final next = state > level + 1 ? state : level + 1;
    if (next == state) return;
    await ref.read(sharedPreferencesProvider).setInt(key, next);
    state = next;
  }

  Future<void> reset() async {
    await ref.read(sharedPreferencesProvider).setInt(key, 1);
    state = 1;
  }
}

final campaignProgressProvider =
    NotifierProvider<CampaignProgress, int>(CampaignProgress.new);
