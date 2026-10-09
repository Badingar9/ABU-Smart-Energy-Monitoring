import 'dart:async';

import 'package:modbus_client/modbus_client.dart';
import 'package:scada_app/core/errors/data_provider_exception.dart';
import 'package:scada_app/core/utils/id_generator.dart';
import 'package:scada_app/data/config/circuit_catalog.dart';
import 'package:scada_app/data/config/equipment_catalog.dart';
import 'package:scada_app/data/config/facilities_catalog.dart';
import 'package:scada_app/data/modbus/equipement_registers.dart';
import 'package:scada_app/data/modbus/modbus_tcp_client.dart';
import 'package:scada_app/data/providers/data_provider.dart';
import 'package:scada_app/models/alerts.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/models/control_action.dart';
import 'package:scada_app/models/energy_reading.dart';
import 'package:scada_app/models/equipment.dart';
import 'package:scada_app/models/threshold_config.dart';

class RealDataProvider implements DataProvider {
  RealDataProvider({required ModbusTcpClient modbusClient})
    : _modbusClient = modbusClient {
    _seedBuildingsAndEquipments();
    _seedThresholds();
    _startPolling();
  }
  final ModbusTcpClient _modbusClient;
  final StreamController<EnergyReading> _readingsController =
      StreamController<EnergyReading>.broadcast();

  static const acOfficeBaseAddress = 0;
  static const acLibBaseAddress = 5;

  static const fansLabBaseAddress = 40;
  static const fansLibBaseAddress = 45;
  
  static const lightingOfficeBaseAddress = 80;
  static const lightingLibBaseAddress = 85;
  static const lightingLabBaseAddress = 90;

  static const socketOfficeBaseAddress = 120;
  static const socketLibBaseAddress = 125;
  static const socketLabBaseAddress = 130;
  

  static const _maxHistoryPoints = 3600;

  final List<Building> _buildings = [];
  final List<FacilitiesSpec> _facilities = [];
  final List<Equipment> _equipments = [];
  final List<ThresholdConfig> _thresholds = [];
  final List<Alert> _alerts = [];
  final List<ControlAction> _controlActions = [];

  final Map<String, List<EnergyReading>> _historyByEquipment = {};
  final Map<String, DateTime> _lastResolvedAtByKey = {};
  final Map<String, EquipementRegisters> _registersByEquipmentId = {};
  final Map<String, double> _nominalPowerKwByEquipmentId = {};


  /// Circuit OpenPLC (registres + coil) de chaque équipement.
  /// Servira à écrire le coil dans sendControlCommand.
  final Map<String, CircuitSpec> _circuitByEquipmentId = {};

  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _disposed = false;

  static const _resolutionCooldown = Duration(seconds: 30);

  //=========INITIALISATION================

  void _seedBuildingsAndEquipments() {
    final now = DateTime.now();

    //==============Add Buildings===================
    for (final b in kBuildingCatalog) {
      _buildings.add(
        Building(id: b.id, name: b.name, type: b.type, createdAt: now),
      );
    }

    //==============Add Equipments (un par circuit OpenPLC)==============
    for (final circuit in kCircuitCatalog) {
      _addEquipment(circuit);
    }
 
    _createFacility();

  }

  //=======Facilities function to add

  void _addEquipment(CircuitSpec circuit) {
    final equipment = Equipment(
      id: IdGenerator.generate('eq'),
      buildingId: circuit.buildingId,
      name: circuit.name,
      category: circuit.category,
      zone: circuit.zone,
      controllable: circuit.controllable,
      relayAddress: 'coil-${circuit.coilAddress}',
      createdAt: DateTime.now(),
    );

    _equipments.add(equipment);
    _historyByEquipment[equipment.id] = [];
    _nominalPowerKwByEquipmentId[equipment.id] = circuit.nominalPowerKw;
    _registersByEquipmentId[equipment.id] = EquipementRegisters(
      circuit.id,
      circuit.baseRegister,
    );
  }

  void _createFacility() {
    _facilities.clear();

    final grouped = <String, List<Equipment>>{};

    for (final eq in _equipments) {
      final key = '${eq.buildingId}-${eq.zone.name}';
      grouped.putIfAbsent(key, () => []).add(eq);
      }

      for (final entry in grouped.entries) {
        final equipments = entry.value;
        final firstEquipment = equipments.first;

        _facilities.add(
          FacilitiesSpec(
            id: '${firstEquipment.buildingId}-${firstEquipment.zone.name}',
            title: firstEquipment.zone.name,
            buildingSpecId: firstEquipment.buildingId,
            zone: firstEquipment.zone,
            equipments: List.unmodifiable(equipments),
          ),
        );
      }
    
  }

