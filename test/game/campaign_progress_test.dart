import 'package:arrows_goo/core/storage/campaign_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts at level 1 by default', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    expect(container.read(campaignProgressProvider), 1);
  });

  test('completing a level advances progress and never goes backward', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    final progress = container.read(campaignProgressProvider.notifier);

    await progress.completeLevel(1);
    expect(container.read(campaignProgressProvider), 2);

    await progress.completeLevel(1);
    expect(container.read(campaignProgressProvider), 2);

    await progress.completeLevel(4);
    expect(container.read(campaignProgressProvider), 5);
  });

  test('saved current level is restored', () async {
    final container = await createTestContainer(
      prefs: {CampaignProgress.key: 7},
    );
    addTearDown(container.dispose);
    expect(container.read(campaignProgressProvider), 7);
  });

  test('reset returns campaign to level 1', () async {
    final container = await createTestContainer(
      prefs: {CampaignProgress.key: 9},
    );
    addTearDown(container.dispose);
    await container.read(campaignProgressProvider.notifier).reset();
    expect(container.read(campaignProgressProvider), 1);
  });
}
