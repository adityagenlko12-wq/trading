import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class StockChart extends StatelessWidget {
  final List<double> prices;
  final bool isPositive;
  final bool isIndex;

  const StockChart({
    super.key,
    required this.prices,
    this.isPositive = true,
    this.isIndex = false,
  });

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    final themeColor = isIndex ? const Color(0xFFF07470) : (isPositive ? AppColors.green : AppColors.red);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(
          prices: prices,
          color: themeColor,
          isIndex: isIndex,
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> prices;
  final Color color;
  final bool isIndex;

  _ChartPainter({
    required this.prices,
    required this.color,
    required this.isIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final double minPrice = prices.reduce((a, b) => a < b ? a : b);
    final double maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final double range = maxPrice - minPrice == 0 ? 1.0 : maxPrice - minPrice;

    final double width = size.width;
    final double height = size.height;

    final double stepX = width / (prices.length - 1);

    // Padding inside the custom paint area
    final double verticalPadding = height * 0.15;
    final double usableHeight = height - (verticalPadding * 2);

    final Path path = Path();
    final Path fillPath = Path();

    // Map points
    double getX(int index) => index * stepX;
    double getY(double price) {
      final double normalized = (price - minPrice) / range;
      // Invert Y coordinate because Flutter's (0,0) is top-left
      return height - verticalPadding - (normalized * usableHeight);
    }

    path.moveTo(getX(0), getY(prices[0]));
    fillPath.moveTo(getX(0), height);
    fillPath.lineTo(getX(0), getY(prices[0]));

    for (int i = 1; i < prices.length; i++) {
      final x = getX(i);
      final y = getY(prices[i]);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(getX(prices.length - 1), height);
    fillPath.close();

    // Draw grid lines (horizontal background lines)
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.06)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final double gridY = verticalPadding + (usableHeight * (i / 4));
      canvas.drawLine(Offset(0, gridY), Offset(width, gridY), gridPaint);
    }

    // Paint for the gradient fill below the chart path (only if NOT an index)
    if (!isIndex) {
      final Paint fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.00),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(0, getY(maxPrice), 0, height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Paint for the stock line
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    if (isIndex) {
      // 1. Draw vertical dashed orange line in the middle
      final int midIdx = (prices.length * 0.52).toInt().clamp(0, prices.length - 1);
      final double midX = getX(midIdx);
      final double midY = getY(prices[midIdx]);

      final Paint dashPaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      double dashHeight = 4, dashSpace = 4;
      double startY = 0;
      while (startY < height) {
        canvas.drawLine(Offset(midX, startY), Offset(midX, startY + dashHeight), dashPaint);
        startY += dashHeight + dashSpace;
      }

      // 2. Draw white tooltip box with orange border
      final double boxW = 85;
      final double boxH = 42;
      final double boxX = midX - boxW / 2;
      final double boxY = midY - boxH / 2 - 15;

      final RRect rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(boxX, boxY, boxW, boxH),
        const Radius.circular(6),
      );

      final Paint boxBgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final Paint boxBorderPaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(rrect, boxBgPaint);
      canvas.drawRRect(rrect, boxBorderPaint);

      // Draw values inside tooltip
      final TextPainter tpVal = TextPainter(
        text: const TextSpan(
          text: '75,200.85',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpVal.paint(canvas, Offset(midX - tpVal.width / 2, boxY + 6));

      final TextPainter tpDate = TextPainter(
        text: const TextSpan(
          text: '19 May 2026',
          style: TextStyle(color: Colors.grey, fontSize: 8.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tpDate.paint(canvas, Offset(midX - tpDate.width / 2, boxY + 23));

      // 3. Draw end green dot
      final double lastX = getX(prices.length - 1);
      final double lastY = getY(prices.last);

      canvas.drawCircle(Offset(lastX, lastY), 5.5, Paint()..color = const Color(0xFF1B5E20)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(lastX, lastY), 3.8, Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill);
    } else {
      // Draw end pulsing point for normal stock charts
      final double lastX = getX(prices.length - 1);
      final double lastY = getY(prices.last);

      final Paint innerDotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final Paint outerDotPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 8, outerDotPaint);
      canvas.drawCircle(Offset(lastX, lastY), 4, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.prices != prices || oldDelegate.color != color || oldDelegate.isIndex != isIndex;
  }
}
