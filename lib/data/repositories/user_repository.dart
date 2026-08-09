import 'package:collection/collection.dart';
import 'package:scada_app/core/errors/authentication_exception.dart';

import '../../core/errors/repository_exception.dart';
import '../../core/utils/id_generator.dart';
import '../../models/role.dart';
import '../../models/user.dart';

/// Gestion des utilisateurs — indépendante de DataProvider, car les comptes
/// applicatifs n'appartiennent pas au domaine SCADA (ScadaBR ne les gère
/// pas). Stockage en mémoire pour cette étape ; une future persistance
/// (Hive) pourra être branchée ici sans changer l'API du repository.
class UserRepository {
  UserRepository() {
    _seed();
  }

  final List<AppUser> _users = [];

  void _seed() {
    _users.addAll([
      AppUser(
        id: IdGenerator.generate('user'),
        fullName: 'Ibrahim Sani',
        email: 'ibrahim.sani@abu.edu.ng',
        role: Role(id: IdGenerator.generate('role'), type: RoleType.admin),
      ),
      AppUser(
        id: IdGenerator.generate('user'),
        fullName: 'Yusuf Danladi',
        email: 'yusuf.danladi@abu.edu.ng',
        role: Role(id: IdGenerator.generate('role'), type: RoleType.technician),
      ),
    ]);
  }

  List<AppUser> getUsers() => List.unmodifiable(_users);

  AppUser? findById(String id) => _users.firstWhereOrNull((u) => u.id == id);

  AppUser createUser({
    required String fullName,
    required String email,
    required RoleType roleType,
  }) {
    final user = AppUser(
      id: IdGenerator.generate('user'),
      fullName: fullName,
      email: email,
      role: Role(id: IdGenerator.generate('role'), type: roleType),
    );
    _users.add(user);
    return user;
  }

  void updateUser(AppUser updated) {
    final index = _users.indexWhere((u) => u.id == updated.id);
    if (index == -1) {
      throw RepositoryException('User introuvable pour id=${updated.id}');
    }
    _users[index] = updated;
  }

  void setStatus(String userId, UserStatus status) {
    final user = findById(userId);
    if (user == null) {
      throw RepositoryException('User introuvable pour id=$userId');
    }
    updateUser(user.copyWith(status: status));
  }

  // Stockage en mémoire uniquement — aucun vrai hash/salage à ce stade
  // (pas de backend), juste assez pour simuler le flux UC de sécurité.
  final Map<String, String> _passwordsByUserId = {};

  String? _currentPassword(String userId) =>
      _passwordsByUserId[userId] ?? 'password123'; // valeur par défaut de démo

  void changePassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) {
    final storedPassword = _currentPassword(userId);
    if (storedPassword != currentPassword) {
      throw const AuthenticationException('Current password is incorrect.');
    }
    if (newPassword.length < 8) {
      throw const AuthenticationException(
        'New password must be at least 8 characters.',
      );
    }
    _passwordsByUserId[userId] = newPassword;
  }
}
