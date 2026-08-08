import '../../fixtures/domain/fixture.dart';
import 'generated_pick.dart';
import 'generation_mode.dart';

class GenerationSession {
  final String id;
  final DateTime createdAt;
  final GenerationMode requestedMode;
  final List<Fixture> fixtures;
  final List<GeneratedPick> picks;

  const GenerationSession({
    required this.id,
    required this.createdAt,
    required this.requestedMode,
    required this.fixtures,
    required this.picks,
  });

  GenerationSession copyWith({
    List<GeneratedPick>? picks,
  }) {
    return GenerationSession(
      id: id,
      createdAt: createdAt,
      requestedMode: requestedMode,
      fixtures: fixtures,
      picks: picks ?? this.picks,
    );
  }
}
