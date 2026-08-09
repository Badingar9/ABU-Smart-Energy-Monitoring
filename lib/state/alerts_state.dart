import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:scada_app/models/alerts.dart';

import '../core/constants/simulation_constants.dart';
import '../services/alert_service.dart';

/// Les alertes sont générées en interne par le DataProvider (pas de flux
/// dédié à ce stade) : ce state se rafraîchit périodiquement au même rythme
/// que la simulation pour rester à jour. Une vraie souscription réactive
/// pourra remplacer ce Timer à l'étape 5 (ScadaBRProvider).
class AlertsState extends ChangeNotifier {
  AlertsState(this._service) {
    _refreshTimer = Timer.periodic(
      SimulationConstants.tickInterval,
      (_) => notifyListeners(),
    );
  }

  final AlertService _service;
  Timer? _refreshTimer;

  List<Alert> get activeAlerts => _service.getActiveAlerts();

  List<AlertGroup> get groupedAlerts => _service.getGroupedAlerts();

  List<Alert> get allAlerts => _service.getAllAlerts();

  void acknowledge(String alertId, {required String acknowledgedBy}) {
    _service.acknowledge(alertId, acknowledgedBy: acknowledgedBy);
    notifyListeners();
  }

  List<Alert> alertsForEquipment(String equipmentId) =>
      _service.getAlertsForEquipment(equipmentId);

  void resolve(String alertId, {required String resolvedBy, String? comment}) {
    _service.resolve(alertId, resolvedBy: resolvedBy, comment: comment);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
