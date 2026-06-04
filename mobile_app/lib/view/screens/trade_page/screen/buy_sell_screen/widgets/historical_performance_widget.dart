import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/screens/trade_page/screen/buy_sell_screen/widgets/price_range_slider_widget.dart';

class HistoricalPerformanceWidget extends StatelessWidget {
  final double currentPrice;
  final double yearHigh;
  final double yearLow;

  const HistoricalPerformanceWidget({
    super.key,
    required this.currentPrice,
    required this.yearHigh,
    required this.yearLow,
  });

  @override
  Widget build(BuildContext context) {
    // Estimate 3-Year and 5-Year values from 1-Year data
    final double threeYearHigh = yearHigh;
    final double threeYearLow = yearLow * 0.85;
    final double fiveYearHigh = yearHigh;
    final double fiveYearLow = yearLow * 0.70;

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
            'Historical Performance',
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

          // 1-Year row
          _buildPerformanceRow(
            '1-Year High',
            yearHigh.toStringAsFixed(2),
            '1-Year Low',
            yearLow.toStringAsFixed(2),
          ),
          verticalSpace(Dimensions.space12),

          // 3-Year row
          _buildPerformanceRow(
            '3-Year High',
            threeYearHigh.toStringAsFixed(2),
            '3-Year Low',
            threeYearLow.toStringAsFixed(2),
          ),
          verticalSpace(Dimensions.space12),

          // 5-Year row
          _buildPerformanceRow(
            '5-Year High',
            fiveYearHigh.toStringAsFixed(2),
            '5-Year Low',
            fiveYearLow.toStringAsFixed(2),
          ),
          verticalSpace(Dimensions.space20),

          // Price Range Slider (5-Year range)
          PriceRangeSliderWidget(
            currentPrice: currentPrice,
            lowPrice: fiveYearLow,
            highPrice: fiveYearHigh,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(
    String highLabel,
    String highValue,
    String lowLabel,
    String lowValue,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  highLabel,
                  style: regularExtraSmall.copyWith(
                    color: MyColor.getSecondaryTextColor(),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  highValue,
                  style: semiBoldSmall.copyWith(
                    color: MyColor.getPrimaryTextColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
        horizontalSpace(Dimensions.space10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  lowLabel,
                  style: regularExtraSmall.copyWith(
                    color: MyColor.getSecondaryTextColor(),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  lowValue,
                  style: semiBoldSmall.copyWith(
                    color: MyColor.getPrimaryTextColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
