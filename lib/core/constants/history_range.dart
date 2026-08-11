enum HistoryRange { last20, last100, all }

extension HistoryRangeX on HistoryRange {
  String get label {
    switch (this) {
      case HistoryRange.last20:
        return 'Last 20 readings';
      case HistoryRange.last100:
        return 'Last 100 readings';
      case HistoryRange.all:
        return 'All available data';
    }
  }

  int? get limit {
    switch (this) {
      case HistoryRange.last20:
        return 20;
      case HistoryRange.last100:
        return 100;
      case HistoryRange.all:
        return null;
    }
  }
}
