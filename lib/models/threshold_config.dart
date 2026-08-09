enum AlertMetric { voltage, current, power, powerFactor }

enum AlertSeverity { warning, critical }

enum AutoAction { none, alertOnly, autoDisconnect }

class ThresholdConfig {
  final String id;
  final String equipmentId;
  final AlertMetric metric;
  final double? minValue;
  final double? maxValue;
  final AlertSeverity severity;
  final AutoAction autoAction;

  const ThresholdConfig({
    required this.id,
    required this.equipmentId,
    required this.metric,
    this.minValue,
    this.maxValue,
    required this.severity,
    this.autoAction = AutoAction.alertOnly,
  });

  ThresholdConfig copyWith({
    String? id,
    String? equipmentId,
    AlertMetric? metric,
    double? minValue,
    double? maxValue,
    AlertSeverity? severity,
    AutoAction? autoAction,
  }) => ThresholdConfig(
    id: id ?? this.id,
    equipmentId: equipmentId ?? this.equipmentId,
    metric: metric ?? this.metric,
    minValue: minValue ?? this.minValue,
    maxValue: maxValue ?? this.maxValue,
    severity: severity ?? this.severity,
    autoAction: autoAction ?? this.autoAction,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'equipmentId': equipmentId,
    'metric': metric.name,
    'minValue': minValue,
    'maxValue': maxValue,
    'severity': severity.name,
    'autoAction': autoAction.name,
  };

  factory ThresholdConfig.fromJson(Map<String, dynamic> json) =>
      ThresholdConfig(
        id: json['id'] as String,
        equipmentId: json['equipmentId'] as String,
        metric: AlertMetric.values.byName(json['metric'] as String),
        minValue: (json['minValue'] as num?)?.toDouble(),
        maxValue: (json['maxValue'] as num?)?.toDouble(),
        severity: AlertSeverity.values.byName(json['severity'] as String),
        autoAction: AutoAction.values.byName(json['autoAction'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ThresholdConfig && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
