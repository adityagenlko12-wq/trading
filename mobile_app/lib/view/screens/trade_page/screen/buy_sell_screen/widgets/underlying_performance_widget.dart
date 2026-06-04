import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

class UnderlyingPerformanceWidget extends StatelessWidget {
  final int positiveStocks;
  final int negativeStocks;

  const UnderlyingPerformanceWidget({
    super.key,
    required this.positiveStocks,
    required this.negativeStocks,
  });

  @override
  Widget build(BuildContext context) {
    final int total = positiveStocks + negativeStocks;
    final double positiveRatio = total > 0 ? positiveStocks / total : 0.5;
    final double negativeRatio = total > 0 ? negativeStocks / total : 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
        border: Border.all(
          color: MyColor.getBorderColor(),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Underlying Performance',
            style: semiBoldDefault.copyWith(
              color: MyColor.getPrimaryTextColor(),
            ),
          ),
          verticalSpace(Dimensions.space3),
          Divider(
            color: MyColor.getBorderColor(),
            height: 1,
            thickness: 0.5,
          ),
          verticalSpace(Dimensions.space15),

          // Positive Stocks
          _buildStockBar(
            label: 'Positive Stocks',
            count: positiveStocks,
            ratio: positiveRatio,
            barColor: MyColor.colorGreen,
            bgColor: MyColor.colorGreen.withOpacity(0.1),
          ),
          verticalSpace(Dimensions.space15),

          // Negative Stocks
          _buildStockBar(
            label: 'Negative Stocks',
            count: negativeStocks,
            ratio: negativeRatio,
            barColor: MyColor.colorRed,
            bgColor: MyColor.colorRed.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBar({
    required String label,
    required int count,
    required double ratio,
    required Color barColor,
    required Color bgColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: regularExtraSmall.copyWith(
            color: MyColor.getSecondaryTextColor(),
          ),
        ),
        verticalSpace(Dimensions.space7),
        LayoutBuilder(
          builder: (context, constraints) {
            final double maxBarWidth = constraints.maxWidth - 40;
            final double barWidth = (maxBarWidth * ratio).clamp(8.0, maxBarWidth);

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 20,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              barColor.withOpacity(0.6),
                              barColor.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                horizontalSpace(Dimensions.space8),
                Text(
                  '$count',
                  style: semiBoldSmall.copyWith(
                    color: barColor,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
