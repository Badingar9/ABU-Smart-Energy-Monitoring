import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/data/config/facilities_catalog.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/energy_data_state.dart';

class BuildingListPanel extends StatefulWidget {
  final List<Building> buildings;
  final List<FacilitiesSpec> facilities;
  final String? selectedBuildingId;
  final String? selectedFacilityId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onSelectFacility;
  final EnergyDataState energy;
  final AlertsState alertsState;

  const BuildingListPanel({
    super.key,
    required this.buildings,
    required this.facilities,
    required this.selectedBuildingId,
    required this.selectedFacilityId,
    required this.onSelect,
    required this.onSelectFacility,
    required this.energy,
    required this.alertsState,
  });

  @override
  State<BuildingListPanel> createState() => _BuildingListPanelState();
}

class _BuildingListPanelState extends State<BuildingListPanel> {
  final Set<String> _expandedBuildings = {};

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
              itemCount: widget.buildings.length,
              itemBuilder: (context, index) {
                final building = widget.buildings[index];
                final isSelected = building.id == widget.selectedBuildingId;
                final equipmentIds = widget.energy
                    .equipmentsForBuilding(building.id)
                    .map((e) => e.id)
                    .toSet();
                final hasCritical = widget.alertsState.activeAlerts.any(
                  (a) =>
                      equipmentIds.contains(a.equipmentId) &&
                      a.severity == AlertSeverity.critical,
                );
                final hasWarning = widget.alertsState.activeAlerts.any(
                  (a) =>
                      equipmentIds.contains(a.equipmentId) &&
                      a.severity == AlertSeverity.warning,
                );
                final statusColor = hasCritical
                    ? AppColors.statusCritical
                    : hasWarning
                    ? AppColors.statusWarning
                    : AppColors.statusSuccess;

                return Column(
                  children: [
                    InkWell(
                      onTap: () => widget.onSelect(building.id),
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
                                    '${widget.energy.totalActivePowerForBuilding(building.id).toStringAsFixed(1)} kW',
                                    style: AppTypography.labelData.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Icon to open facilities
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_expandedBuildings.contains(
                                    building.id,
                                  )) {
                                    _expandedBuildings.remove(building.id);
                                  } else {
                                    _expandedBuildings.add(building.id);
                                  }
                                });
                              },
                              icon: Icon(
                                _expandedBuildings.contains(building.id)
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Facilities under building
                    if (_expandedBuildings.contains(building.id))
                      _buildingFacilities(building.id),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildingFacilities(String buildingId) {
    final buildingFacilities = widget.facilities
        .where((facility) => facility.buildingSpecId == buildingId)
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: buildingFacilities.map((facility) {
          final isSelected = facility.id == widget.selectedFacilityId;

          final facilityEquipments = widget.energy.equipmentsForFacility(
            facility.id,
          );

          final equipmentIds = facilityEquipments.map((e) => e.id).toSet();

          final hasCritical = widget.alertsState.activeAlerts.any(
            (a) =>
                equipmentIds.contains(a.equipmentId) &&
                a.severity == AlertSeverity.critical,
          );

          final hasWarning = widget.alertsState.activeAlerts.any(
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
            onTap: () {
              widget.onSelectFacility(facility.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              color: isSelected
                  ? AppColors.primaryContainer.withValues(alpha: 0.08)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  //-------------------------------------
                  //>>>>Ajouter Icon pour les facilities
                  //-------------------------------------

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      facility.zone.name,
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
                  ),

                  Text(
                    '${facilityEquipments.length}',
                    style: AppTypography.labelData.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
