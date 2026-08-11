import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/date_format.dart';
import 'package:scada_app/models/energy_reading.dart';

/// Table de mesures brutes — complète les graphiques (tendance visuelle)
/// avec des valeurs exactes consultables. Limitée par le parent (jamais
/// plus de quelques centaines de lignes) pour éviter un ListView trop
/// lourd.
class ReadingsTable extends StatelessWidget {
  final List<EnergyReading> readings;

  const ReadingsTable({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text('No readings available yet', style: AppTypography.bodySm),
        ),
      );
    }

    final reversed = readings.reversed.toList(); // plus récent en premier

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
          ),
          child: Row(
            children: const [
              _HeaderCell('Time', flex: 2),
              _HeaderCell('Voltage (V)'),
              _HeaderCell('Current (A)'),
              _HeaderCell('Power (kW)'),
              _HeaderCell('PF'),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reversed.length,
            itemBuilder: (context, index) {
              final r = reversed[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? AppColors.surfaceContainerLow
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    _Cell(formatTime(r.timestamp), flex: 2, mono: true),
                    _Cell(r.voltage.toStringAsFixed(1), mono: true),
                    _Cell(r.current.toStringAsFixed(1), mono: true),
                    _Cell(r.activePower.toStringAsFixed(2), mono: true),
                    _Cell(r.powerFactor.toStringAsFixed(2), mono: true),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelCaps.copyWith(fontSize: 10),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final int flex;
  final bool mono;
  const _Cell(this.value, {this.flex = 1, this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: mono
            ? AppTypography.labelData.copyWith(fontSize: 12)
            : AppTypography.bodySm,
      ),
    );
  }
}
