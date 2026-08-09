import '../core/errors/validation_exception.dart';
import '../data/repositories/energy_data_repository.dart';
import '../models/threshold_config.dart';

/// Logique de validation des seuils, indépendante du provider — testable
/// isolément (étape 4) sans dépendre de FakeDataProvider ni de ScadaBR.
class ThresholdService {
  ThresholdService(this._repository);
  final EnergyDataRepository _repository;

  List<ThresholdConfig> getThresholds(String equipmentId) =>
      _repository.getThresholds(equipmentId);

  /// Valide puis applique une nouvelle configuration de seuil (UC-04).
  void applyThreshold(ThresholdConfig config) {
    _validate(config);
    _repository.updateThreshold(config);
  }

  void _validate(ThresholdConfig config) {
    if (config.minValue == null && config.maxValue == null) {
      throw const ValidationException(
        'Un seuil doit définir au moins une valeur minimale ou maximale.',
      );
    }
    if (config.minValue != null &&
        config.maxValue != null &&
        config.minValue! >= config.maxValue!) {
      throw const ValidationException(
        'La valeur minimale doit être strictement inférieure à la valeur maximale.',
      );
    }
    if ((config.minValue != null && config.minValue! < 0) ||
        (config.maxValue != null && config.maxValue! < 0)) {
      throw const ValidationException(
        'Les valeurs de seuil ne peuvent pas être négatives.',
      );
    }
  }
}
