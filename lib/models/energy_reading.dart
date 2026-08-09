class EnergyReading {
  final String id;
  final String equipmentId;
  final double voltage;
  final double current;
  final double activePower;
  final double reactivePower;
  final double powerFactor;
  final double energyKwh;
  final DateTime timestamp;

  const EnergyReading({
    required this.id,
    required this.equipmentId,
    required this.voltage,
    required this.current,
    required this.activePower,
    required this.reactivePower,
    required this.powerFactor,
    required this.energyKwh,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipmentId': equipmentId,
    'voltage': voltage,
    'current': current,
    'activePower': activePower,
    'reactivePower': reactivePower,
    'powerFactor': powerFactor,
    'energyKwh': energyKwh,
    'timestamp': timestamp.toIso8601String(),
  };

  factory EnergyReading.fromJson(Map<String, dynamic> json) => EnergyReading(
    id: json['id'] as String,
    equipmentId: json['equipmentId'] as String,
    voltage: (json['voltage'] as num).toDouble(),
    current: (json['current'] as num).toDouble(),
    activePower: (json['activePower'] as num).toDouble(),
    reactivePower: (json['reactivePower'] as num).toDouble(),
    powerFactor: (json['powerFactor'] as num).toDouble(),
    energyKwh: (json['energyKwh'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is EnergyReading && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
