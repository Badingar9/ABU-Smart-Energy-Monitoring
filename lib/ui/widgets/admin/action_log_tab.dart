import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/time_ago.dart';
import 'package:scada_app/models/control_action.dart';
import 'package:scada_app/state/energy_data_state.dart';

class ActionLogTab extends StatelessWidget {
  final List<ControlAction> actions;
  final EnergyDataState energy;

  const ActionLogTab({super.key, required this.actions, required this.energy});

  Color _resultColor(ControlResult result) {
    switch (result) {
      case ControlResult.success:
        return AppColors.statusSuccess;
      case ControlResult.failed:
        return AppColors.statusCritical;
      case ControlResult.timeout:
        return AppColors.statusWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...actions]
      ..sort((a, b) => b.executedAt.compareTo(a.executedAt));

    if (sorted.isEmpty) {
      return Center(
        child: Text(
          'No control actions recorded yet',
          style: AppTypography.bodySm,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      itemCount: sorted.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.outlineVariant, height: 1),
      itemBuilder: (context, index) {
        final action = sorted[index];
        final building = energy.findBuildingForEquipment(action.equipmentId);
        final equipment = energy
            .equipmentsFor(building?.id ?? '')
            .firstWhereOrNull((e) => e.id == action.equipmentId);
        final isDisconnect = action.actionType == ControlActionType.disconnect;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                isDisconnect ? Icons.power_off : Icons.power,
                color: isDisconnect
                    ? AppColors.statusCritical
                    : AppColors.statusSuccess,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isDisconnect ? "Disconnected" : "Reconnected"} — ${equipment?.name ?? "Unknown equipment"}',
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${building?.name ?? "Unknown building"} · Triggered by ${action.triggeredBy.name}'
                      '${action.userId != null ? " (${action.userId})" : ""}',
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
                  color: _resultColor(action.result).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  action.result.name.toUpperCase(),
                  style: AppTypography.labelCaps.copyWith(
                    color: _resultColor(action.result),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatTimeAgo(action.executedAt),
                style: AppTypography.labelData.copyWith(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
