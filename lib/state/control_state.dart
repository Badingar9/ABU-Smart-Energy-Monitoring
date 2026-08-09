import 'dart:async';
import 'package:flutter/foundation.dart';

import '../core/constants/simulation_constants.dart';
import '../models/control_action.dart';
import '../models/user.dart';
import '../services/control_service.dart';

/// Peut lever PermissionException (RBAC) — à capturer côté UI (étape 3),
/// par exemple pour afficher un message "action non autorisée".
class ControlState extends ChangeNotifier {
  ControlState(this._service) {
    _refreshTimer = Timer.periodic(
      SimulationConstants.tickInterval,
      (_) => notifyListeners(),
    );
  }

  final ControlService _service;
  Timer? _refreshTimer;

  List<ControlAction> get controlActions => _service.getControlActions();

  Future<ControlAction> sendCommand({
    required String equipmentId,
    required ControlActionType actionType,
    required AppUser requestingUser,
    String? alertId,
  }) async {
    final action = await _service.execute(
      equipmentId: equipmentId,
      actionType: actionType,
      requestingUser: requestingUser,
      alertId: alertId,
    );
    notifyListeners();
    return action;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
