enum ControlActionType { disconnect, reconnect }

enum ControlTrigger { system, user }

enum ControlResult { success, failed, timeout }

/// Journalisation de toute action de coupure/rétablissement (UC-08/UC-09) —
/// traçabilité exigée par la section 9.4 du SRS.
class ControlAction {
  final String id;
  final String equipmentId;
  final String? alertId;
  final ControlActionType actionType;
  final ControlTrigger triggeredBy;
  final String? userId;
  final DateTime executedAt;
  final ControlResult result;

  const ControlAction({
    required this.id,
    required this.equipmentId,
    this.alertId,
    required this.actionType,
    required this.triggeredBy,
    this.userId,
    required this.executedAt,
    required this.result,
  });
}
