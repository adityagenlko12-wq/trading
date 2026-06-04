import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

class SimpleLineChartWidget extends StatefulWidget {
  final List<double> dataPoints;
  final Color lineColor;
  final double height;

  const SimpleLineChartWidget({
    super.key,
    this.dataPoints = const [],
    this.lineColor = MyColor.colorGreen,
    this.height = 200,
  });

  @override
  State<SimpleLineChartWidget> createState() => _SimpleLineChartWidgetState();
}

class _SimpleLineChartWidgetState extends State<SimpleLineChartWidget> {
  String _selectedTimeframe = '1m';
  late List<double> _chartData;

  static const List<String> _timeframes = [
    '1d',
    '5d',
    '1m',
    '6m',
    '1y',
    '5y',
    'max',
  ];

  @override
  void initState() {
    super.initState();
    _chartData = widget.dataPoints.isNotEmpty
        ? widget.dataPoints
        : _generateSampleData();
  }

  List<double> _generateSampleData() {
    final Random random = Random(42);
    final List<double> data = [];
    double price = 23000 + random.nextDouble() * 500;

    for (int i = 0; i < 30; i++) {
      // Simulate a realistic walk with some trend
      final double change = (random.nextDouble() - 0.48) * 150;
      price += change;
      // Add slight sine wave for realism
      price += sin(i * 0.3) * 30;
      data.add(price);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
        border: Border.all(
          color: MyColor.getBorderColor(),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Chart area
          Padding(
            padding: const EdgeInsets.only(
              left: Dimensions.space15,
              right: Dimensions.space15,
              top: Dimensions.space15,
            ),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  dataPoints: _chartData,
                  lineColor: widget.lineColor,
                ),
              ),
            ),
          ),
          verticalSpace(Dimensions.space10),

          // Divider
          Divider(
            color: MyColor.getBorderColor(),
            height: 1,
            thickness: 0.5,
          ),

          // Timeframe buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space10,
              vertical: Dimensions.space10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _timeframes.map((tf) {
                final bool isSelected = tf == _selectedTimeframe;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeframe = tf;
                      // Regenerate data for different timeframes
                      if (widget.dataPoints.isEmpty) {
                        _chartData = _generateSampleData();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.space10,
                      vertical: Dimensions.space5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MyColor.colorGreen.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(Dimensions.space5),
                      border: Border.all(
                        color: isSelected
                            ? MyColor.colorGreen
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tf.toUpperCase(),
                      style: (isSelected ? semiBoldExtraSmall : regularExtraSmall)
                          .copyWith(
                        color: isSelected
                            ? MyColor.colorGreen
                            : MyColor.getSecondaryTextColor(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _LineChartPainter({
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double minVal =
        dataPoints.reduce((a, b) => a < b ? a : b);
    final double maxVal =
        dataPoints.reduce((a, b) => a > b ? a : b);
    final double range = maxVal - minVal;
    final double effectiveRange = range == 0 ? 1 : range;

    final double stepX = size.width / (dataPoints.length - 1);
    final double paddingY = 12;

    // Build path for the line
    final Path linePath = Path();
    final List<Offset> points = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      final double normalizedY =
          (dataPoints[i] - minVal) / effectiveRange;
      final double y =
          size.height - paddingY - (normalizedY * (size.height - paddingY * 2));

      points.add(Offset(x, y));
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    // Draw gradient fill below the line
    final Path fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.15),
          lineColor.withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw the line
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw circle at last data point
    if (points.isNotEmpty) {
      final Offset lastPoint = points.last;

      // Outer glow
      final Paint glowPaint = Paint()
        ..color = lineColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 6, glowPaint);

      // Inner dot
      final Paint dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPoint, 3.5, dotPaint);

      // White ring
      final Paint ringPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(lastPoint, 3.5, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.lineColor != lineColor;
  }
}
