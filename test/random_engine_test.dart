import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:kickluck_mvp/features/fixtures/data/mock_fixtures.dart';
import 'package:kickluck_mvp/features/generator/domain/generation_mode.dart';
import 'package:kickluck_mvp/features/generator/domain/random_engine.dart';

void main() {
  test('locked picks survive regeneration', () {
    final engine = RandomEngine(random: Random(1));
    final fixture = mockFixtures.first;

    final first = engine.generatePick(fixture, GenerationMode.oneXTwo);
    final locked = first.copyWith(isLocked: true);

    final next = engine.generateSession(
      fixtures: [fixture],
      mode: GenerationMode.oneXTwo,
      existing: {fixture.id: locked},
    );

    expect(next.single.outcome, locked.outcome);
    expect(next.single.mode, locked.mode);
    expect(next.single.isLocked, isTrue);
  });

  test('1X2 produces only valid outcomes', () {
    final engine = RandomEngine(random: Random(3));
    final valid = {'1', 'X', '2'};

    for (var i = 0; i < 50; i++) {
      final pick = engine.generatePick(
        mockFixtures.first,
        GenerationMode.oneXTwo,
      );
      expect(valid.contains(pick.outcome), isTrue);
    }
  });
}
