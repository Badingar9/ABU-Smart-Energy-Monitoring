import '../../models/threshold_config.dart';

/// Libellé humain + unité pour une grandeur mesurée — utilisé partout où
/// un AlertMetric doit s'afficher (Buildings, Admin...).
(String label, String unit) metricLabelAndUnit(AlertMetric metric) {
  switch (metric) {
    case AlertMetric.voltage:
      return ('Voltage', 'V');
    case AlertMetric.current:
      return ('Current', 'A');
    case AlertMetric.power:
      return ('Active power', 'kW');
    case AlertMetric.powerFactor:
      return ('Power factor', '');
  }
}
