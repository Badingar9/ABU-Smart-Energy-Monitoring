import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/energy_data_state.dart';

class BuildingListPanel extends StatelessWidget {
  final List<Building> buildings;
  final String? selectedBuildingId;
  final ValueChanged<String> onSelect;
  final EnergyDataState energy;
  final AlertsState alertsState;

  const BuildingListPanel({
    super.key,
    required this.buildings,
    required this.selectedBuildingId,
    required this.onSelect,
    required this.energy,
    required this.alertsState,
  });

  IconData _iconFor(BuildingType type) {
    switch (type) {
      case BuildingType.office:
        return Icons.account_balance;
      case BuildingType.classroom:
        return Icons.school;
      case BuildingType.laboratory:
        return Icons.engineering;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Text('Buildings', style: AppTypography.headlineMd),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: buildings.length,
              itemBuilder: (context, index) {
                final building = buildings[index];
                final isSelected = building.id == selectedBuildingId;
                final equipmentIds = energy
                    .equipmentsFor(building.id)
                    .map((e) => e.id)
                    .toSet();
                final hasCritical = alertsState.activeAlerts.any(
                  (a) =>
                      equipmentIds.contains(a.equipmentId) &&
                      a.severity == AlertSeverity.critical,
                );
                final hasWarning = alertsState.activeAlerts.any(
                  (a) =>
                      equipmentIds.contains(a.equipmentId) &&
                      a.severity == AlertSeverity.warning,
                );
                final statusColor = hasCritical
                    ? AppColors.statusCritical
                    : hasWarning
                    ? AppColors.statusWarning
                    : AppColors.statusSuccess;

                return InkWell(
                  onTap: () => onSelect(building.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.containerPadding,
                      vertical: 12,
                    ),
                    color: isSelected
                        ? AppColors.primaryContainer.withValues(alpha: 0.08)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(
                          _iconFor(building.type),
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                building.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMd.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                                ),
                              ),
                              Text(
                                '${energy.totalActivePowerForBuilding(building.id).toStringAsFixed(1)} kW',
                                style: AppTypography.labelData.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
