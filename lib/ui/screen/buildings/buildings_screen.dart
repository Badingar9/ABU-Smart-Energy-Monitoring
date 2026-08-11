import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/metric_label.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/models/user.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/control_state.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/state/user_state.dart';
import 'package:scada_app/ui/widgets/buildings/building_list_panel.dart';
import 'package:scada_app/ui/widgets/buildings/equipment_tile.dart';
import 'package:scada_app/ui/widgets/buildings/thresolds_field_card.dart';

import '../../widgets/dashboard/sparkline_chart.dart';
import '../../widgets/shared/alert_row.dart';
import '../../widgets/shared/app_shell.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedBuildingId;
  String? _selectedEquipmentIdForHistory;
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.buildings,
      body: Consumer4<EnergyDataState, AlertsState, ControlState, UsersState>(
        builder: (context, energy, alertsState, controlState, users, _) {
          final buildings = energy.buildings;
          _selectedBuildingId ??= buildings.isNotEmpty
              ? buildings.first.id
              : null;
          final selectedBuilding = buildings.firstWhereOrNull(
            (b) => b.id == _selectedBuildingId,
          );
          final technician = users.users.firstWhereOrNull(
            (u) => u.role.type == RoleType.technician,
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BuildingListPanel(
                buildings: buildings,
                selectedBuildingId: _selectedBuildingId,
                energy: energy,
                alertsState: alertsState,
                onSelect: (id) => setState(() {
                  _selectedBuildingId = id;
                  _selectedEquipmentIdForHistory = null;
                  _tabController.index = 0;
                }),
              ),
              Expanded(
                child: selectedBuilding == null
                    ? const Center(child: Text('No building available'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                              AppSpacing.containerPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedBuilding.name,
                                  style: AppTypography.headlineLg,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${energy.totalActivePowerForBuilding(selectedBuilding.id).toStringAsFixed(1)} kW total consumption',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.onSurfaceVariant,
                            indicatorColor: AppColors.primary,
                            tabAlignment: TabAlignment.start,
                            tabs: const [
                              Tab(text: 'Overview'),
                              Tab(text: 'History'),
                              Tab(text: 'Thresholds & Alerts'),
                            ],
                          ),
                          const Divider(
                            height: 1,
                            color: AppColors.outlineVariant,
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(
                                  energy,
                                  controlState,
                                  selectedBuilding.id,
                                  technician,
                                ),
                                _buildHistoryTab(energy, selectedBuilding.id),
                                _buildThresholdsTab(
                                  energy,
                                  alertsState,
                                  selectedBuilding.id,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(
    EnergyDataState energy,
    ControlState controlState,
    String buildingId,
    AppUser? technician,
  ) {
    final equipments = energy.equipmentsFor(buildingId);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      children: [
        for (final equipment in equipments)
          EquipmentTile(
            equipment: equipment,
            latestReading: energy.latestReadingFor(equipment.id),
            requestingUser: technician,
            onControl: (actionType) async {
              if (technician == null) return;
              await controlState.sendCommand(
                equipmentId: equipment.id,
                actionType: actionType,
                requestingUser: technician,
              );
            },
          ),
      ],
    );
  }

  Widget _buildHistoryTab(EnergyDataState energy, String buildingId) {
    final equipments = energy.equipmentsFor(buildingId);
    _selectedEquipmentIdForHistory ??= equipments.isNotEmpty
        ? equipments.first.id
        : null;
    final selectedEquipment = equipments.firstWhereOrNull(
      (e) => e.id == _selectedEquipmentIdForHistory,
    );
    final history = selectedEquipment == null
        ? <double>[]
        : energy
              .historyFor(selectedEquipment.id)
              .map((r) => r.activePower)
              .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: _selectedEquipmentIdForHistory,
            items: [
              for (final e in equipments)
                DropdownMenuItem(value: e.id, child: Text(e.name)),
            ],
            onChanged: (id) =>
                setState(() => _selectedEquipmentIdForHistory = id),
          ),
          const SizedBox(height: 16),
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              border: Border.all(color: AppColors.outlineVariant),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: history.length < 2
                ? Center(
                    child: Text(
                      'Not enough data yet',
                      style: AppTypography.bodySm,
                    ),
                  )
                : SparklineChart(values: history, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdsTab(
    EnergyDataState energy,
    AlertsState alertsState,
    String buildingId,
  ) {
    final buildingName =
        energy.buildings.firstWhereOrNull((b) => b.id == buildingId)?.name ??
        '';
    final equipments = energy.equipmentsFor(buildingId);
    final equipmentIds = equipments.map((e) => e.id).toSet();
    final relatedAlerts = alertsState.activeAlerts
        .where((a) => equipmentIds.contains(a.equipmentId))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      children: [
        Text('Thresholds', style: AppTypography.headlineMd),
        const SizedBox(height: 12),
        for (final equipment in equipments) ...[
          Text(
            equipment.name,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          for (final config in energy.thresholdsFor(equipment.id)) ...[
            Builder(
              builder: (context) {
                final (label, unit) = metricLabelAndUnit(config.metric);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ThresholdFieldCard(
                    config: config,
                    metricLabel: label,
                    unit: unit,
                    onApply: (updated) => energy.applyThreshold(updated),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 16),
        ],
        const Divider(color: AppColors.outlineVariant),
        const SizedBox(height: 16),
        Text('Alerts', style: AppTypography.headlineMd),
        const SizedBox(height: 12),
        if (relatedAlerts.isEmpty)
          Text(
            'No active alerts for this building.',
            style: AppTypography.bodySm,
          )
        else
          for (final alert in relatedAlerts) ...[
            AlertRow(
              data: AlertRowData(
                alert: alert,
                buildingName: buildingName,
                equipmentName:
                    equipments
                        .firstWhereOrNull((e) => e.id == alert.equipmentId)
                        ?.name ??
                    'Unknown',
              ),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
