import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../../data/model/market/market_data_list_model.dart';
import '../../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../components/shimmer/home_page_market_list_data_shimmer.dart';
import 'widgets/home_market_pair_coin_card_widget.dart';

class HomeScreenMarketPairCoinList extends StatelessWidget {
  final HomeController controller;
  const HomeScreenMarketPairCoinList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return !controller.isMarketPairListDataLoading && controller.marketDataListPairData.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.marketsOverview.tr,
                      style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                          child: PopupMenuButton(
                            splashRadius: Dimensions.cardRadius2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
                            color: MyColor.getScreenBgSecondaryColor(),
                            offset: const Offset(-10, 50),
                            onSelected: (value) {
                              if (value == 0) {
                                controller.loadMarketListPairData(type: 'all', hotRefresh: true);
                              }
                              if (value == 1) {
                                controller.loadMarketListPairData(type: 'crypto', hotRefresh: true);
                              }
                              if (value == 2) {
                                controller.loadMarketListPairData(type: 'fiat', hotRefresh: true);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 0, child: menuPopItem(text: MyStrings.all.tr, isSelected: controller.loadMarketPairDataType == 'all')),
                              PopupMenuItem(value: 1, child: menuPopItem(text: MyStrings.crypto.tr, isSelected: controller.loadMarketPairDataType == 'crypto')),
                              PopupMenuItem(value: 2, child: menuPopItem(text: MyStrings.fiat.tr, isSelected: controller.loadMarketPairDataType == 'fiat'))
                            ],
                            tooltip: MyStrings.marketsOverview.tr,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: MyColor.getSecondaryTextColor(),
                              size: Dimensions.space25,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                verticalSpace(Dimensions.space10),
                if (controller.isMarketPairListDataLoading) ...[
                  const HomePageMarketListDataShimmer(),
                ] else ...[
                  Column(
                    children: List.generate(controller.marketDataListPairData.length + 1, (index) {
                      if (controller.marketDataListPairData.length == (index)) {
                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                      }
                      MarketPairSingleData item = controller.marketDataListPairData[index];
                      return HomeMarketPairCoinCardWidget(
                        item: item,
                        controller: controller,
                      );
                    }),
                  )
                ]
              ],
            ),
          );
  }

  Widget menuPopItem({required String text, required bool isSelected}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          text,
          style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
        ),
        if (isSelected) ...[
          Icon(
            Icons.check_rounded,
            color: MyColor.getPrimaryTextColor(),
          )
        ]
      ],
    );
  }
}
