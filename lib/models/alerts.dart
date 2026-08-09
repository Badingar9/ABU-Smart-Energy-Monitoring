import 'threshold_config.dart';

enum AlertStatus { active, inProgress, resolved }

class Alert {
  final String id;
  final String equipmentId;
  final AlertMetric metric;
  final AlertSeverity severity;
  final double measuredValue;
  final double thresholdValue;
  final AlertStatus status;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? comment;

  const Alert({
    required this.id,
    required this.equipmentId,
    required this.metric,
    required this.severity,
    required this.measuredValue,
    required this.thresholdValue,
    this.status = AlertStatus.active,
    required this.createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.comment,
  });

  Alert copyWith({
    AlertStatus? status,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? comment,
  }) => Alert(
    id: id,
    equipmentId: equipmentId,
    metric: metric,
    severity: severity,
    measuredValue: measuredValue,
    thresholdValue: thresholdValue,
    status: status ?? this.status,
    createdAt: createdAt,
    acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    resolvedBy: resolvedBy ?? this.resolvedBy,
    comment: comment ?? this.comment,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipmentId': equipmentId,
    'metric': metric.name,
    'severity': severity.name,
    'measuredValue': measuredValue,
    'thresholdValue': thresholdValue,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'acknowledgedAt': acknowledgedAt?.toIso8601String(),
    'acknowledgedBy': acknowledgedBy,
    'resolvedAt': resolvedAt?.toIso8601String(),
    'resolvedBy': resolvedBy,
    'comment': comment,
  };

  factory Alert.fromJson(Map<String, dynamic> json) => Alert(
    id: json['id'] as String,
    equipmentId: json['equipmentId'] as String,
    metric: AlertMetric.values.byName(json['metric'] as String),
    severity: AlertSeverity.values.byName(json['severity'] as String),
    measuredValue: (json['measuredValue'] as num).toDouble(),
    thresholdValue: (json['thresholdValue'] as num).toDouble(),
    status: AlertStatus.values.byName(json['status'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    acknowledgedAt: json['acknowledgedAt'] != null
        ? DateTime.parse(json['acknowledgedAt'] as String)
        : null,
    acknowledgedBy: json['acknowledgedBy'] as String?,
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'] as String)
        : null,
    resolvedBy: json['resolvedBy'] as String?,
    comment: json['comment'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Alert && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
