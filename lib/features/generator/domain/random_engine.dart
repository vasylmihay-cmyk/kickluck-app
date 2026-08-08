import 'dart:math';
import '../../fixtures/domain/fixture.dart';
import 'generated_pick.dart';
import 'generation_mode.dart';

class RandomEngine {
  RandomEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  GeneratedPick generatePick(Fixture fixture, GenerationMode mode) {
    final actualMode = mode == GenerationMode.randomMix
        ? _randomMode()
        : mode;

    final outcomes = _outcomesFor(actualMode);
    final outcome = outcomes[_random.nextInt(outcomes.length)];

    return GeneratedPick(
      fixture: fixture,
      mode: actualMode,
      outcome: outcome,
    );
  }

  List<GeneratedPick> generateSession({
    required List<Fixture> fixtures,
    required GenerationMode mode,
    required Map<String, GeneratedPick> existing,
  }) {
    return fixtures.map((fixture) {
      final current = existing[fixture.id];
      if (current != null && current.isLocked) {
        return current;
      }
      return generatePick(fixture, mode);
    }).toList();
  }

  GenerationMode _randomMode() {
    const allowed = [
      GenerationMode.oneXTwo,
      GenerationMode.doubleChance,
      GenerationMode.totalGoals,
      GenerationMode.exactTotal,
      GenerationMode.firstHalf,
      GenerationMode.secondHalf,
      GenerationMode.btts,
      GenerationMode.teamToScore,
    ];
    return allowed[_random.nextInt(allowed.length)];
  }

  List<String> _outcomesFor(GenerationMode mode) {
    switch (mode) {
      case GenerationMode.oneXTwo:
      case GenerationMode.firstHalf:
      case GenerationMode.secondHalf:
        return const ['1', 'X', '2'];
      case GenerationMode.doubleChance:
        return const ['1X', 'X2', '12'];
      case GenerationMode.totalGoals:
        return const [
          'Over 1.5',
          'Under 1.5',
          'Over 2.5',
          'Under 2.5',
          'Over 3.5',
          'Under 3.5',
        ];
      case GenerationMode.exactTotal:
        return const ['0', '1', '2', '3', '4', '5+'];
      case GenerationMode.btts:
        return const ['YES', 'NO'];
      case GenerationMode.teamToScore:
        return const ['Home', 'Away', 'Both', 'Neither'];
      case GenerationMode.randomMix:
        throw StateError('Random Mix must be resolved before outcome selection.');
    }
  }
}
