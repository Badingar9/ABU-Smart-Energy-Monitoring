/// Erreur d'authentification — ex. mot de passe actuel incorrect lors
/// d'un changement de mot de passe.
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
