import 'package:flutter/material.dart';
import 'package:scada_app/core/theme/app_colors.dart';
import 'package:scada_app/core/theme/app_spacing.dart';
import 'package:scada_app/core/theme/app_typography.dart';
import 'package:scada_app/core/utils/time_ago.dart';
import 'package:scada_app/models/alerts.dart';
import 'package:scada_app/models/threshold_config.dart';
import 'package:scada_app/models/user.dart';

/// Panneau de détail — affiche la fiche complète (SRS 4.3) et le
/// formulaire de clôture. Le commentaire est obligatoire pour Resolve,
/// pas pour Acknowledge (UC-03).
class AlertDetailPanel extends StatefulWidget {
  final Alert alert;
  final String buildingName;
  final String equipmentName;
  final List<AppUser> actingUsers;
  final AppUser? actingUser;
  final ValueChanged<AppUser> onActingUserChanged;
  final void Function(String acknowledgedBy) onAcknowledge;
  final void Function(String resolvedBy, String comment) onResolve;

  const AlertDetailPanel({
    super.key,
    required this.alert,
    required this.buildingName,
    required this.equipmentName,
    required this.actingUsers,
    required this.actingUser,
    required this.onActingUserChanged,
    required this.onAcknowledge,
    required this.onResolve,
  });

  @override
  State<AlertDetailPanel> createState() => _AlertDetailPanelState();
}

class _AlertDetailPanelState extends State<AlertDetailPanel> {
  final _commentController = TextEditingController();

  @override
  void didUpdateWidget(covariant AlertDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alert.id != widget.alert.id) {
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _metricLabel {
    switch (widget.alert.metric) {
      case AlertMetric.voltage:
        return 'Voltage';
      case AlertMetric.current:
        return 'Current';
      case AlertMetric.power:
        return 'Active power';
      case AlertMetric.powerFactor:
        return 'Power factor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final isCritical = alert.severity == AlertSeverity.critical;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.containerPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isCritical
                                ? AppColors.statusCritical
                                : AppColors.statusWarning)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    alert.severity.name.toUpperCase(),
                    style: AppTypography.labelCaps.copyWith(
                      color: isCritical
                          ? AppColors.statusCritical
                          : AppColors.statusWarning,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(alert.status),
                  style: AppTypography.labelData.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.buildingName} — ${widget.equipmentName}',
              style: AppTypography.headlineMd,
            ),
            const SizedBox(height: 4),
            Text(
              'Detected ${formatTimeAgo(alert.createdAt)}',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _InfoRow(
              label: _metricLabel,
              value: alert.measuredValue.toStringAsFixed(2),
            ),
            _InfoRow(
              label: 'Configured threshold',
              value: alert.thresholdValue.toStringAsFixed(2),
            ),
            const SizedBox(height: 24),
            if (alert.status != AlertStatus.active) ...[
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'History',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (alert.acknowledgedAt != null)
                _InfoRow(
                  label: 'Acknowledged by',
                  value:
                      '${alert.acknowledgedBy} · ${formatTimeAgo(alert.acknowledgedAt!)}',
                ),
              if (alert.resolvedAt != null) ...[
                _InfoRow(
                  label: 'Resolved by',
                  value:
                      '${alert.resolvedBy} · ${formatTimeAgo(alert.resolvedAt!)}',
                ),
                if (alert.comment != null)
                  _InfoRow(label: 'Comment', value: alert.comment!),
              ],
              const SizedBox(height: 24),
            ],
            if (alert.status != AlertStatus.resolved) ...[
              const Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Text(
                'Acting as',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<AppUser>(
                value: widget.actingUser,
                isExpanded: true,
                items: [
                  for (final user in widget.actingUsers)
                    DropdownMenuItem(
                      value: user,
                      child: Text('${user.fullName} (${user.role.label})'),
                    ),
                ],
                onChanged: (user) =>
                    user == null ? null : widget.onActingUserChanged(user),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Resolution comment',
                  hintText: 'Required to resolve this alert',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (alert.status == AlertStatus.active)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.actingUser == null
                            ? null
                            : () => widget.onAcknowledge(
                                widget.actingUser!.fullName,
                              ),
                        child: const Text('Acknowledge'),
                      ),
                    ),
                  if (alert.status == AlertStatus.active)
                    const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          widget.actingUser == null ||
                              _commentController.text.trim().isEmpty
                          ? null
                          : () => widget.onResolve(
                              widget.actingUser!.fullName,
                              _commentController.text.trim(),
                            ),
                      child: const Text('Resolve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(AlertStatus status) {
    switch (status) {
      case AlertStatus.active:
        return 'Active — not yet acknowledged';
      case AlertStatus.inProgress:
        return 'In progress';
      case AlertStatus.resolved:
        return 'Resolved';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
