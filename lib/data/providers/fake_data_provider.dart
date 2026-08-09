import 'dart:async';
import 'dart:math';

import 'package:scada_app/models/alerts.dart';

import '../../core/constants/simulation_constants.dart';
import '../../core/errors/data_provider_exception.dart';
import '../../core/utils/id_generator.dart';
import '../../models/building.dart';
import '../../models/control_action.dart';
import '../../models/energy_reading.dart';
import '../../models/equipment.dart';
import '../../models/threshold_config.dart';
import 'data_provider.dart';

/// Simulateur de données, conforme au périmètre resserré du SRS (section
/// 10.3) : un bâtiment pilote avec un jeu d'équipements contrôlables,
/// plus quelques bâtiments simples sans granularité, pour illustrer le
/// dashboard global.
class FakeDataProvider implements DataProvider {
  FakeDataProvider() {
    _seedBuildingsAndEquipments();
    _seedThresholds();
    _startSimulation();
  }

  final Random _random = Random();
  final StreamController<EnergyReading> _readingsController =
      StreamController<EnergyReading>.broadcast();

  final List<Building> _buildings = [];
  final List<Equipment> _equipments = [];
  final Map<String, double> _basePowerByEquipment = {};
  final Map<String, List<EnergyReading>> _historyByEquipment = {};
  final List<ThresholdConfig> _thresholds = [];
  final List<Alert> _alerts = [];
  final List<ControlAction> _controlActions = [];
  final Map<String, DateTime> _lastResolvedAtByKey = {};
  static const _resolutionCooldown = Duration(seconds: 30);

  Timer? _timer;

  // ---------------------------------------------------------------------
  // Initialisation des données de démonstration
  // ---------------------------------------------------------------------

  void _seedBuildingsAndEquipments() {
    final now = DateTime.now();

    final officeComplex = Building(
      id: 'b-001',
      name: 'Office Complex',
      type: BuildingType.office,
      createdAt: now,
    );
    final scienceLab2 = Building(
      id: 'b-002',
      name: 'Science Lab',
      type: BuildingType.laboratory,
      createdAt: now,
    );
    final lectureHall = Building(
      id: 'b-003',
      name: 'Main Lecture Hall',
      type: BuildingType.classroom,
      createdAt: now,
    );

    _buildings.addAll([officeComplex, scienceLab2, lectureHall]);

    // Bâtiment pilote (Science Lab 2) : équipements individuels contrôlables,
    // conformément au périmètre resserré défini en section 10.3 du SRS.
    _addEquipment(
      buildingId: scienceLab2.id,
      name: 'AC — Office 3',
      category: EquipmentCategory.ac,
      controllable: true,
      relayAddress: 'coil-101',
      basePowerKw: 3.2,
    );
    _addEquipment(
      buildingId: scienceLab2.id,
      name: 'Fans — Room 12',
      category: EquipmentCategory.fan,
      controllable: true,
      relayAddress: 'coil-102',
      basePowerKw: 0.8,
    );
    _addEquipment(
      buildingId: scienceLab2.id,
      name: 'Socket — Office 7',
      category: EquipmentCategory.socket,
      controllable: true,
      relayAddress: 'coil-103',
      basePowerKw: 0.5,
    );

    _addEquipment(
      buildingId: officeComplex.id,
      name: 'Lighting — Ground Floor',
      category: EquipmentCategory.lighting,
      controllable: true,
      relayAddress: 'coil-201',
      basePowerKw: 60.0,
    );
    _addEquipment(
      buildingId: officeComplex.id,
      name: 'Sockets — Admin Wing',
      category: EquipmentCategory.socket,
      controllable: true,
      relayAddress: 'coil-202',
      basePowerKw: 120.0,
    );
    _addEquipment(
      buildingId: officeComplex.id,
      name: 'AC — Server Room',
      category: EquipmentCategory.ac,
      controllable: true,
      relayAddress: 'coil-203',
      basePowerKw: 180.0,
    );
    _addEquipment(
      buildingId: officeComplex.id,
      name: 'Elevator',
      category: EquipmentCategory.other,
      controllable: true,
      relayAddress: 'coil-204',
      basePowerKw: 52.5,
    );
    _addEquipment(
      buildingId: lectureHall.id,
      name: 'Lighting — Hall',
      category: EquipmentCategory.lighting,
      controllable: true,
      relayAddress: 'coil-301',
      basePowerKw: 20.0,
    );
    _addEquipment(
      buildingId: lectureHall.id,
      name: 'Projector & AV',
      category: EquipmentCategory.other,
      controllable: true,
      relayAddress: 'coil-302',
      basePowerKw: 8.8,
    );
    _addEquipment(
      buildingId: lectureHall.id,
      name: 'Ceiling Fans',
      category: EquipmentCategory.fan,
      controllable: true,
      relayAddress: 'coil-303',
      basePowerKw: 14.0,
    );
    _addEquipment(
      buildingId: lectureHall.id,
      name: 'Sockets',
      category: EquipmentCategory.socket,
      controllable: true,
      relayAddress: 'coil-304',
      basePowerKw: 50.0,
    );
  }

