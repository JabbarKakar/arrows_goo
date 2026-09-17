import 'package:arrows_goo/core/storage/app_settings.dart';
import 'package:arrows_goo/core/storage/campaign_progress.dart';
import 'package:arrows_goo/core/storage/tutorial_seen.dart';
import 'package:arrows_goo/game/levels/tutorial_levels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

Future<void> openPlay(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  await tester.pumpWidget(await createTestApp(prefs: prefs));
  await tester.tap(find.byKey(const Key('play_button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> pumpSlide(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));
}

Future<void> solveLevel1(WidgetTester tester) async {
  for (final pos in TutorialLevels.level1Solution) {
    await tester.tap(find.byKey(Key('cell_${pos.row}_${pos.col}')));
    await pumpSlide(tester);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home shows title and navigates to play', (tester) async {
    await tester.pumpWidget(await createTestApp());

    expect(find.text('Arrows Goo'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byKey(const Key('home_level_label')), findsOneWidget);

    await tester.tap(find.byKey(const Key('play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.widgetWithText(AppBar, 'Level 1'), findsOneWidget);
    expect(find.byKey(const Key('tutorial_overlay')), findsOneWidget);
    expect(find.text('Tap an arrow that can reach the edge.'), findsOneWidget);
    expect(find.byKey(const Key('cell_0_0')), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNWidgets(3));
  });

  testWidgets('play board zooms in and out with InteractiveViewer', (tester) async {
    await openPlay(tester);

    expect(find.byKey(const Key('board_zoom_viewer')), findsOneWidget);
    expect(find.byKey(const Key('zoom_in_button')), findsOneWidget);
    expect(find.byKey(const Key('zoom_out_button')), findsOneWidget);

    final viewer = tester.widget<InteractiveViewer>(
      find.byKey(const Key('board_zoom_viewer')),
    );
    final controller = viewer.transformationController!;
    final start = controller.value.getMaxScaleOnAxis();

    await tester.tap(find.byKey(const Key('zoom_in_button')));
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), greaterThan(start));

    await tester.tap(find.byKey(const Key('zoom_out_button')));
    await tester.pump();
    expect(controller.value.getMaxScaleOnAxis(), closeTo(start, 0.05));
  });

  testWidgets('tapping a movable arrow slides it off the board', (tester) async {
    await openPlay(tester);

    expect(find.byKey(const Key('arrow_8')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cell_2_2')));
    await pumpSlide(tester);

    expect(find.byKey(const Key('arrow_8')), findsNothing);
    expect(find.text('Cleared!'), findsNothing);
  });

  testWidgets('solving level 1 shows Cleared', (tester) async {
    await openPlay(tester);
    await solveLevel1(tester);

    expect(find.text('Cleared!'), findsOneWidget);
    expect(find.text('Perfect — no hearts lost'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.byKey(const Key('clear_confetti')), findsOneWidget);
  });

  testWidgets('blocked taps spend hearts and then fail', (tester) async {
    await openPlay(tester);

    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();

    expect(find.text('Out of hearts'), findsOneWidget);
    expect(find.byKey(const Key('continue_button')), findsOneWidget);
    expect(find.text('Ad placeholder — restores one heart'), findsOneWidget);
    expect(find.byKey(const Key('restart_button')), findsOneWidget);
  });

  testWidgets('hint highlights a movable arrow', (tester) async {
    await openPlay(tester);

    await tester.tap(find.byKey(const Key('hint_button')));
    await tester.pump();

    expect(find.byKey(const Key('hinted_cell')), findsOneWidget);
  });

  testWidgets('two free hints then extra hint placeholder', (tester) async {
    await openPlay(tester);

    expect(find.text('Hint · 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hint_button')));
    await tester.pump();
    expect(find.text('Hint · 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('hint_button')));
    await tester.pump();

    expect(find.text('Extra hint'), findsOneWidget);
    expect(find.text('Ad placeholder — extra hint'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cell_2_2')));
    await pumpSlide(tester);
    expect(find.byKey(const Key('hinted_cell')), findsNothing);

    await tester.tap(find.byKey(const Key('hint_button')));
    await tester.pump();
    expect(find.byKey(const Key('hinted_cell')), findsOneWidget);
  });

  testWidgets('pause sheet can resume', (tester) async {
    await openPlay(tester);

    await tester.tap(find.byKey(const Key('pause_button')));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(find.byKey(const Key('resume_button')));
    await tester.pump();

    expect(find.text('Paused'), findsNothing);
    expect(find.byKey(const Key('hint_button')), findsOneWidget);
  });

  testWidgets('home continue starts the saved campaign level', (tester) async {
    await tester.pumpWidget(
      await createTestApp(prefs: {CampaignProgress.key: 5}),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Level 5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.widgetWithText(AppBar, 'Level 5'), findsOneWidget);
    expect(find.byKey(const Key('cell_3_3')), findsOneWidget);
  });

  testWidgets('fail continue restores a heart', (tester) async {
    await openPlay(tester);

    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('cell_1_1')));
    await tester.pump();

    expect(find.text('Out of hearts'), findsOneWidget);
    await tester.tap(find.byKey(const Key('continue_button')));
    await tester.pump();

    expect(find.text('Out of hearts'), findsNothing);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('daily screen opens today\'s puzzle', (tester) async {
    await tester.pumpWidget(
      await createTestApp(now: DateTime(2026, 9, 17)),
    );
    await tester.tap(find.text('Daily'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('17 Sep 2026'), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily_play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.widgetWithText(AppBar, 'Daily'), findsOneWidget);
  });

  testWidgets('settings can switch theme and reset progress', (tester) async {
    await tester.pumpWidget(
      await createTestApp(prefs: {CampaignProgress.key: 5}),
    );
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Celebrations'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pump();

    await tester.tap(find.byKey(const Key('reset_progress_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('confirm_reset_button')));
    await tester.pump();

    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
  });

  testWidgets('first-run tutorial dismisses with Got it', (tester) async {
    await openPlay(tester);
    expect(find.byKey(const Key('tutorial_overlay')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tutorial_got_it')));
    await tester.pump();

    expect(find.byKey(const Key('tutorial_overlay')), findsNothing);
    expect(
      find.text('Tap a free arrow, or long-press for guidance.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('pause_button')));
    await tester.pump();
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const Key('play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('tutorial_overlay')), findsNothing);
  });

  testWidgets('seen tutorial is not shown again', (tester) async {
    await openPlay(tester, prefs: {TutorialSeen.key: true});
    expect(find.byKey(const Key('tutorial_overlay')), findsNothing);
    expect(
      find.text('Tap a free arrow, or long-press for guidance.'),
      findsOneWidget,
    );
  });

  testWidgets('celebrations off skips confetti', (tester) async {
    await openPlay(
      tester,
      prefs: {
        TutorialSeen.key: true,
        AppSettingsNotifier.celebrationsKey: false,
      },
    );
    await solveLevel1(tester);
    expect(find.text('Cleared!'), findsOneWidget);
    expect(find.byKey(const Key('clear_confetti')), findsNothing);
  });
}
