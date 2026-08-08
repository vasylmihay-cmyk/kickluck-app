enum HistoryActionType { generated, regenerated, saved }

class HistoryEntry {
  final String id;
  final DateTime timestamp;
  final HistoryActionType action;
  final int matchCount;
  final String modeLabel;

  const HistoryEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.matchCount,
    required this.modeLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'action': action.name,
        'matchCount': matchCount,
        'modeLabel': modeLabel,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: HistoryActionType.values.byName(json['action'] as String),
      matchCount: json['matchCount'] as int,
      modeLabel: json['modeLabel'] as String,
    );
  }
}
