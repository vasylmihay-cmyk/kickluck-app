class Team {
  final String id;
  final String name;
  final String shortName;
  final String? logoUrl;

  const Team({
    required this.id,
    required this.name,
    required this.shortName,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'logoUrl': logoUrl,
      };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      logoUrl: json['logoUrl'] as String?,
    );
  }
}
