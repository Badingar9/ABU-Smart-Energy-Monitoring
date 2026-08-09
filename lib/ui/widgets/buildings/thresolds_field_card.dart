import 'package:flutter/material.dart';
import 'package:scada_app/core/errors/validation_exception.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/models/threshold_config.dart';

/// Carte de seuil éditable — la validation (min < max, etc.) reste dans
/// ThresholdService ; ce widget affiche juste le résultat.
class ThresholdFieldCard extends StatefulWidget {
  final ThresholdConfig config;
  final String metricLabel;
  final String unit;
  final void Function(ThresholdConfig updated) onApply;

  const ThresholdFieldCard({
    super.key,
    required this.config,
    required this.metricLabel,
    required this.unit,
    required this.onApply,
  });

  @override
  State<ThresholdFieldCard> createState() => _ThresholdFieldCardState();
}

class _ThresholdFieldCardState extends State<ThresholdFieldCard> {
  late final TextEditingController _minController = TextEditingController(
    text: widget.config.minValue?.toString() ?? '',
  );
  late final TextEditingController _maxController = TextEditingController(
    text: widget.config.maxValue?.toString() ?? '',
  );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _apply() {
    try {
      final updated = widget.config.copyWith(
        minValue: _minController.text.isEmpty
            ? null
            : double.tryParse(_minController.text),
        maxValue: _maxController.text.isEmpty
            ? null
            : double.tryParse(_maxController.text),
      );
      widget.onApply(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.metricLabel} threshold updated')),
      );
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.metricLabel} (${widget.unit})',
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _apply, child: const Text('Apply')),
            ],
          ),
        ],
      ),
    );
  }
}
