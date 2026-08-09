import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/time_ago.dart';
import 'package:scada_app/models/alerts.dart';
import 'package:scada_app/models/threshold_config.dart';

class AlertRowData {
  final Alert alert;
  final String buildingName;
  final String equipmentName;
  final int occurrenceCount;

  const AlertRowData({
    required this.alert,
    required this.buildingName,
    required this.equipmentName,
    this.occurrenceCount = 1,
  });
}

/// Ligne d'affichage d'une alerte — réutilisée par le Dashboard (panneau
/// latéral) et par l'écran Buildings (onglet Thresholds & Alerts).
class AlertRow extends StatelessWidget {
  final AlertRowData data;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  const AlertRow({
    super.key,
    required this.data,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  String get _title {
    switch (data.alert.metric) {
      case AlertMetric.voltage:
        return data.alert.measuredValue < data.alert.thresholdValue
            ? 'Voltage Drop'
            : 'Voltage Spike';
      case AlertMetric.current:
        return 'Overcurrent';
      case AlertMetric.power:
        return 'High Demand';
      case AlertMetric.powerFactor:
        return 'Low Power Factor';
    }
  }

  String get _description {
    final measured = data.alert.measuredValue.toStringAsFixed(1);
    final threshold = data.alert.thresholdValue.toStringAsFixed(1);
    final comparison = data.alert.measuredValue < data.alert.thresholdValue
        ? 'below'
        : 'above';
    return 'Measured $measured is $comparison the configured threshold of $threshold.';
  }

  bool get _isCritical => data.alert.severity == AlertSeverity.critical;

  @override
  Widget build(BuildContext context) {
    final color = _isCritical
        ? AppColors.statusCritical
        : AppColors.statusWarning;
    final subtitle = data.buildingName.isEmpty
        ? data.equipmentName
        : '${data.buildingName} — ${data.equipmentName}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCritical
                  ? AppColors.errorContainer.withValues(alpha: 0.2)
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _title.toUpperCase(),
                          style: AppTypography.labelCaps.copyWith(color: color),
                        ),
                        if (data.occurrenceCount > 1) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(x${data.occurrenceCount})',
                            style: AppTypography.labelCaps.copyWith(
                              color: color,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      formatTimeAgo(data.alert.createdAt),
                      style: AppTypography.labelData.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _description,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 12),
                  trailing!,
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
