import 'package:arrows_goo/game/engine/board_engine.dart';
import 'package:arrows_goo/game/session/play_session.dart';
import 'package:arrows_goo/game/session/play_state.dart';
import 'package:arrows_goo/core/storage/campaign_progress.dart';
import 'package:arrows_goo/core/storage/daily_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  PlaySessionNotifier session() => container.read(playSessionProvider.notifier);

  PlayState read() => container.read(playSessionProvider);

  setUp(() async {
    container = await createTestContainer();
  });

  tearDown(() => container.dispose());

  test('loads tutorial level 1', () {
    expect(read().levelNumber, 1);
    expect(read().board.rows, 3);
    expect(read().board.arrowCount, 9);
  });

  test('valid tap does not spend a heart', () {
    session().tap(2, 2);
    expect(read().hearts, PlayState.maxHearts);
    expect(read().sliding, isNotNull);
    expect(read().isFailed, isFalse);
    expect(feelOf(container).calls, ['validMove']);
  });

  test('blocked tap spends a heart and shakes', () {
    session().tap(1, 1);
    expect(read().hearts, 2);
    expect(read().shakingPos?.row, 1);
    expect(read().shakingPos?.col, 1);
    expect(read().board.at(1, 1), isNotNull);
    expect(feelOf(container).calls, ['blockedTap']);
  });

  test('three blocked taps fail the level', () {
    session().tap(1, 1);
    session().tap(1, 1);
    session().tap(1, 1);
    expect(read().hearts, 0);
    expect(read().isFailed, isTrue);
    expect(read().isWon, isFalse);
  });

  test('empty cell tap does not spend a heart', () async {
    session().tap(2, 2);
    await session().completeSlide();
    expect(read().board.at(2, 2), isNull);

    session().tap(2, 2);
    expect(read().hearts, PlayState.maxHearts);
    expect(read().isFailed, isFalse);
  });

  test('hint highlights the first movable arrow', () {
    session().hint();
    expect(read().hintedPos?.row, 0);
    expect(read().hintedPos?.col, 0);
  });

  test('pause blocks taps until resumed', () {
    session().pause();
    expect(read().isPaused, isTrue);
    session().tap(1, 1);
    expect(read().hearts, PlayState.maxHearts);
    session().resume();
    session().tap(1, 1);
    expect(read().hearts, 2);
  });

  test('restart restores hearts and the board', () {
    session().tap(1, 1);
    session().tap(2, 2);
    session().restart();
    expect(read().hearts, PlayState.maxHearts);
    expect(read().isFailed, isFalse);
    expect(read().isWon, isFalse);
    expect(read().isPaused, isFalse);
    expect(read().board.arrowCount, 9);
    expect(read().levelNumber, 1);
  });

  test('nextLevel loads the following tutorial board', () {
    session().nextLevel();
    expect(read().levelNumber, 2);
    expect(read().board.rows, 3);
    expect(read().isWon, isFalse);
  });

  test('free hints are limited then extra hint grants one', () {
    expect(read().hintsRemaining, PlayState.freeHintsPerLevel);
    session().hint();
    session().hint();
    expect(read().hintsRemaining, 0);
    session().hint();
    expect(read().hintsRemaining, 0);

    session().extraHint();
    expect(read().hintsRemaining, 0);
    expect(read().hintedPos, isNotNull);
  });

  test('continue after fail restores one heart', () {
    session().tap(1, 1);
    session().tap(1, 1);
    session().tap(1, 1);
    expect(read().isFailed, isTrue);

    session().continueWithHeart();
    expect(read().isFailed, isFalse);
    expect(read().hearts, 1);
    expect(read().board.arrowCount, 9);
  });

  test('daily clear does not advance campaign', () async {
    container.dispose();
    container = await createTestContainer(
      config: const PlayConfig.daily('20260917'),
    );
    expect(read().isDaily, isTrue);
    expect(container.read(campaignProgressProvider), 1);

    var guard = 0;
    while (!read().board.isCleared && guard < 80) {
      final moves = BoardEngine.movablePositions(read().board);
      expect(moves, isNotEmpty);
      session().tap(moves.first.row, moves.first.col);
      await session().completeSlide();
      guard++;
    }

    expect(read().isWon, isTrue);
    expect(container.read(campaignProgressProvider), 1);
    expect(container.read(dailyProgressProvider), '20260917');
    expect(feelOf(container).calls, contains('cleared'));
  });
}