  void _addEquipment({
    required String buildingId,
    required String name,
    required EquipmentCategory category,
    required double basePowerKw,
    bool controllable = false,
    String? relayAddress,
  }) {
    final equipment = Equipment(
      id: IdGenerator.generate('equipment'),
      buildingId: buildingId,
      name: name,
      category: category,
      controllable: controllable,
      relayAddress: relayAddress,
      createdAt: DateTime.now(),
    );
    _equipments.add(equipment);
    _basePowerByEquipment[equipment.id] = basePowerKw;
    _historyByEquipment[equipment.id] = [];
  }

  void _seedThresholds() {
    for (final equipment in _equipments) {
      final basePower = _basePowerByEquipment[equipment.id]!;

      _thresholds.add(
        ThresholdConfig(
          id: IdGenerator.generate('threshold'),
          equipmentId: equipment.id,
          metric: AlertMetric.voltage,
          minValue: 215,
          maxValue: 225,
          severity: AlertSeverity.critical,
          autoAction: AutoAction.alertOnly,
        ),
      );

      _thresholds.add(
        ThresholdConfig(
          id: IdGenerator.generate('threshold'),
          equipmentId: equipment.id,
          metric: AlertMetric.power,
          maxValue: basePower * 1.05,
          severity: AlertSeverity.warning,
          // Coupure automatique uniquement sur les équipements contrôlables
          // du bâtiment pilote (UC-08).
          autoAction: equipment.controllable
              ? AutoAction.autoDisconnect
              : AutoAction.alertOnly,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------
  // Simulation périodique
  // ---------------------------------------------------------------------

  void _startSimulation() {
    _timer = Timer.periodic(SimulationConstants.tickInterval, (_) {
      for (var i = 0; i < _equipments.length; i++) {
        final equipment = _equipments[i];
        if (!equipment.isConnected) continue;

        final reading = _generateReading(equipment);
        _historyByEquipment[equipment.id]!.add(reading);
        _evaluateThresholds(equipment, reading);
        _readingsController.add(reading);
      }
    });
  }

  EnergyReading _generateReading(Equipment equipment) {
    final basePower = _basePowerByEquipment[equipment.id]!;
    final variation =
        (_random.nextDouble() - 0.5) *
        2 *
        SimulationConstants.powerVariationRatio;
    final activePower = basePower * (1 + variation);

    final voltage =
        SimulationConstants.nominalVoltage +
        (_random.nextDouble() - 0.5) *
            SimulationConstants.voltageVariationRange;

    final current = (activePower * 1000) / (voltage * 0.95);

    final powerFactor =
        SimulationConstants.minPowerFactor +
        _random.nextDouble() *
            (SimulationConstants.maxPowerFactor -
                SimulationConstants.minPowerFactor);

    final historyLength = _historyByEquipment[equipment.id]?.length ?? 0;
    final tickHours = SimulationConstants.tickInterval.inSeconds / 3600;

    return EnergyReading(
      id: IdGenerator.generate('reading'),
      equipmentId: equipment.id,
      voltage: voltage,
      current: current,
      activePower: activePower,
      reactivePower: activePower * 0.3,
      powerFactor: powerFactor,
      energyKwh: historyLength * activePower * tickHours,
      timestamp: DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------
  // Évaluation des seuils et génération d'alertes (UC-03, UC-08)
  // ---------------------------------------------------------------------

  void _evaluateThresholds(Equipment equipment, EnergyReading reading) {
    final configs = _thresholds
        .where((t) => t.equipmentId == equipment.id)
        .toList();

    for (final config in configs) {
      final value = _extractMetricValue(config.metric, reading);
      final exceeded =
          (config.maxValue != null && value > config.maxValue!) ||
          (config.minValue != null && value < config.minValue!);

      if (!exceeded) continue;

      final key = '${equipment.id}-${config.metric.name}';

      // 1. Une alerte ACTIVE existe déjà pour ce couple équipement/grandeur
      //    → ne pas en recréer une deuxième en double.
      final alreadyActive = _alerts.any(
        (a) =>
            a.equipmentId == equipment.id &&
            a.metric == config.metric &&
            a.status != AlertStatus.resolved,
      );
      if (alreadyActive) continue;

      // 2. Une alerte vient d'être résolue récemment pour ce couple
      //    → laisser un délai de grâce avant d'en générer une nouvelle.
      final lastResolvedAt = _lastResolvedAtByKey[key];
      if (lastResolvedAt != null &&
          DateTime.now().difference(lastResolvedAt) < _resolutionCooldown) {
        continue;
      }

      final alert = Alert(
        id: IdGenerator.generate('alert'),
        equipmentId: equipment.id,
        metric: config.metric,
        severity: config.severity,
        measuredValue: value,
        thresholdValue: config.maxValue ?? config.minValue!,
        createdAt: reading.timestamp,
      );
      _alerts.add(alert);

      if (config.autoAction == AutoAction.autoDisconnect &&
          equipment.controllable) {
        // ignore: unawaited_futures
        sendControlCommand(
          equipmentId: equipment.id,
          actionType: ControlActionType.disconnect,
          triggeredBy: ControlTrigger.system,
          alertId: alert.id,
        );
      }
    }
  }

  double _extractMetricValue(AlertMetric metric, EnergyReading reading) {
    switch (metric) {
      case AlertMetric.voltage:
        return reading.voltage;
      case AlertMetric.current:
        return reading.current;
      case AlertMetric.power:
        return reading.activePower;
      case AlertMetric.powerFactor:
        return reading.powerFactor;
    }
  }

  // ---------------------------------------------------------------------
  // Implémentation de l'interface DataProvider
  // ---------------------------------------------------------------------

  @override
  List<Building> getBuildings() => List.unmodifiable(_buildings);

  @override
  List<Equipment> getEquipmentsForBuilding(String buildingId) => _equipments
      .where((e) => e.buildingId == buildingId)
      .toList(growable: false);

  @override
  Stream<EnergyReading> watchReadings() => _readingsController.stream;

  @override
  List<EnergyReading> getHistory(
    String equipmentId, {
    DateTime? from,
    DateTime? to,
  }) {
    final all = _historyByEquipment[equipmentId] ?? [];
    return all
        .where((r) {
          if (from != null && r.timestamp.isBefore(from)) return false;
          if (to != null && r.timestamp.isAfter(to)) return false;
          return true;
        })
        .toList(growable: false);
  }

  @override
  List<ThresholdConfig> getThresholds(String equipmentId) => _thresholds
      .where((t) => t.equipmentId == equipmentId)
      .toList(growable: false);

  @override
  void updateThreshold(ThresholdConfig config) {
    final index = _thresholds.indexWhere((t) => t.id == config.id);
    if (index == -1) {
      throw DataProviderException(
        'ThresholdConfig introuvable pour id=${config.id}',
      );
    }
    _thresholds[index] = config;
  }

  @override
  List<Alert> getAlerts() => List.unmodifiable(_alerts);

  @override
  void resolveAlert(
    String alertId, {
    required String resolvedBy,
    String? comment,
  }) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw DataProviderException('Alert introuvable pour id=$alertId');
    }
    final alert = _alerts[index];
    _alerts[index] = alert.copyWith(
      status: AlertStatus.resolved,
      resolvedAt: DateTime.now(),
      resolvedBy: resolvedBy,
      comment: comment,
    );

    // Enregistre le moment de résolution pour activer le délai de grâce.
    final key = '${alert.equipmentId}-${alert.metric.name}';
    _lastResolvedAtByKey[key] = DateTime.now();
  }

  @override
  Future<ControlAction> sendControlCommand({
    required String equipmentId,
    required ControlActionType actionType,
    required ControlTrigger triggeredBy,
    String? userId,
    String? alertId,
  }) async {
    final equipmentIndex = _equipments.indexWhere((e) => e.id == equipmentId);
    if (equipmentIndex == -1) {
      throw DataProviderException('Equipment introuvable pour id=$equipmentId');
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final equipment = _equipments[equipmentIndex];
    ControlResult result;

    if (!equipment.controllable) {
      result = ControlResult.failed;
    } else {
      // Equipment étant désormais immuable : on remplace l'entrée via copyWith.
      _equipments[equipmentIndex] = equipment.copyWith(
        isConnected: actionType == ControlActionType.reconnect,
      );
      result = ControlResult.success;
    }

    final action = ControlAction(
      id: IdGenerator.generate('control'),
      equipmentId: equipmentId,
      alertId: alertId,
      actionType: actionType,
      triggeredBy: triggeredBy,
      userId: userId,
      executedAt: DateTime.now(),
      result: result,
    );

    _controlActions.add(action);
    return action;
  }

  @override
  List<ControlAction> getControlActions() => List.unmodifiable(_controlActions);

  @override
  void dispose() {
    _timer?.cancel();
    _readingsController.close();
  }

  @override
  void acknowledgeAlert(String alertId, {required String acknowledgedBy}) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) return;

    final alert = _alerts[index];
    if (alert.status != AlertStatus.active) return; // déjà traité, no-op

    _alerts[index] = alert.copyWith(
      status: AlertStatus.inProgress,
      acknowledgedAt: DateTime.now(),
      acknowledgedBy: acknowledgedBy,
    );
  }
}
