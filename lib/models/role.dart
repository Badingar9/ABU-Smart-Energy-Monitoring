enum RoleType { admin, technician }

class Role {
  final String id;
  final RoleType type;

  const Role({required this.id, required this.type});

  String get label => type == RoleType.admin ? 'Administrateur' : 'Technicien';

  Role copyWith({String? id, RoleType? type}) =>
      Role(id: id ?? this.id, type: type ?? this.type);

  Map<String, dynamic> toJson() => {'id': id, 'type': type.name};

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['id'] as String,
    type: RoleType.values.byName(json['type'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Role && other.id == id && other.type == type);

  @override
  int get hashCode => Object.hash(id, type);
}
