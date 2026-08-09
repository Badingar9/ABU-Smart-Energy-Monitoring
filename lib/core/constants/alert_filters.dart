import 'package:scada_app/models/alerts.dart';

import '../../models/threshold_config.dart';

enum SeverityFilter { all, warning, critical }

enum StatusFilter { all, active, inProgress, resolved }

extension SeverityFilterX on SeverityFilter {
  String get label {
    switch (this) {
      case SeverityFilter.all:
        return 'All Severities';
      case SeverityFilter.warning:
        return 'Warning';
      case SeverityFilter.critical:
        return 'Critical';
    }
  }

  bool matches(AlertSeverity severity) {
    if (this == SeverityFilter.all) return true;
    return (this == SeverityFilter.warning &&
            severity == AlertSeverity.warning) ||
        (this == SeverityFilter.critical && severity == AlertSeverity.critical);
  }
}

extension StatusFilterX on StatusFilter {
  String get label {
    switch (this) {
      case StatusFilter.all:
        return 'All Statuses';
      case StatusFilter.active:
        return 'Active';
      case StatusFilter.inProgress:
        return 'In Progress';
      case StatusFilter.resolved:
        return 'Resolved';
    }
  }

  bool matches(AlertStatus status) {
    if (this == StatusFilter.all) return true;
    return (this == StatusFilter.active && status == AlertStatus.active) ||
        (this == StatusFilter.inProgress && status == AlertStatus.inProgress) ||
        (this == StatusFilter.resolved && status == AlertStatus.resolved);
  }
}
