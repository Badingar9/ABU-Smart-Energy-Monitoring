import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/state/settings_state.dart';
import 'package:scada_app/state/user_state.dart';

import '../../widgets/settings/about_card.dart';
import '../../widgets/settings/appearance_card.dart';
import '../../widgets/settings/notifications_card.dart';
import '../../widgets/settings/security_card.dart';
import '../../widgets/shared/app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.settings,
      body: Consumer2<UsersState, SettingsState>(
        builder: (context, users, settings, _) {
          final currentUser =
              users.users.firstWhereOrNull(
                (u) => u.role.type == RoleType.admin,
              ) ??
              users.users.firstOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings', style: AppTypography.headlineLg),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your profile and application preferences.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    if (currentUser != null) ...[
                      // ProfileCard(user: currentUser, onSave: users.updateUser),
                      const SizedBox(height: AppSpacing.cardGap),
                      SecurityCard(
                        onChangePassword: (current, next) =>
                            users.changePassword(
                              currentUser.id,
                              currentPassword: current,
                              newPassword: next,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.cardGap),
                    ],
                    NotificationsCard(
                      preferences: settings.notifications,
                      onChanged: settings.updateNotifications,
                    ),
                    const SizedBox(height: AppSpacing.cardGap),
                    AppearanceCard(settings: settings),
                    const SizedBox(height: AppSpacing.cardGap),
                    const AboutCard(dataSourceLabel: 'Simulated'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
