import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/state/user_state.dart';
import 'package:scada_app/ui/screen/alerts/alerts_screen.dart';

import '../../widgets/dashboard/active_alerts_panel.dart';
import '../../widgets/dashboard/building_metric_card.dart';
import '../../widgets/dashboard/featured_building_card.dart';
import '../../widgets/shared/alert_row.dart';
import '../../widgets/shared/app_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  IconData _iconForBuilding(BuildingType type) {
    switch (type) {
      case BuildingType.office:
        return Icons.account_balance;
      case BuildingType.classroom:
        return Icons.school;
      case BuildingType.laboratory:
        return Icons.engineering;
    }
  }

  BuildingCardStatus _statusFor(int criticalCount, int warningCount) {
    if (criticalCount > 0) return BuildingCardStatus.critical;
    if (warningCount > 0) return BuildingCardStatus.warning;
    return BuildingCardStatus.nominal;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.dashboard,
      body: Consumer2<EnergyDataState, AlertsState>(
        builder: (context, energy, alertsState, _) {
          final buildings = energy.buildings;
          final pilotBuilding = buildings.firstWhere(
            (b) => energy.equipmentsFor(b.id).any((e) => e.controllable),
            orElse: () => buildings.first,
          );
          final regularBuildings = buildings
              .where((b) => b.id != pilotBuilding.id)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Flex(
              direction: MediaQuery.of(context).size.width > 1100
                  ? Axis.horizontal
                  : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overview', style: AppTypography.headlineLg),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time power consumption across primary campus facilities.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.cardGap),
                      GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 700
                            ? 2
                            : 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.cardGap,
                        crossAxisSpacing: AppSpacing.cardGap,
                        childAspectRatio: 1.1,
                        children: [
                          for (final building in regularBuildings)
                            _buildRegularCard(energy, alertsState, building),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.cardGap),
                      _buildFeaturedCard(energy, pilotBuilding),
                    ],
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.cardGap,
                  height: AppSpacing.cardGap,
                ),
                SizedBox(
                  width: 360,
                  child: _buildAlertsPanel(context, energy, alertsState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegularCard(
    EnergyDataState energy,
    AlertsState alertsState,
    Building building,
  ) {
    final equipmentIds = energy
        .equipmentsFor(building.id)
        .map((e) => e.id)
        .toSet();
    final buildingAlerts = alertsState.activeAlerts.where(
      (a) => equipmentIds.contains(a.equipmentId),
    );
    final criticalCount = buildingAlerts
        .where((a) => a.severity == AlertSeverity.critical)
        .length;
    final warningCount = buildingAlerts
        .where((a) => a.severity == AlertSeverity.warning)
        .length;

    return BuildingMetricCard(
      buildingName: building.name,
      icon: _iconForBuilding(building.type),
      activePowerKw: energy.totalActivePowerForBuilding(building.id),
      trend: energy.buildingPowerTrend(building.id),
      status: _statusFor(criticalCount, warningCount),
      alertCount: criticalCount + warningCount,
    );
  }

  Widget _buildFeaturedCard(EnergyDataState energy, Building pilotBuilding) {
    final trend = energy.buildingPowerTrend(pilotBuilding.id, points: 20);
    final trendPercent = trend.length >= 2 && trend.first != 0
        ? ((trend.last - trend.first) / trend.first) * 100
        : 0.0;

    return FeaturedBuildingCard(
      buildingName: pilotBuilding.name,
      icon: _iconForBuilding(pilotBuilding.type),
      activePowerKw: energy.totalActivePowerForBuilding(pilotBuilding.id),
      trendPercent: trendPercent,
      trendProvider: (points) =>
          energy.buildingPowerTrend(pilotBuilding.id, points: points),
      peakDemandKw: trend.isEmpty
          ? null
          : trend.reduce((a, b) => a > b ? a : b),
      powerFactor: energy.averagePowerFactorForBuilding(pilotBuilding.id),
    );
  }

  Widget _buildAlertsPanel(
    BuildContext context,
    EnergyDataState energy,
    AlertsState alertsState,
  ) {
    final grouped = alertsState.groupedAlerts
      ..sort((a, b) => b.latest.createdAt.compareTo(a.latest.createdAt));

    final rows = grouped.take(5).map((group) {
      final building = energy.findBuildingForEquipment(
        group.latest.equipmentId,
      );
      final equipment = energy
          .equipmentsFor(building?.id ?? '')
          .firstWhereOrNull((e) => e.id == group.latest.equipmentId);
      return AlertRowData(
        alert: group.latest,
        buildingName: building?.name ?? 'Unknown building',
        equipmentName: equipment?.name ?? 'Unknown equipment',
        occurrenceCount: group.occurrenceCount,
      );
    }).toList();

    return ActiveAlertsPanel(
      alerts: rows,
      totalCount: alertsState.activeAlerts.length,
      onAcknowledge: (alertId) {
        final technician = context.read<UsersState>().users.firstWhereOrNull(
          (u) => u.role.type == RoleType.technician,
        );
        if (technician == null) return;
        alertsState.acknowledge(alertId, acknowledgedBy: technician.fullName);
      },
      onViewAll: () {
        final shell = context.findAncestorWidgetOfExactType<AppShell>();
        if (shell != null) {
          shell.navigate(context, AppRoute.alerts);
          debugPrint('Navigating to alerts screen via AppShell');
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AlertsScreen()),
          );
          debugPrint('Navigating to alerts screen via Navigator');
        }
      },
    );
  }
}
