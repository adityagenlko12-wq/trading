import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../dashboard/screen/market/widgets/market_sort_filter_button.dart';

class TradePageScreenSortByWidget extends StatelessWidget {
  final TradePageController controller;
  const TradePageScreenSortByWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
      child: Row(
        children: [
          Text(
            MyStrings.shortBy.tr,
            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
          ),
          horizontalSpace(Dimensions.space10),
          //Sort  by button
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  MarketSortFilterButton(
                    name: "",
                    iconWidget: Icon(
                      Icons.star_rounded,
                      color: controller.isFavFilter == true ? MyColor.getPrimaryTextColor() : MyColor.getSecondaryTextColor(),
                      size: Dimensions.space20,
                    ),
                    isActive: controller.isFavFilter == true,
                    showAscOrDescIcon: false,
                    onTap: () {
                      controller.filterMarketPairData(filterTypeParam: 'fav');
                    },
                  ),
                  horizontalSpace(Dimensions.space10),
                  MarketSortFilterButton(
                      name: MyStrings.priceSort,
                      isActive: controller.isPriceFilter,
                      isAsc: controller.isPriceAsc,
                      onTap: () {
                        controller.filterMarketPairData(filterTypeParam: 'price', toggleOrder: true);
                      }),
                  horizontalSpace(Dimensions.space10),
                  MarketSortFilterButton(
                      name: MyStrings.changes1HSort,
                      isActive: controller.is1hFilter,
                      isAsc: controller.is1hAsc,
                      onTap: () {
                        controller.filterMarketPairData(filterTypeParam: '1hFilter', toggleOrder: true);
                      }),
                  horizontalSpace(Dimensions.space10),
                  MarketSortFilterButton(
                      name: MyStrings.volSort,
                      isActive: controller.isVolFilter,
                      isAsc: controller.isVolAsc,
                      onTap: () {
                        controller.filterMarketPairData(filterTypeParam: 'volFilter', toggleOrder: true);
                      }),
                  horizontalSpace(Dimensions.space10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
