import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/alert_filters.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/role.dart';
import 'package:scada_app/models/user.dart';
import 'package:scada_app/state/alerts_state.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/state/user_state.dart';

import '../../widgets/alerts/alert_detail_panel.dart';
import '../../widgets/alerts/alert_filter_bar.dart';
import '../../widgets/shared/alert_row.dart';
import '../../widgets/shared/app_shell.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  SeverityFilter _severity = SeverityFilter.all;
  StatusFilter _status = StatusFilter.all;
  String? _buildingId;
  String? _selectedAlertId;
  AppUser? _actingUser;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.alerts,
      body: Consumer3<EnergyDataState, AlertsState, UsersState>(
        builder: (context, energy, alertsState, users, _) {
          _actingUser ??= users.users.firstWhereOrNull(
            (u) => u.role.type == RoleType.technician,
          );

          final filtered = alertsState.allAlerts.where((a) {
            if (!_severity.matches(a.severity)) return false;
            if (!_status.matches(a.status)) return false;
            if (_buildingId != null) {
              final building = energy.findBuildingForEquipment(a.equipmentId);
              if (building?.id != _buildingId) return false;
            }
            return true;
          }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final selectedAlert =
              filtered.firstWhereOrNull((a) => a.id == _selectedAlertId) ??
              (filtered.isNotEmpty ? filtered.first : null);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alerts', style: AppTypography.headlineLg),
                      const SizedBox(height: 4),
                      Text(
                        '${filtered.length} alert(s) matching current filters',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AlertFilterBar(
                        severity: _severity,
                        status: _status,
                        buildingId: _buildingId,
                        buildings: energy.buildings,
                        onSeverityChanged: (v) => setState(() => _severity = v),
                        onStatusChanged: (v) => setState(() => _status = v),
                        onBuildingChanged: (v) =>
                            setState(() => _buildingId = v),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'No alerts match these filters',
                                  style: AppTypography.bodySm,
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final alert = filtered[index];
                                  final building = energy
                                      .findBuildingForEquipment(
                                        alert.equipmentId,
                                      );
                                  final equipment = energy
                                      .equipmentsForBuilding(building?.id ?? '')
                                      .firstWhereOrNull(
                                        (e) => e.id == alert.equipmentId,
                                      );

                                  return AlertRow(
                                    data: AlertRowData(
                                      alert: alert,
                                      buildingName:
                                          building?.name ?? 'Unknown building',
                                      equipmentName:
                                          equipment?.name ??
                                          'Unknown equipment',
                                    ),
                                    selected: alert.id == selectedAlert?.id,
                                    onTap: () => setState(
                                      () => _selectedAlertId = alert.id,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 380,
                child: selectedAlert == null
                    ? Center(
                        child: Text(
                          'Select an alert',
                          style: AppTypography.bodySm,
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final building = energy.findBuildingForEquipment(
                            selectedAlert.equipmentId,
                          );
                          final equipment = energy
                              .equipmentsForBuilding(building?.id ?? '')
                              .firstWhereOrNull(
                                (e) => e.id == selectedAlert.equipmentId,
                              );

                          return AlertDetailPanel(
                            key: ValueKey(selectedAlert.id),
                            alert: selectedAlert,
                            buildingName: building?.name ?? 'Unknown building',
                            equipmentName:
                                equipment?.name ?? 'Unknown equipment',
                            actingUsers: users.users,
                            actingUser: _actingUser,
                            onActingUserChanged: (user) =>
                                setState(() => _actingUser = user),
                            onAcknowledge: (acknowledgedBy) =>
                                alertsState.acknowledge(
                                  selectedAlert.id,
                                  acknowledgedBy: acknowledgedBy,
                                ),
                            onResolve: (resolvedBy, comment) =>
                                alertsState.resolve(
                                  selectedAlert.id,
                                  resolvedBy: resolvedBy,
                                  comment: comment,
                                ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
