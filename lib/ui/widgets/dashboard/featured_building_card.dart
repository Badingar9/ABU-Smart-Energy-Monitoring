import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';

import '../shared/status_pill.dart';
import 'sparkline_chart.dart';

enum _ChartRange { live, history24h }

/// Carte "featured", plus grande (span 2 colonnes) — mise en avant du
/// bâtiment pilote. Le toggle Live/24h est un état purement visuel local,
/// géré ici (pas besoin de le faire remonter dans EnergyDataState).
class FeaturedBuildingCard extends StatefulWidget {
  final String buildingName;
  final IconData icon;
  final double activePowerKw;
  final double trendPercent;
  final List<double> Function(int points) trendProvider;
  final double? peakDemandKw;
  final double? powerFactor;
  final VoidCallback? onTap;

  const FeaturedBuildingCard({
    super.key,
    required this.buildingName,
    required this.icon,
    required this.activePowerKw,
    required this.trendPercent,
    required this.trendProvider,
    required this.peakDemandKw,
    required this.powerFactor,
    this.onTap,
  });

  @override
  State<FeaturedBuildingCard> createState() => _FeaturedBuildingCardState();
}

class _FeaturedBuildingCardState extends State<FeaturedBuildingCard> {
  _ChartRange _range = _ChartRange.live;

  @override
  Widget build(BuildContext context) {
    final points = _range == _ChartRange.live ? 20 : 200;
    final trend = widget.trendProvider(points);
    final isUp = widget.trendPercent >= 0;

    return InkWell(
      onTap: widget.onTap,
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        widget.icon,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.buildingName.toUpperCase(),
                          style: AppTypography.labelCaps,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.activePowerKw.toStringAsFixed(1),
                              style: AppTypography.displayLg,
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('kW', style: AppTypography.labelData),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Text(
                                    '${isUp ? '+' : ''}${widget.trendPercent.toStringAsFixed(1)}%',
                                    style: AppTypography.labelData.copyWith(
                                      color: isUp
                                          ? AppColors.statusSuccess
                                          : AppColors.statusCritical,
                                    ),
                                  ),
                                  Icon(
                                    isUp
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 16,
                                    color: isUp
                                        ? AppColors.statusSuccess
                                        : AppColors.statusCritical,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                _RangeToggle(
                  range: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 192,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              padding: const EdgeInsets.all(8),
              child: trend.length < 2
                  ? Center(
                      child: Text(
                        'Not enough data yet',
                        style: AppTypography.bodySm,
                      ),
                    )
                  : SparklineChart(values: trend, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              children: [
                Row(
                  children: [
                    _Stat(
                      label: 'Peak Demand',
                      value:
                          '${(widget.peakDemandKw ?? 0).toStringAsFixed(1)} kW',
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: AppColors.outlineVariant,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    _Stat(
                      label: 'Power Factor',
                      value: widget.powerFactor == null
                          ? '—'
                          : widget.powerFactor!.toStringAsFixed(2),
                    ),
                  ],
                ),
                const StatusPill(
                  label: 'Systems Nominal',
                  color: AppColors.statusSuccess,
                  icon: Icons.check_circle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelData),
        Text(value, style: AppTypography.headlineMd),
      ],
    );
  }
}

class _RangeToggle extends StatelessWidget {
  final _ChartRange range;
  final ValueChanged<_ChartRange> onChanged;
  const _RangeToggle({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RangeButton(
            label: 'Live Data',
            selected: range == _ChartRange.live,
            onTap: () => onChanged(_ChartRange.live),
          ),
          _RangeButton(
            label: '24h History',
            selected: range == _ChartRange.history24h,
            onTap: () => onChanged(_ChartRange.history24h),
          ),
        ],
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelData.copyWith(
            color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
