/// Générateur d'identifiants réutilisable dans tout le projet.
/// Centralisé ici pour ne pas disperser la logique de génération d'id
/// (utile aussi si on migre vers le package `uuid` plus tard — un seul
/// endroit à modifier).
class IdGenerator {
  IdGenerator._();

  static int _counter = 0;

  /// Génère un identifiant unique préfixé, lisible pour le débogage.
  /// Ex: generate('reading') -> "reading-1723   -42"
  static String generate(String prefix) {
    _counter++;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }
}
