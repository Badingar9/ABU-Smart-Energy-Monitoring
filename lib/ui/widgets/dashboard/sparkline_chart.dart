import 'package:flutter/material.dart';

/// Mini-graphique de tendance réutilisable — utilisé par les cartes
/// bâtiment compactes et par la carte featured (avec fillArea activé
/// pour un rendu plus riche sur cette dernière).
class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final bool filled;

  const SparklineChart({
    super.key,
    required this.values,
    required this.color,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color, filled: filled),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final bool filled;

  _SparklinePainter({
    required this.values,
    required this.color,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < 0.001
        ? 1.0
        : maxValue - minValue;

    final stepX = size.width / (values.length - 1);
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i * stepX,
          size.height - ((values[i] - minValue) / range) * size.height,
        ),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }

    if (filled) {
      final areaPath = Path.from(linePath)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(areaPath, Paint()..color = color.withValues(alpha: 0.15));
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
