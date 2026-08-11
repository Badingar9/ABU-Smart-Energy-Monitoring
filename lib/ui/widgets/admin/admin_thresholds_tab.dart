import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/metric_label.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/ui/widgets/buildings/thresolds_field_card.dart';

/// Vue consolidée de TOUS les seuils, tous bâtiments confondus — contexte
/// administrateur. Réutilise ThresholdFieldCard (déjà construit pour
/// BuildingsScreen) plutôt que d'en recréer un équivalent.
class AdminThresholdsTab extends StatelessWidget {
  final EnergyDataState energy;

  const AdminThresholdsTab({super.key, required this.energy});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      children: [
        for (final building in energy.buildings) ...[
          Text(building.name, style: AppTypography.headlineMd),
          const SizedBox(height: 12),
          for (final equipment in energy.equipmentsFor(building.id)) ...[
            Text(
              equipment.name,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
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
            const SizedBox(height: 12),
          ],
          const Divider(color: AppColors.outlineVariant, height: 32),
        ],
      ],
    );
  }
}
