import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';

import '../shared/status_pill.dart';
import 'sparkline_chart.dart';

enum BuildingCardStatus { nominal, warning, critical }

/// Carte métrique compacte pour un bâtiment — répétée dans la grille du
/// Dashboard. Widget purement présentationnel : ne lit aucun Provider,
/// reçoit tout en paramètres (l'écran orchestre les données).
class BuildingMetricCard extends StatelessWidget {
  final String buildingName;
  final IconData icon;
  final double activePowerKw;
  final List<double> trend;
  final BuildingCardStatus status;
  final int alertCount;
  final VoidCallback? onTap;

  const BuildingMetricCard({
    super.key,
    required this.buildingName,
    required this.icon,
    required this.activePowerKw,
    required this.trend,
    required this.status,
    required this.alertCount,
    this.onTap,
  });

  Color get _statusColor {
    switch (status) {
      case BuildingCardStatus.nominal:
        return AppColors.statusSuccess;
      case BuildingCardStatus.warning:
        return AppColors.statusWarning;
      case BuildingCardStatus.critical:
        return AppColors.statusCritical;
    }
  }

  String get _statusLabel {
    if (alertCount == 0) return 'No Alerts';
    final noun = alertCount == 1 ? 'Alert' : 'Alerts';
    final severity = status == BuildingCardStatus.critical
        ? 'Critical'
        : 'Warning';
    return '$alertCount $severity $noun';
  }

  IconData get _statusIcon =>
      status == BuildingCardStatus.nominal ? Icons.check_circle : Icons.warning;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // ← contraint la largeur disponible
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buildingName.toUpperCase(),
                        style: AppTypography.labelCaps,
                        maxLines: 1,
                        overflow: TextOverflow
                            .ellipsis, // "MAIN LECTURE HALL" → "MAIN LECTURE…" si trop long
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            activePowerKw.toStringAsFixed(1),
                            style: AppTypography.displayLg,
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('kW', style: AppTypography.labelData),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // ← évite que l'icône colle au texte
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: SparklineChart(values: trend, color: _statusColor),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.outlineVariant, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize
                      .min, // ← empêche ce Row de forcer trop d'espace
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Active Power', style: AppTypography.labelData),
                  ],
                ),
                Flexible(
                  // ← autorise le badge à rétrécir si besoin
                  child: StatusPill(
                    label: _statusLabel,
                    color: _statusColor,
                    icon: _statusIcon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
