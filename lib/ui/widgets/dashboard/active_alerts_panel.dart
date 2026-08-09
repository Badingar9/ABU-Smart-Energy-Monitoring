import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/threshold_config.dart';

import '../shared/alert_row.dart';

class ActiveAlertsPanel extends StatelessWidget {
  final List<AlertRowData> alerts;
  final int totalCount;
  final ValueChanged<String> onAcknowledge;
  final VoidCallback onViewAll;

  const ActiveAlertsPanel({
    super.key,
    required this.alerts,
    required this.totalCount,
    required this.onAcknowledge,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderMuted),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: AppColors.statusCritical,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Active Alerts', style: AppTypography.headlineMd),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Text(
                  '$totalCount Total',
                  style: AppTypography.labelData.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.outlineVariant, height: 1),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No active alerts', style: AppTypography.bodySm),
              ),
            )
          else
            for (final data in alerts) ...[
              AlertRow(
                data: data,
                trailing: data.alert.severity == AlertSeverity.critical
                    ? OutlinedButton(
                        onPressed: () => onAcknowledge(data.alert.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Acknowledge',
                          style: AppTypography.labelData,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onSurface,
                backgroundColor: AppColors.surfaceContainerHigh,
                side: const BorderSide(color: AppColors.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              icon: Text('View All Alerts', style: AppTypography.labelData),
              label: const Icon(Icons.arrow_forward, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
