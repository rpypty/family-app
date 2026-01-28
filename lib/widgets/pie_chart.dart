import 'dart:math';

import 'package:flutter/material.dart';

class PieSlice {
  final String label;
  final double value;
  final Color color;

  const PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class PieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;

  const PieChart({
    super.key,
    required this.slices,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text('0')),
      );
    }
    return CustomPaint(
      size: Size(size, size),
      painter: PieChartPainter(
        slices: slices,
        total: total,
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieSlice> slices;
  final double total;

  PieChartPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    var startAngle = -pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, paint);

      final percent = (slice.value / total) * 100;
      if (percent >= 6) {
        final midAngle = startAngle + sweep / 2;
        final radius = size.width / 2;
        final labelRadius = radius * 0.62;
        final offset = Offset(
          radius + labelRadius * cos(midAngle),
          radius + labelRadius * sin(midAngle),
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${percent.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          offset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
