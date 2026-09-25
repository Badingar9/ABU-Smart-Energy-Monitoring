import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/state/energy_data_state.dart';

class AdminBuildingsTab extends StatelessWidget {
  final EnergyDataState energy;

  const AdminBuildingsTab({super.key, required this.energy});

  IconData _iconFor(BuildingType type) {
    switch (type) {
      case BuildingType.office:
        return Icons.account_balance;
      case BuildingType.classroom:
        return Icons.school;
      case BuildingType.laboratory:
        return Icons.engineering;
      case BuildingType.department:
        return Icons.business;
      case BuildingType.faculty:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Building creation is not yet supported — this view is read-only until the data provider exposes it.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: energy.buildings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final building = energy.buildings[index];
                final equipments = energy.equipmentsForBuilding(building.id);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.borderMuted),
                  ),
                  child: Row(
                    children: [
                      Icon(_iconFor(building.type), color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              building.name,
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${equipments.length} equipment(s)',
                              style: AppTypography.labelData.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${energy.totalActivePowerForBuilding(building.id).toStringAsFixed(1)} kW',
                        style: AppTypography.headlineMd,
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
