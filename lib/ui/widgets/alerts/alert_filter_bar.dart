import 'package:flutter/material.dart';
import 'package:scada_app/core/constants/alert_filters.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/models/building.dart';

class AlertFilterBar extends StatelessWidget {
  final SeverityFilter severity;
  final StatusFilter status;
  final String? buildingId;
  final List<Building> buildings;
  final ValueChanged<SeverityFilter> onSeverityChanged;
  final ValueChanged<StatusFilter> onStatusChanged;
  final ValueChanged<String?> onBuildingChanged;

  const AlertFilterBar({
    super.key,
    required this.severity,
    required this.status,
    required this.buildingId,
    required this.buildings,
    required this.onSeverityChanged,
    required this.onStatusChanged,
    required this.onBuildingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _Dropdown<SeverityFilter>(
          value: severity,
          items: SeverityFilter.values,
          labelOf: (v) => v.label,
          onChanged: onSeverityChanged,
        ),
        _Dropdown<StatusFilter>(
          value: status,
          items: StatusFilter.values,
          labelOf: (v) => v.label,
          onChanged: onStatusChanged,
        ),
        _Dropdown<String?>(
          value: buildingId,
          items: [null, ...buildings.map((b) => b.id)],
          labelOf: (id) => id == null
              ? 'All Buildings'
              : buildings.firstWhere((b) => b.id == id).name,
          onChanged: onBuildingChanged,
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(labelOf(item))),
          ],
          onChanged: (v) => v == null && T != String ? null : onChanged(v as T),
        ),
      ),
    );
  }
}
