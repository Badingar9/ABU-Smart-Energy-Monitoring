import 'package:flutter/material.dart';
import 'package:scada_app/core/constants/history_range.dart';
import 'package:scada_app/models/building.dart';
import 'package:scada_app/models/equipment.dart';

import '../shared/labeled_dropdown.dart';

class HistoryFiltersBar extends StatelessWidget {
  final List<Building> buildings;
  final List<Equipment> equipmentsForSelectedBuilding;
  final String selectedBuildingId;
  final String selectedEquipmentId;
  final HistoryRange range;
  final ValueChanged<String> onBuildingChanged;
  final ValueChanged<String> onEquipmentChanged;
  final ValueChanged<HistoryRange> onRangeChanged;

  const HistoryFiltersBar({
    super.key,
    required this.buildings,
    required this.equipmentsForSelectedBuilding,
    required this.selectedBuildingId,
    required this.selectedEquipmentId,
    required this.range,
    required this.onBuildingChanged,
    required this.onEquipmentChanged,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        LabeledDropdown<String>(
          value: selectedBuildingId,
          items: buildings.map((b) => b.id).toList(),
          labelOf: (id) => buildings.firstWhere((b) => b.id == id).name,
          onChanged: onBuildingChanged,
        ),
        LabeledDropdown<String>(
          value: selectedEquipmentId,
          items: equipmentsForSelectedBuilding.map((e) => e.id).toList(),
          labelOf: (id) =>
              equipmentsForSelectedBuilding.firstWhere((e) => e.id == id).name,
          onChanged: onEquipmentChanged,
        ),
        LabeledDropdown<HistoryRange>(
          value: range,
          items: HistoryRange.values,
          labelOf: (r) => r.label,
          onChanged: onRangeChanged,
        ),
      ],
    );
  }
}
