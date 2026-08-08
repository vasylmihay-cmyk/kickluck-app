import '../../fixtures/domain/fixture.dart';
import 'generation_mode.dart';

class GeneratedPick {
  final Fixture fixture;
  final GenerationMode mode;
  final String outcome;
  final bool isLocked;

  const GeneratedPick({
    required this.fixture,
    required this.mode,
    required this.outcome,
    this.isLocked = false,
  });

  GeneratedPick copyWith({
    Fixture? fixture,
    GenerationMode? mode,
    String? outcome,
    bool? isLocked,
  }) {
    return GeneratedPick(
      fixture: fixture ?? this.fixture,
      mode: mode ?? this.mode,
      outcome: outcome ?? this.outcome,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'fixture': fixture.toJson(),
        'mode': mode.name,
        'outcome': outcome,
        'isLocked': isLocked,
      };

  factory GeneratedPick.fromJson(Map<String, dynamic> json) {
    return GeneratedPick(
      fixture: Fixture.fromJson(
        Map<String, dynamic>.from(json['fixture'] as Map),
      ),
      mode: GenerationMode.values.byName(json['mode'] as String),
      outcome: json['outcome'] as String,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}
