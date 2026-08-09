/// Formatage relatif du temps ("2m ago", "1h ago") — réutilisable partout
/// où un horodatage doit s'afficher de façon lisible (Dashboard, History,
/// Alerts...).
String formatTimeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
