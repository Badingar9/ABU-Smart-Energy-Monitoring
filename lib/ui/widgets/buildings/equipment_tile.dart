import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/control_action.dart';
import 'package:scada_app/models/energy_reading.dart';
import 'package:scada_app/models/equipment.dart';
import 'package:scada_app/models/user.dart';

IconData iconForCategory(EquipmentCategory category) {
  switch (category) {
    case EquipmentCategory.ac:
      return Icons.ac_unit;
    case EquipmentCategory.lighting:
      return Icons.lightbulb_outline;
    case EquipmentCategory.socket:
      return Icons.power_outlined;
    case EquipmentCategory.fan:
      return Icons.air;
    case EquipmentCategory.chargingPoint:
      return Icons.ev_station_outlined;
    case EquipmentCategory.other:
      return Icons.electrical_services;
  }
}

/// Ligne d'équipement avec contrôle marche/arrêt. Double confirmation
/// obligatoire avant toute commande (UC-08 manuel / UC-09) — aucune action
/// de coupure ne part sans un dialogue de confirmation explicite.
class EquipmentTile extends StatelessWidget {
  final Equipment equipment;
  final EnergyReading? latestReading;
  final AppUser? requestingUser;
  final Future<void> Function(ControlActionType actionType) onControl;

  const EquipmentTile({
    super.key,
    required this.equipment,
    required this.latestReading,
    required this.requestingUser,
    required this.onControl,
  });

  Future<void> _confirmAndExecute(
    BuildContext context,
    ControlActionType actionType,
  ) async {
    final isDisconnect = actionType == ControlActionType.disconnect;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isDisconnect ? 'Confirm disconnection' : 'Confirm reconnection',
        ),
        content: Text(
          'Are you sure you want to ${isDisconnect ? "disconnect" : "reconnect"} "${equipment.name}"? '
          '${isDisconnect ? "This will cut power to this equipment only." : "This will restore power to this equipment."}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: isDisconnect
                  ? AppColors.statusCritical
                  : AppColors.primary,
            ),
            child: Text(isDisconnect ? 'Disconnect' : 'Reconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await onControl(actionType);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: equipment.isConnected
                  ? AppColors.surfaceContainerHigh
                  : AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconForCategory(equipment.category),
              color: equipment.isConnected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  latestReading == null
                      ? 'No data yet'
                      : '${latestReading!.activePower.toStringAsFixed(2)} kW · ${latestReading!.voltage.toStringAsFixed(0)} V',
                  style: AppTypography.labelData.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (equipment.isConnected
                          ? AppColors.statusSuccess
                          : AppColors.statusCritical)
                      .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              equipment.isConnected ? 'ACTIVE' : 'DISCONNECTED',
              style: AppTypography.labelCaps.copyWith(
                fontSize: 10,
                color: equipment.isConnected
                    ? AppColors.statusSuccess
                    : AppColors.statusCritical,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (equipment.controllable)
            OutlinedButton(
              onPressed: () => _confirmAndExecute(
                context,
                equipment.isConnected
                    ? ControlActionType.disconnect
                    : ControlActionType.reconnect,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: equipment.isConnected
                    ? AppColors.statusCritical
                    : AppColors.primary,
                side: BorderSide(
                  color: equipment.isConnected
                      ? AppColors.statusCritical
                      : AppColors.primary,
                ),
              ),
              child: Text(equipment.isConnected ? 'Disconnect' : 'Reconnect'),
            )
          else
            Text(
              'Not controllable',
              style: AppTypography.labelData.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
