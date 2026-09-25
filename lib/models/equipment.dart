enum EquipmentCategory { ac, lighting, socket, fan, chargingPoint, other }

enum Zone {
  office,
  library,
  laboratory,
  lectureHall,
  other;

  @override
  String toString() => name;
}

/// Élément électrique individuel supervisé à l'intérieur d'un bâtiment.
class Equipment {
  final String id;
  final String buildingId;
  final String name;
  final EquipmentCategory category;
  final Zone zone;
  final bool controllable;
  final String? relayAddress;
  final DateTime createdAt;
  final bool isConnected;

  const Equipment({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.category,
    required this.zone,
    this.controllable = false,
    this.relayAddress,
    required this.createdAt,
    this.isConnected = true,
  });

  Equipment copyWith({
    String? id,
    String? buildingId,
    String? name,
    EquipmentCategory? category,
    Zone? zone,
    bool? controllable,
    String? relayAddress,
    DateTime? createdAt,
    bool? isConnected,
  }) => Equipment(
    id: id ?? this.id,
    buildingId: buildingId ?? this.buildingId,
    name: name ?? this.name,
    category: category ?? this.category,
    zone: zone ?? this.zone,
    controllable: controllable ?? this.controllable,
    relayAddress: relayAddress ?? this.relayAddress,
    createdAt: createdAt ?? this.createdAt,
    isConnected: isConnected ?? this.isConnected,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'buildingId': buildingId,
    'name': name,
    'category': category.name,
    'zone': zone.name,
    'controllable': controllable,
    'relayAddress': relayAddress,
    'createdAt': createdAt.toIso8601String(),
    'isConnected': isConnected,
  };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
    id: json['id'] as String,
    buildingId: json['buildingId'] as String,
    name: json['name'] as String,
    category: EquipmentCategory.values.byName(json['category'] as String),
    zone: Zone.values.byName(json['zone']),
    controllable: json['controllable'] as bool,
    relayAddress: json['relayAddress'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isConnected: json['isConnected'] as bool,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Equipment && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
