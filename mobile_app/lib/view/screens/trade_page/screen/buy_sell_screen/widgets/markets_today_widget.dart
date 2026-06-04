import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/screens/trade_page/screen/buy_sell_screen/widgets/price_range_slider_widget.dart';

class MarketsTodayWidget extends StatelessWidget {
  final String open;
  final String high;
  final String low;
  final String prevClose;
  final double currentPrice;

  const MarketsTodayWidget({
    super.key,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final double lowVal = double.tryParse(low) ?? 0;
    final double highVal = double.tryParse(high) ?? 0;

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
            'Markets Today',
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

          // OHLC grid
          Row(
            children: [
              _buildOhlcItem('Open', open),
              _buildOhlcItem('High', high),
              _buildOhlcItem('Low', low),
              _buildOhlcItem('Prev. Close', prevClose),
            ],
          ),
          verticalSpace(Dimensions.space20),

          // Price Range Slider
          PriceRangeSliderWidget(
            currentPrice: currentPrice,
            lowPrice: lowVal,
            highPrice: highVal,
          ),
        ],
      ),
    );
  }

  Widget _buildOhlcItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: regularExtraSmall.copyWith(
              color: MyColor.getSecondaryTextColor(),
            ),
          ),
          verticalSpace(Dimensions.space5),
          Text(
            value,
            style: semiBoldSmall.copyWith(
              color: MyColor.getPrimaryTextColor(),
            ),
          ),
        ],
      ),
    );
  }
}
