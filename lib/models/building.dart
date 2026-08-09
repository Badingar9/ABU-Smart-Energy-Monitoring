enum BuildingType { office, classroom, laboratory }

class Building {
  final String id;
  final String name;
  final BuildingType type;
  final DateTime createdAt;

  const Building({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  Building copyWith({
    String? id,
    String? name,
    BuildingType? type,
    DateTime? createdAt,
  }) => Building(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    id: json['id'] as String,
    name: json['name'] as String,
    type: BuildingType.values.byName(json['type'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Building && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
