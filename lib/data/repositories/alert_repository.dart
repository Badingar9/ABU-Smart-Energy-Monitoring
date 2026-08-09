import 'package:scada_app/models/alerts.dart';
import '../providers/data_provider.dart';

class AlertRepository {
  AlertRepository(this._provider);
  final DataProvider _provider;

  List<Alert> getAlerts() => _provider.getAlerts();

  List<Alert> getAlertsForEquipment(String equipmentId) =>
      _provider.getAlerts().where((a) => a.equipmentId == equipmentId).toList();

  void resolveAlert(
    String alertId, {
    required String resolvedBy,
    String? comment,
  }) =>
      _provider.resolveAlert(alertId, resolvedBy: resolvedBy, comment: comment);

  void acknowledgeAlert(String alertId, {required String acknowledgedBy}) =>
      _provider.acknowledgeAlert(alertId, acknowledgedBy: acknowledgedBy);
}
