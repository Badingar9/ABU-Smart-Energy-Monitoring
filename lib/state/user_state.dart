import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';
import '../models/role.dart';
import '../models/user.dart';

/// Support de l'UC-05 (gestion des utilisateurs et rôles), pour l'écran
/// Admin à venir en étape 3.
class UsersState extends ChangeNotifier {
  UsersState(this._repository);
  final UserRepository _repository;

  List<AppUser> get users => _repository.getUsers();

  AppUser createUser({
    required String fullName,
    required String email,
    required RoleType roleType,
  }) {
    final user = _repository.createUser(
      fullName: fullName,
      email: email,
      roleType: roleType,
    );
    notifyListeners();
    return user;
  }

  void setStatus(String userId, UserStatus status) {
    _repository.setStatus(userId, status);
    notifyListeners();
  }

  void changePassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) {
    _repository.changePassword(
      userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
