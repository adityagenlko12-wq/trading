import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';
import 'package:vinance/view/components/shimmer/home_page_market_list_data_shimmer.dart';

import '../../../../core/utils/my_strings.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/no_data.dart';
import 'order_list_tile_widget.dart';


class MyOrderListWidget extends StatelessWidget {
  final TradePageController controller;
  final ScrollController scrollController;
  final String tradeCoinSymbol;
  const MyOrderListWidget({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.tradeCoinSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: Dimensions.space40),
          child: Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space3),
            child: Column(
              children: [
                if (controller.openOrderHistoryLoading) ...[
                  const HomePageMarketListDataShimmer(),
                ] else ...[
                  if (controller.orderListData.isNotEmpty) ...[
                    ListView.builder(
                      // controller: scrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.orderListData.length + 1,
                      itemBuilder: (context, index) {
                        if (controller.orderListData.length == (index)) {
                          return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                        }
                        var item = controller.orderListData[index];
                        return OrderListTileWidget(
                          tradeCoinSymbol: tradeCoinSymbol,
                          item: item,
                          controller: controller,
                        );
                      },
                    ),
                  ] else ...[
                    const NoDataWidget(
                      text: MyStrings.noOrderHistoryFound,
                    )
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
