import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scada_app/core/constants/app_route.dart';
import 'package:scada_app/core/constants/history_range.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/metric_label.dart';
import 'package:scada_app/models/energy_reading.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/state/energy_data_state.dart';
import 'package:scada_app/ui/widgets/history/history_filter_bar.dart';

import '../../widgets/dashboard/sparkline_chart.dart';
import '../../widgets/history/readings_table.dart';
import '../../widgets/shared/app_shell.dart';
import '../../widgets/shared/segmented_toggle.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _buildingId;
  String? _equipmentId;
  AlertMetric _metric = AlertMetric.power;
  HistoryRange _range = HistoryRange.last100;

  double _valueFor(AlertMetric metric, dynamic reading) {
    switch (metric) {
      case AlertMetric.voltage:
        return reading.voltage as double;
      case AlertMetric.current:
        return reading.current as double;
      case AlertMetric.power:
        return reading.activePower as double;
      case AlertMetric.powerFactor:
        return reading.powerFactor as double;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedRoute: AppRoute.history,
      body: Consumer<EnergyDataState>(
        builder: (context, energy, _) {
          final buildings = energy.buildings;
          _buildingId ??= buildings.isNotEmpty ? buildings.first.id : null;
          final equipments = energy.equipmentsForBuilding(_buildingId ?? '');
          if (_equipmentId == null ||
              !equipments.any((e) => e.id == _equipmentId)) {
            _equipmentId = equipments.isNotEmpty ? equipments.first.id : null;
          }

          final fullHistory = _equipmentId == null
              ? const []
              : energy.historyFor(_equipmentId!);
          final limit = _range.limit;
          final visibleHistory = (limit != null && fullHistory.length > limit)
              ? fullHistory.sublist(fullHistory.length - limit)
              : fullHistory;

          final chartValues = visibleHistory
              .map((r) => _valueFor(_metric, r))
              .toList();
          final (metricLabel, unit) = metricLabelAndUnit(_metric);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.containerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('History', style: AppTypography.headlineLg),
                const SizedBox(height: 4),
                Text(
                  'Review past readings for any building or equipment.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.cardGap),
                if (buildings.isEmpty ||
                    _buildingId == null ||
                    _equipmentId == null)
                  Text('No data available yet', style: AppTypography.bodySm)
                else ...[
                  HistoryFiltersBar(
                    buildings: buildings,
                    equipmentsForSelectedBuilding: equipments,
                    selectedBuildingId: _buildingId!,
                    selectedEquipmentId: _equipmentId!,
                    range: _range,
                    onBuildingChanged: (id) => setState(() {
                      _buildingId = id;
                      _equipmentId = null; // se recalcule dans build()
                    }),
                    onEquipmentChanged: (id) =>
                        setState(() => _equipmentId = id),
                    onRangeChanged: (r) => setState(() => _range = r),
                  ),
                  const SizedBox(height: 16),
                  SegmentedToggle<AlertMetric>(
                    value: _metric,
                    onChanged: (m) => setState(() => _metric = m),
                    options: [
                      for (final m in AlertMetric.values)
                        (m, metricLabelAndUnit(m).$1),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.borderMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$metricLabel${unit.isEmpty ? '' : ' ($unit)'}',
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 220,
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: chartValues.length < 2
                              ? Center(
                                  child: Text(
                                    'Not enough data yet',
                                    style: AppTypography.bodySm,
                                  ),
                                )
                              : SparklineChart(
                                  values: chartValues,
                                  color: AppColors.primary,
                                ),
                        ),
                        if (chartValues.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _Stat(
                                label: 'Min',
                                value: chartValues.reduce(
                                  (a, b) => a < b ? a : b,
                                ),
                              ),
                              const SizedBox(width: 24),
                              _Stat(
                                label: 'Max',
                                value: chartValues.reduce(
                                  (a, b) => a > b ? a : b,
                                ),
                              ),
                              const SizedBox(width: 24),
                              _Stat(
                                label: 'Avg',
                                value:
                                    chartValues.reduce((a, b) => a + b) /
                                    chartValues.length,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.cardGap),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.borderMuted),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ReadingsTable(
                      readings: visibleHistory.cast<EnergyReading>(),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelData.copyWith(fontSize: 12)),
        Text(value.toStringAsFixed(2), style: AppTypography.headlineMd),
      ],
    );
  }
}
