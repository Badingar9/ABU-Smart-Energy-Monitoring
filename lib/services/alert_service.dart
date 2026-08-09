import 'package:scada_app/models/alerts.dart';

import '../data/repositories/alert_repository.dart';

/// Vue agrégée d'une alerte répétée : occurrenceCount > 1 signale un
/// "flapping" (UC-03, scénario alternatif A1 du SRS).
class AlertGroup {
  final Alert latest;
  final int occurrenceCount;
  const AlertGroup({required this.latest, required this.occurrenceCount});
}

class AlertService {
  AlertService(
    this._repository, {
    this.flappingWindow = const Duration(minutes: 5),
  });

  final AlertRepository _repository;
  final Duration flappingWindow;

  List<Alert> getActiveAlerts() => _repository
      .getAlerts()
      .where((a) => a.status != AlertStatus.resolved)
      .toList();

  /// Toutes les alertes, y compris résolues — nécessaire pour l'écran de
  /// gestion (filtre "Resolved"), contrairement à getActiveAlerts().
  List<Alert> getAllAlerts() => _repository.getAlerts();

  void acknowledge(String alertId, {required String acknowledgedBy}) =>
      _repository.acknowledgeAlert(alertId, acknowledgedBy: acknowledgedBy);

  List<Alert> getAlertsForEquipment(String equipmentId) =>
      _repository.getAlertsForEquipment(equipmentId);

  /// Regroupe les alertes répétées (même équipement + même grandeur) dans
  /// une fenêtre glissante, pour éviter la surcharge de notifications.
  List<AlertGroup> getGroupedAlerts() {
    final active = getActiveAlerts()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, AlertGroup>{};

    for (final alert in active) {
      final baseKey = '${alert.equipmentId}-${alert.metric.name}';
      final existing = groups[baseKey];

      if (existing == null) {
        groups[baseKey] = AlertGroup(latest: alert, occurrenceCount: 1);
        continue;
      }

      final withinWindow =
          existing.latest.createdAt.difference(alert.createdAt).abs() <=
          flappingWindow;

      if (withinWindow) {
        groups[baseKey] = AlertGroup(
          latest: existing.latest,
          occurrenceCount: existing.occurrenceCount + 1,
        );
      } else {
        // Hors fenêtre : occurrence indépendante, clé distincte pour ne
        // pas l'écraser.
        groups['$baseKey-${alert.id}'] = AlertGroup(
          latest: alert,
          occurrenceCount: 1,
        );
      }
    }

    return groups.values.toList();
  }

  void resolve(String alertId, {required String resolvedBy, String? comment}) =>
      _repository.resolveAlert(
        alertId,
        resolvedBy: resolvedBy,
        comment: comment,
      );
}
