import '../../models/building.dart';
import '../../models/control_action.dart';
import '../../models/energy_reading.dart';
import '../../models/equipment.dart';
import '../../models/threshold_config.dart';
import '../providers/data_provider.dart';

/// Point d'entrée unique pour tout ce qui touche aux bâtiments, équipements,
/// mesures, seuils et actions de contrôle. Les services et states ne
/// doivent jamais appeler DataProvider directement — toujours via ce
/// repository, quelle que soit l'implémentation (Fake ou ScadaBR).
class EnergyDataRepository {
  EnergyDataRepository(this._provider);
  final DataProvider _provider;

  List<Building> getBuildings() => _provider.getBuildings();

  List<Equipment> getEquipmentsForBuilding(String buildingId) =>
      _provider.getEquipmentsForBuilding(buildingId);

  Stream<EnergyReading> watchReadings() => _provider.watchReadings();

  List<EnergyReading> getHistory(
    String equipmentId, {
    DateTime? from,
    DateTime? to,
  }) => _provider.getHistory(equipmentId, from: from, to: to);

  List<ThresholdConfig> getThresholds(String equipmentId) =>
      _provider.getThresholds(equipmentId);

  void updateThreshold(ThresholdConfig config) =>
      _provider.updateThreshold(config);

  Future<ControlAction> sendControlCommand({
    required String equipmentId,
    required ControlActionType actionType,
    required ControlTrigger triggeredBy,
    String? userId,
    String? alertId,
  }) => _provider.sendControlCommand(
    equipmentId: equipmentId,
    actionType: actionType,
    triggeredBy: triggeredBy,
    userId: userId,
    alertId: alertId,
  );

  List<ControlAction> getControlActions() => _provider.getControlActions();

  void dispose() => _provider.dispose();
}
