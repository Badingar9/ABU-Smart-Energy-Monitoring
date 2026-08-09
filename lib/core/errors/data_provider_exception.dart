/// Exception dédiée à la couche DataProvider — permet à l'UI (étape 3)
/// de distinguer une erreur de source de données d'une autre erreur
/// applicative, sans dépendre de l'implémentation concrète (Fake/ScadaBR).
class DataProviderException implements Exception {
  final String message;
  final Object? cause;

  const DataProviderException(this.message, {this.cause});

  @override
  String toString() => 'DataProviderException: $message';
}
