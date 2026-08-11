/// Formatage d'heure courte (HH:mm:ss) — utilisé par le tableau
/// d'historique où l'horodatage précis compte plus qu'un temps relatif.
String formatTime(DateTime dateTime) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(dateTime.hour)}:${two(dateTime.minute)}:${two(dateTime.second)}';
}
