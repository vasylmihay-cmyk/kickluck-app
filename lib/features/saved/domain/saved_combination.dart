import '../../generator/domain/generated_pick.dart';

class SavedCombination {
  final String id;
  final DateTime createdAt;
  final List<GeneratedPick> picks;

  const SavedCombination({
    required this.id,
    required this.createdAt,
    required this.picks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'picks': picks.map((e) => e.toJson()).toList(),
      };

  factory SavedCombination.fromJson(Map<String, dynamic> json) {
    return SavedCombination(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      picks: (json['picks'] as List)
          .map((e) => GeneratedPick.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }
}
