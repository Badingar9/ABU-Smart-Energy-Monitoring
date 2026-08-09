import '../core/errors/permission_exception.dart';
import '../data/repositories/energy_data_repository.dart';
import '../models/control_action.dart';
import '../models/role.dart';
import '../models/user.dart';

/// Encapsule la vérification RBAC avant toute commande de contrôle
/// (UC-08/UC-09) — la validation "équipement contrôlable ?" reste côté
/// DataProvider (elle dépend de l'état réel de l'équipement), mais la
/// validation "cet utilisateur a-t-il le droit ?" est une règle métier
/// applicative, testable indépendamment du provider.
class ControlService {
  ControlService(this._repository);
  final EnergyDataRepository _repository;

  static const _allowedRoles = {RoleType.admin, RoleType.technician};

  Future<ControlAction> execute({
    required String equipmentId,
    required ControlActionType actionType,
    required AppUser requestingUser,
    String? alertId,
  }) async {
    if (!_allowedRoles.contains(requestingUser.role.type)) {
      throw PermissionException(
        '${requestingUser.fullName} (${requestingUser.role.label}) n\'a pas '
        'le droit d\'exécuter une action de contrôle.',
      );
    }

    return _repository.sendControlCommand(
      equipmentId: equipmentId,
      actionType: actionType,
      triggeredBy: ControlTrigger.user,
      userId: requestingUser.id,
      alertId: alertId,
    );
  }

  List<ControlAction> getControlActions() => _repository.getControlActions();
}