  //=========Modbus Polling==============

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _pollOpenPlc();
    });
  }

  Future<void> _pollOpenPlc() async {
    if (_disposed) return;
    if (_isPolling) return;

    _isPolling = true;

    try {
      final listOfAllRegisters = _registersByEquipmentId.values
          .expand((registers) => registers.allRegisters)
          .toList();

      final responseCode = await _modbusClient.readRegisters(
        listOfAllRegisters,
      );

      if (_disposed) return;

      if (responseCode != ModbusResponseCode.requestSucceed) {
        throw DataProviderException(
          'Error reading registers: ${responseCode.name}',
        );
      }
      _processReadings();
    } catch (e) {
      if (!_disposed) {
        print('Error occured, RealDataProvider: ${e.toString()}');
      }
    } finally {
      _isPolling = false;
    }
  }

  void _processReadings() {
    for (final entry in _registersByEquipmentId.entries) {
      final equipmentId = entry.key;
      final registers = entry.value;

      final equipmentIndex = _equipments.indexWhere((e) => e.id == equipmentId);

      if (equipmentIndex == -1) {
        print('❌ Equipment not found: $equipmentId');
        continue;
      }

      final equipment = _equipments[equipmentIndex];

      final voltage = registers.voltage.value?.toDouble();
      final current = registers.current.value?.toDouble();
      final activePower = registers.activePower.value?.toDouble();
      final reactivePower = registers.reactivePower.value?.toDouble();
      final powerFactor = registers.powerFactor.value?.toDouble();

      

      if (voltage == null ||
          current == null ||
          activePower == null ||
          reactivePower == null ||
          powerFactor == null) {
        print(
          'Warning: One or more register values are null for equipmentId=$equipmentId',
        );
        continue;
      }

      final powerKw = activePower.toDouble(); // Convert to kW
      final energyKwh = _calculateEnergy(equipmentId, powerKw);

      final reading = EnergyReading(
        id: IdGenerator.generate('read'),
        equipmentId: equipmentId,
        voltage: voltage,
        current: current,
        activePower: activePower,
        reactivePower: reactivePower,
        powerFactor: powerFactor,
        energyKwh: energyKwh,
        timestamp: DateTime.now(),
      );

      _historyByEquipment[equipmentId]!.add(reading);

      final h = _historyByEquipment[equipmentId]!;
      if (h.length > _maxHistoryPoints) {
        h.removeRange(0, h.length - _maxHistoryPoints);
      }

      _evaluateThresholds(equipment, reading);

      _readingsController.add(reading);
    }
  }

  double _calculateEnergy(String equipmentId, double activePower) {
    final history = _historyByEquipment[equipmentId];

    if (history == null || history.isEmpty) {
      return 0;
    }
    final previous = history.last;
    final elapsedHours = DateTime.now()
        .difference(previous.timestamp)
        .inMilliseconds;
    if (elapsedHours > 5000) {
      return previous.energyKwh;
    }

    return previous.energyKwh +
        (activePower * elapsedHours) / 3600000; // Convert milliseconds to hours
  }

  //============Thresholds=================

  void _seedThresholds() {
    for (final equipment in _equipments) {
      _thresholds.add(
        ThresholdConfig(
          id: IdGenerator.generate('threshold'),
          equipmentId: equipment.id,
          metric: AlertMetric.voltage,
          minValue: 207,
          maxValue: 253,
          severity: AlertSeverity.critical,
          autoAction: AutoAction.alertOnly,
        ),
      );

      final nominalPowerKw = _nominalPowerKwByEquipmentId[equipment.id] ?? 0.0;

      _thresholds.add(
        ThresholdConfig(
          id: IdGenerator.generate('threshold'),
          equipmentId: equipment.id,
          metric: AlertMetric.power,
          maxValue: nominalPowerKw > 0 ? nominalPowerKw * 1.2 : 0.0,
          severity: AlertSeverity.warning,
          autoAction: equipment.controllable
              ? AutoAction.autoDisconnect
              : AutoAction.alertOnly,
        ),
      );
    }
  }

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

      final alreadyActive = _alerts.any(
        (a) =>
            a.equipmentId == equipment.id &&
            a.metric == config.metric &&
            a.status != AlertStatus.resolved,
      );

      if (alreadyActive) continue;

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

    print('Alert sur : ${alert.equipmentId}');
    print(_equipments.where((e)=> e.id==alert.equipmentId).first.name);
      _alerts.add(alert);

      if (config.autoAction == AutoAction.autoDisconnect &&
          equipment.controllable) {
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

  //======================================================
  //  DATA PROVIDER
  //======================================================

  @override
  void acknowledgeAlert(String alertId, {required String acknowledgedBy}) {
    final index = _alerts.indexWhere((a) => a.id == alertId);

    if (index == -1) return;

    final alert = _alerts[index];

    if (alert.status != AlertStatus.active) return;

    _alerts[index] = alert.copyWith(
      status: AlertStatus.inProgress,
      acknowledgedAt: DateTime.now(),
      acknowledgedBy: acknowledgedBy,
    );
  }

  @override
  List<Alert> getAlerts() {
    return List.unmodifiable(_alerts);
  }

  @override
  List<Building> getBuildings() {
    return List.unmodifiable(_buildings);
  }

  @override
  List<ControlAction> getControlActions() {
    return List.unmodifiable(_controlActions);
  }

  @override
  List<Equipment> getEquipmentsForBuilding(String buildingId) {
    return _equipments
        .where((e) => e.buildingId == buildingId)
        .toList(growable: false);
  }

  @override
  List<EnergyReading> getHistory(
    String equipmentId, {
    DateTime? from,
    DateTime? to,
  }) {
    final history = _historyByEquipment[equipmentId] ?? [];

    return history
        .where((reading) {
          if (from != null && reading.timestamp.isBefore(from)) {
            return false;
          }
          if (to != null && reading.timestamp.isAfter(to)) {
            return false;
          }

          return true;
        })
        .toList(growable: false);
  }

  @override
  List<ThresholdConfig> getThresholds(String equipmentId) {
    return _thresholds
        .where((t) => t.equipmentId == equipmentId)
        .toList(growable: false);
  }

  @override
  void resolveAlert(
    String alertId, {
    required String resolvedBy,
    String? comment,
  }) {
    final index = _alerts.indexWhere((a) => a.id == alertId);

    if (index == -1) {
      throw DataProviderException('Alert not found for id=$alertId');
    }

    final alert = _alerts[index];

    _alerts[index] = alert.copyWith(
      status: AlertStatus.resolved,
      resolvedAt: DateTime.now(),
      resolvedBy: resolvedBy,
      comment: comment,
    );

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
    final index = _equipments.indexWhere((e) => e.id == equipmentId);
    final circuit = _circuitByEquipmentId[equipmentId];

    if (index == -1 || circuit == null) {
      throw DataProviderException('Equipment introuvable pour id=$equipmentId');
    }

    // Convention PLC : coil = 1 -> circuit coupé, coil = 0 -> circuit normal.
    final coilValue = actionType == ControlActionType.disconnect;

    ControlResult result;
    try {
      final code = await _modbusClient
          .writeCoil(circuit.coilAddress, coilValue)
          .timeout(const Duration(seconds: 3));

      result = code == ModbusResponseCode.requestSucceed
          ? ControlResult.success
          : ControlResult.failed;
    } on TimeoutException {
      result = ControlResult.timeout;
    } catch (_) {
      result = ControlResult.failed;
    }

    // L'état local n'est mis à jour que si le PLC a accepté l'écriture.
    if (result == ControlResult.success) {
      _equipments[index] = _equipments[index].copyWith(
        isConnected: !coilValue,
      );
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
  void updateThreshold(ThresholdConfig config) {
    final index = _thresholds.indexWhere((t) => t.id == config.id);

    if (index == -1) {
      throw DataProviderException(
        'Threshold configuration not found for id=${config.id}',
      );
    }

    _thresholds[index] = config;
  }

  @override
  Stream<EnergyReading> watchReadings() {
    return _readingsController.stream;
  }

  @override
  void dispose() {
    _disposed = true;
    _pollingTimer?.cancel();
    _readingsController.close();
    _modbusClient.disconnect();
  }

  @override
  List<FacilitiesSpec> getFacilities() {
    return List.unmodifiable(_facilities);
  }

  @override
  List<FacilitiesSpec> getFacilitiesForBuilding(String buildingId) {
    return _facilities
        .where((facility) => facility.buildingSpecId == buildingId)
        .toList();
  }

  @override
  List<Equipment> getEquipmentsForFacility(String facilityId) {
    final facility = _facilities.firstWhere((f) => f.id == facilityId);

    return _equipments
        .where(
          (eq) =>
              eq.buildingId == facility.buildingSpecId &&
              eq.zone == facility.zone,
        )
        .toList(growable: false);
  }
}
