import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/user.dart';

import 'create_user_dialog.dart';

class UsersTab extends StatelessWidget {
  final List<AppUser> users;
  final void Function(String fullName, String email, dynamic role) onCreateUser;
  final void Function(String userId, UserStatus status) onSetStatus;

  const UsersTab({
    super.key,
    required this.users,
    required this.onCreateUser,
    required this.onSetStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${users.length} user(s)',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              FilledButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => CreateUserDialog(onCreate: onCreateUser),
                ),
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('New user'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: AppColors.outlineVariant, height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                final isActive = user.status == UserStatus.active;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              user.email,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          user.role.label,
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) => onSetStatus(
                          user.id,
                          v ? UserStatus.active : UserStatus.inactive,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
