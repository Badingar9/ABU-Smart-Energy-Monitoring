import 'package:scada_app/data/config/facilities_catalog.dart';
import 'package:scada_app/models/alerts.dart';

import '../../models/building.dart';
import '../../models/equipment.dart';
import '../../models/energy_reading.dart';
import '../../models/threshold_config.dart';
import '../../models/control_action.dart';

/// Contrat commun à toute source de données. FakeDataProvider (aujourd'hui)
/// et ScadaBRProvider (étape 5) l'implémentent tous les deux à l'identique,
/// ce qui permet de basculer l'un vers l'autre sans toucher au reste du
/// code (UC-07 du SRS).
abstract class DataProvider {
  List<Building> getBuildings();
  List<FacilitiesSpec> getFacilities();

  List<FacilitiesSpec> getFacilitiesForBuilding(String buildingId);

  List<Equipment> getEquipmentsForBuilding(String buildingId);
  List<Equipment> getEquipmentsForFacility(String facilityId);

  /// Flux continu de nouvelles mesures, tous équipements confondus.
  Stream<EnergyReading> watchReadings();

  List<EnergyReading> getHistory(
    String equipmentId, {
    DateTime? from,
    DateTime? to,
  });

  List<ThresholdConfig> getThresholds(String equipmentId);

  void updateThreshold(ThresholdConfig config);

  List<Alert> getAlerts();

  void resolveAlert(
    String alertId, {
    required String resolvedBy,
    String? comment,
  });

  /// Passe une alerte active en "en cours de traitement" (UC-03). N'a
  /// aucun effet si l'alerte est déjà résolue ou introuvable — silencieux
  /// plutôt qu'exception, car acquitter une alerte déjà traitée n'est pas
  /// une erreur bloquante côté UI.
  void acknowledgeAlert(String alertId, {required String acknowledgedBy});

  /// Coupe ou rétablit un équipement précis (UC-08/UC-09).
  /// Retourne l'action journalisée, y compris en cas d'échec.
  Future<ControlAction> sendControlCommand({
    required String equipmentId,
    required ControlActionType actionType,
    required ControlTrigger triggeredBy,
    String? userId,
    String? alertId,
  });

  List<ControlAction> getControlActions();

  void dispose();
}
