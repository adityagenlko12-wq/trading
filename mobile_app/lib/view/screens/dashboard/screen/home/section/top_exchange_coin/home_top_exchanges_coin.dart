import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../../data/model/market/market_over_view_model.dart';
import '../../../../../../components/shimmer/home_page_market_list_horizontal_shimmer.dart';
import 'widget/top_exchange_list_card.dart';

class HomeTopExchangesCoinList extends StatelessWidget {
  final HomeController controller;
  const HomeTopExchangesCoinList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return !controller.isMarketOverviewDataLoading && controller.marketTopExchangeData.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  MyStrings.topExchangesCoin.tr,
                  style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                ),
                verticalSpace(Dimensions.space10),
                if (controller.isMarketOverviewDataLoading) ...[
                  const HomePageMarketListHorizontalDataShimmer(),
                ] else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(controller.marketTopExchangeData.length, (index) {
                        TopExchangesCoin item = controller.marketTopExchangeData[index];
                        return TopExchangeHorizontalListWidget(item: item, controller: controller);
                      }),
                    ),
                  )
                ],
              ],
            ),
          );
  }
}
