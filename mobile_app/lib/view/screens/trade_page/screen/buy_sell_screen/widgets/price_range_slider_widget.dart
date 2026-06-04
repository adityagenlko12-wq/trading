import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

class PriceRangeSliderWidget extends StatelessWidget {
  final double currentPrice;
  final double lowPrice;
  final double highPrice;

  const PriceRangeSliderWidget({
    super.key,
    required this.currentPrice,
    required this.lowPrice,
    required this.highPrice,
  });

  @override
  Widget build(BuildContext context) {
    final double range = highPrice - lowPrice;
    final double ratio = range > 0
        ? ((currentPrice - lowPrice) / range).clamp(0.0, 1.0)
        : 0.5;

    final double downSidePercent =
        lowPrice > 0 ? ((currentPrice - lowPrice) / lowPrice) * 100 : 0;
    final double upSidePercent =
        currentPrice > 0 ? ((highPrice - currentPrice) / currentPrice) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient bar with tooltip
        LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            final double tooltipWidth = 80;
            final double tooltipPosition =
                (barWidth * ratio - tooltipWidth / 2).clamp(0.0, barWidth - tooltipWidth);

            return Column(
              children: [
                // Tooltip bubble
                SizedBox(
                  height: 32,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: tooltipPosition,
                        bottom: 0,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.space8,
                                vertical: Dimensions.space3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9800),
                                borderRadius: BorderRadius.circular(Dimensions.space5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                currentPrice.toStringAsFixed(2),
                                style: semiBoldExtraSmall.copyWith(
                                  color: MyColor.colorWhite,
                                ),
                              ),
                            ),
                            // Small triangle pointer
                            CustomPaint(
                              size: const Size(10, 6),
                              painter: _TrianglePainter(color: const Color(0xFFFF9800)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                verticalSpace(Dimensions.space2),
                // Gradient bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF6465D), // Red
                        Color(0xFFFF9800), // Orange
                        Color(0xFFFFCC00), // Yellow
                        Color(0xFF0ECB81), // Green
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        verticalSpace(Dimensions.space5),
        // Low and High labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lowPrice.toStringAsFixed(2),
              style: regularExtraSmall.copyWith(
                color: MyColor.getSecondaryTextColor(),
              ),
            ),
            Text(
              highPrice.toStringAsFixed(2),
              style: regularExtraSmall.copyWith(
                color: MyColor.getSecondaryTextColor(),
              ),
            ),
          ],
        ),
        verticalSpace(Dimensions.space5),
        // Down side / Up side percentages
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '↘ ${downSidePercent.toStringAsFixed(2)}% down side',
              style: regularExtraSmall.copyWith(
                color: MyColor.colorRed,
              ),
            ),
            Text(
              'up side ${upSidePercent.toStringAsFixed(2)}% ↗',
              style: regularExtraSmall.copyWith(
                color: MyColor.colorGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
