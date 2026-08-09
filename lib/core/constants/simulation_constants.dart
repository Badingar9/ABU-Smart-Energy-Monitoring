/// Constantes de simulation, centralisées pour éviter les "nombres magiques"
/// dispersés dans le code — modifiables en un seul endroit.
class SimulationConstants {
  SimulationConstants._();

  /// Intervalle entre deux cycles de génération de mesures.
  /// Conforme à l'indicateur de succès #1 du SRS (1 à 5 secondes).
  static const Duration tickInterval = Duration(seconds: 2);

  /// Amplitude de variation aléatoire autour de la valeur de base (10%).
  static const double powerVariationRatio = 0.10;

  /// Tension nominale de référence (V), utilisée comme centre de simulation.
  static const double nominalVoltage = 220.0;

  /// Amplitude de variation de tension autour du nominal (V).
  static const double voltageVariationRange = 20.0;

  /// Facteur de puissance simulé, plage réaliste.
  static const double minPowerFactor = 0.90;
  static const double maxPowerFactor = 0.98;
}
