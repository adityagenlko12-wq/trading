import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../components/auto_height_grid_view/auto_height_grid_view.dart';
import '../../../../../../components/shimmer/home_page_market_list_horizontal_shimmer.dart';
import 'widgets/home_high_light_coin_card_widget.dart';

class HomeScreenHighLightsCoinList extends StatelessWidget {
  final HomeController controller;
  const HomeScreenHighLightsCoinList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return !controller.isMarketOverviewDataLoading && controller.marketHighLightedCoinsData.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  MyStrings.highlightCoin.tr,
                  style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                ),
                verticalSpace(Dimensions.space10),
                if (controller.isMarketOverviewDataLoading) ...[
                  const HomePageMarketListHorizontalDataShimmer(),
                ] else ...[
                  AutoHeightGridView(
                    itemCount: controller.marketHighLightedCoinsData.length,
                    crossAxisCount: 2,
                    mainAxisSpacing: Dimensions.space10,
                    crossAxisSpacing: Dimensions.space10,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    builder: (context, index) {
                      var item = controller.marketHighLightedCoinsData[index];
                      return HomeHighLightCoinCardWidget(
                        item: item,
                        controller: controller,
                      );
                    },
                  ),
                ]
              ],
            ),
          );
  }
}
