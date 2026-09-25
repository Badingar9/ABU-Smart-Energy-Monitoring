import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:scada_app/data/config/facilities_catalog.dart';

import '../data/repositories/energy_data_repository.dart';
import '../models/building.dart';
import '../models/energy_reading.dart';
import '../models/equipment.dart';
import '../models/threshold_config.dart';
import '../services/threshold_service.dart';

/// Ne gère plus que la télémétrie (bâtiments, équipements, mesures, seuils).
/// Les alertes et actions de contrôle vivent désormais dans AlertsState et
/// ControlState — évite un state trop large ("god file").
class EnergyDataState extends ChangeNotifier {
  EnergyDataState(this._repository)
    : _thresholdService = ThresholdService(_repository) {
    _buildings = _repository.getBuildings();
    _facilities = _repository.getFacilities();
    _subscription = _repository.watchReadings().listen(_onReading);
  }

  final EnergyDataRepository _repository;
  final ThresholdService _thresholdService;
  late final List<Building> _buildings;
  late final List<FacilitiesSpec> _facilities;
  late final StreamSubscription<EnergyReading> _subscription;

  final Map<String, EnergyReading> _latestReadingByEquipment = {};

  List<Building> get buildings => _buildings;
  List<FacilitiesSpec> get facilities => _facilities;

  List<FacilitiesSpec> facilitiesFor(String buildingId) => _repository.getFacilitiesForBuilding(buildingId);
  

  List<Equipment> equipmentsForBuilding(String buildingId) =>
      _repository.getEquipmentsForBuilding(buildingId);
  List<Equipment> equipmentsForFacility(String facilityId) =>
      _repository.getEquipmentsForFacilities(facilityId);

  EnergyReading? latestReadingFor(String equipmentId) =>
      _latestReadingByEquipment[equipmentId];

  List<EnergyReading> historyFor(
    String equipmentId, {
    DateTime? from,
    DateTime? to,
  }) => _repository.getHistory(equipmentId, from: from, to: to);

  List<ThresholdConfig> thresholdsFor(String equipmentId) =>
      _thresholdService.getThresholds(equipmentId);

  /// Peut lever ValidationException — à capturer côté UI (étape 3).
  void applyThreshold(ThresholdConfig config) {
    _thresholdService.applyThreshold(config);
    notifyListeners();
  }

  void _onReading(EnergyReading reading) {
    _latestReadingByEquipment[reading.equipmentId] = reading;
    notifyListeners();
  }

  /// Somme des puissances actives des équipements d'un bâtiment — vue
  /// agrégée nécessaire au Dashboard, qui affiche des totaux par bâtiment
  /// plutôt que par équipement individuel.
  double totalActivePowerForBuilding(String buildingId) {
    double total = 0;
    for (final equipment in equipmentsForBuilding(buildingId)) {
      total += latestReadingFor(equipment.id)?.energyKwh ?? 0;
    }
    return total;
  }

  /// Tendance de puissance agrégée sur les derniers points d'historique —
  /// alimente les sparklines. Somme élément par élément les historiques
  /// de chaque équipement du bâtiment, tronqués à la longueur commune la
  /// plus courte pour rester alignés dans le temps.
  List<double> buildingPowerTrend(String buildingId, {int points = 20}) {
    final histories = equipmentsForBuilding(
      buildingId,
    ).map((e) => historyFor(e.id)).where((h) => h.isNotEmpty).toList();
    if (histories.isEmpty) return const [];

    final minLength = histories
        .map((h) => h.length)
        .reduce((a, b) => a < b ? a : b);
    final trimmed = minLength < points ? minLength : points;
    if (trimmed == 0) return const [];

    final trend = List<double>.filled(trimmed, 0);
    for (final history in histories) {
      final slice = history.sublist(history.length - trimmed);
      for (var i = 0; i < trimmed; i++) {
        trend[i] += slice[i].activePower;
      }
    }
    return trend;
  }

  /// Facteur de puissance moyen des équipements actifs d'un bâtiment.
  double? averagePowerFactorForBuilding(String buildingId) {
    final factors = equipmentsForBuilding(buildingId)
        .map((e) => latestReadingFor(e.id)?.powerFactor)
        .whereType<double>()
        .toList();
    if (factors.isEmpty) return null;
    return factors.reduce((a, b) => a + b) / factors.length;
  }

  Building? findBuildingForEquipment(String buildingId) {
    for (final building in _buildings) {
      if (equipmentsForBuilding(building.id).any((e) => e.buildingId == buildingId )) {
        return building;
      }
      
    }
    return null;
  }
  FacilitiesSpec? findFacilityForEquipment(String facilityId) {
    for (final facility in _facilities) {
      if (equipmentsForFacility(facility.zone.toString()).any((e) => e.zone.toString() == facilityId)) {
        return facility;
      }
      
    }
    return null;
  }
  Building? findBuildingForFacility(String facilityId) {
    for (final building in _buildings) {
      if (facilitiesFor(building.id).any((e) => e.id == facilityId)) {
        return building;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    _repository.dispose();
    super.dispose();
  }
}
