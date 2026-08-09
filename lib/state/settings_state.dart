import 'package:flutter/material.dart';

enum AppLanguage { english, french }

extension AppLanguageX on AppLanguage {
  String get label => this == AppLanguage.english ? 'English' : 'Français';
}

/// Préférences de notification — locales à l'app pour l'instant, sans
/// vraie intégration son/push (à ajouter si un jour un vrai backend de
/// notification est branché, cf. section 8.4 du SRS).
class NotificationPreferences {
  final bool notifyOnWarning;
  final bool notifyOnCritical;
  final bool soundEnabled;

  const NotificationPreferences({
    this.notifyOnWarning = true,
    this.notifyOnCritical = true,
    this.soundEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? notifyOnWarning,
    bool? notifyOnCritical,
    bool? soundEnabled,
  }) => NotificationPreferences(
    notifyOnWarning: notifyOnWarning ?? this.notifyOnWarning,
    notifyOnCritical: notifyOnCritical ?? this.notifyOnCritical,
    soundEnabled: soundEnabled ?? this.soundEnabled,
  );
}

class SettingsState extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;
  NotificationPreferences _notifications = const NotificationPreferences();

  AppLanguage get language => _language;
  NotificationPreferences get notifications => _notifications;

  void setLanguage(AppLanguage language) {
    if (language == _language) return;
    _language = language;
    notifyListeners();
  }

  void updateNotifications(NotificationPreferences updated) {
    _notifications = updated;
    notifyListeners();
  }
}
