import 'package:flutter/material.dart';
import 'package:scada_app/core/constants/app_info.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';

class AboutCard extends StatelessWidget {
  final String dataSourceLabel;

  const AboutCard({super.key, required this.dataSourceLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: AppTypography.headlineMd),
          const SizedBox(height: 16),
          _InfoRow(label: 'Application', value: AppInfo.projectName),
          _InfoRow(label: 'Version', value: AppInfo.version),
          _InfoRow(label: 'Build stage', value: AppInfo.buildStage),
          _InfoRow(label: 'Data source', value: dataSourceLabel),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.labelData.copyWith(fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodySm)),
        ],
      ),
    );
  }
}
