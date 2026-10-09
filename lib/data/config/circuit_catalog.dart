import 'package:scada_app/models/equipment.dart';

/// Un circuit simulé par le programme OpenPLC (une instance de CircuitSim).
///
/// Correspondance avec le PLC :
///   - 5 holding registers (FC3) à partir de [baseRegister] :
///       V (x10), I (x100), P (W), Q (var), PF (x1000)
///   - 1 coil à l'adresse [coilAddress] (1 = circuit coupé, 0 = normal)
///
/// Règle d'adressage : baseRegister = slot * 5 ; coilAddress = slot.
/// Slots : AC 0-7, Fans 8-15, Lighting 16-23, Sockets 24-31.
///
/// C'est ici, côté Flutter, que chaque circuit est rattaché à son bâtiment
/// et à sa zone : le PLC ne connaît ni l'un ni l'autre.
class CircuitSpec {
  const CircuitSpec({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.category,
    required this.zone,
    required this.slot,
    required this.nominalPowerKw,
    this.controllable = true,
  });

  /// Identique au préfixe des variables OpenPLC (ex. 'ac_office').
  final String id;
  final String buildingId;
  final String name;
  final EquipmentCategory category;
  final Zone zone;
  final int slot;

  /// Puissance nominale (kW), égale à p_nominal du PLC / 1000.
  /// Sert à fixer le seuil d'alerte de puissance (nominale x 1,2).
  final double nominalPowerKw;
  final bool controllable;

  int get baseRegister => slot * 5;
  int get coilAddress => slot;
}

/// Les 10 circuits actuellement déclarés dans le programme OpenPLC.
/// Tous appartiennent au département Computer Engineering ('b-cpe').
const kCircuitCatalog = <CircuitSpec>[
  // ---- AC : slots 0-7 ----
  CircuitSpec(
    id: 'ac_office',
    buildingId: 'b-cpe',
    name: 'AC Office',
    category: EquipmentCategory.ac,
    zone: Zone.office,
    slot: 0,
    nominalPowerKw: 2.2,
  ),
  CircuitSpec(
    id: 'ac_lib',
    buildingId: 'b-cpe',
    name: 'AC Library',
    category: EquipmentCategory.ac,
    zone: Zone.library,
    slot: 1,
    nominalPowerKw: 2.2, // à confirmer (valeur du PLC pour ac_lib)
  ),

  // ---- Fans : slots 8-15 ----
  CircuitSpec(
    id: 'fan_lab',
    buildingId: 'b-cpe',
    name: 'Fans Laboratory',
    category: EquipmentCategory.fan,
    zone: Zone.laboratory,
    slot: 8,
    nominalPowerKw: 0.75,
  ),
  CircuitSpec(
    id: 'fan_lib',
    buildingId: 'b-cpe',
    name: 'Fans Library',
    category: EquipmentCategory.fan,
    zone: Zone.library,
    slot: 9,
    nominalPowerKw: 0.75,
  ),

  // ---- Lighting : slots 16-23 ----
  CircuitSpec(
    id: 'light_office',
    buildingId: 'b-cpe',
    name: 'Lighting Office',
    category: EquipmentCategory.lighting,
    zone: Zone.office,
    slot: 16,
    nominalPowerKw: 0.04,
  ),
  CircuitSpec(
    id: 'light_lib',
    buildingId: 'b-cpe',
    name: 'Lighting Library',
    category: EquipmentCategory.lighting,
    zone: Zone.library,
    slot: 17,
    nominalPowerKw: 0.05,
  ),
  CircuitSpec(
    id: 'light_lab',
    buildingId: 'b-cpe',
    name: 'Lighting Laboratory',
    category: EquipmentCategory.lighting,
    zone: Zone.laboratory,
    slot: 18,
    nominalPowerKw: 0.05,
  ),

  // ---- Sockets : slots 24-31 ----
  CircuitSpec(
    id: 'socket_office',
    buildingId: 'b-cpe',
    name: 'Sockets Office',
    category: EquipmentCategory.socket,
    zone: Zone.office,
    slot: 24,
    nominalPowerKw: 3.68,
  ),
  CircuitSpec(
    id: 'socket_lib',
    buildingId: 'b-cpe',
    name: 'Sockets Library',
    category: EquipmentCategory.socket,
    zone: Zone.library,
    slot: 25,
    nominalPowerKw: 3.68,
  ),
  CircuitSpec(
    id: 'socket_lab',
    buildingId: 'b-cpe',
    name: 'Sockets Laboratory',
    category: EquipmentCategory.socket,
    zone: Zone.laboratory,
    slot: 26,
    nominalPowerKw: 3.68,
  ),
];