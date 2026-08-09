import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/user.dart';

class AppTopBar extends StatelessWidget {
  final String dataSourceLabel; // "Simulated" en V1, dynamique à l'étape 5
  final AppUser? currentUser;

  const AppTopBar({
    super.key,
    required this.dataSourceLabel,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'ABU Smart Energy',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 24, color: AppColors.outlineVariant),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.statusSuccess,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Data Source: $dataSourceLabel',
                      style: AppTypography.labelData,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.sensors),
                color: AppColors.onSurfaceVariant,
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                    color: AppColors.onSurfaceVariant,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.statusCritical,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 32, color: AppColors.outlineVariant),
              const SizedBox(width: 12),
              if (currentUser != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currentUser!.fullName,
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      currentUser!.role.label,
                      style: AppTypography.labelData.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: const Icon(
                  Icons.person,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
