import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/state/settings_state.dart';

class NotificationsCard extends StatelessWidget {
  final NotificationPreferences preferences;
  final ValueChanged<NotificationPreferences> onChanged;

  const NotificationsCard({
    super.key,
    required this.preferences,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: AppTypography.headlineMd),
          const SizedBox(height: 4),
          Text(
            'Choose which alerts should notify you.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Warning alerts'),
            subtitle: const Text(
              'Notify when a threshold warning is triggered',
            ),
            value: preferences.notifyOnWarning,
            activeColor: AppColors.primary,
            onChanged: (v) =>
                onChanged(preferences.copyWith(notifyOnWarning: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Critical alerts'),
            subtitle: const Text(
              'Notify when a critical threshold is exceeded',
            ),
            value: preferences.notifyOnCritical,
            activeColor: AppColors.primary,
            onChanged: (v) =>
                onChanged(preferences.copyWith(notifyOnCritical: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sound'),
            subtitle: const Text('Play a sound when a new alert arrives'),
            value: preferences.soundEnabled,
            activeColor: AppColors.primary,
            onChanged: (v) => onChanged(preferences.copyWith(soundEnabled: v)),
          ),
        ],
      ),
    );
  }
}
