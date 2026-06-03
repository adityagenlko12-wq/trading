import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';

import '../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../core/utils/util.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';
import '../../../../../components/no_data.dart';
import '../../../../../components/shimmer/market_buy_sell_order_book_shimmer.dart';

class BuySellOrderBookWidget extends StatelessWidget {
  final TradePageController controller;
  final String tradeCoinSymbol;
  const BuySellOrderBookWidget({super.key, required this.controller, required this.tradeCoinSymbol});

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: MyColor.redCancelTextColor,
        width: MediaQuery.of(context).size.width / 2.35,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //Header
            //Price
            Container(
              // color: Colors.red,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.space10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Text(
                              MyStrings.price.tr,
                              style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                            Text(
                              "(${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''})",
                              style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Text(
                              MyStrings.amount.tr,
                              style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                            Text(
                              "(${controller.tradeDetailsMarketPair?.coin?.symbol ?? ''})",
                              style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.tradeDetailsOrderBookLoading) ...[
              const MarketBuySellOrderBookShimmerShimmer(),
            ] else ...[
              if (controller.sellSideOrder.isEmpty) ...[
                const SizedBox(
                  height: Dimensions.space100,
                  child: Center(
                    child: NoDataWidget(
                      margin: 40,
                      text: MyStrings.noSellOrderFound,
                    ),
                  ),
                )
              ] else ...[
                Column(
                  children: List.generate(
                    controller.sellSideOrder.length > 10 ? 10 : controller.sellSideOrder.length,
                    (index) {
                      var item = controller.sellSideOrder[index];
                      return InkWell(
                        onTap: () {
                          controller.setOrderBookPriceToInputBox(item.rate ?? '0.0');
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: FittedBox(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                          style: regularSmall.copyWith(color: MyColor.colorRed),
                                        ),
                                        if (item.userId == controller.marketTradeRepo.apiClient.getUserID()) ...[
                                          TextSpan(
                                            text: " •",
                                            style: regularSmall.copyWith(
                                              color: MyColor.colorYellow,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: FittedBox(
                                  child: Text(
                                    MyUtils.formatNumberAbbreviated("${item.amount.toString() == "null" ? '0.0' : item.amount?.toString()}"),
                                    style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              //Sell List End
              //Current Market Value
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    verticalSpace(Dimensions.space15),

                    //Rank
                    FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            StringConverter.formatNumber(controller.tradeDetailsMarketData?.price ?? '0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: semiBoldDefault.copyWith(color: (controller.tradeDetailsMarketData?.htmlClasses?.priceChange?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed),
                          ),
                          horizontalSpace(Dimensions.space5),
                          MyLocalImageWidget(
                            imagePath: (controller.tradeDetailsMarketData?.htmlClasses?.priceChange?.toLowerCase() == 'up') ? MyIcons.arrowUp : MyIcons.arrowDown,
                            height: Dimensions.space15,
                            width: Dimensions.space15,
                            imageOverlayColor: (controller.tradeDetailsMarketData?.htmlClasses?.priceChange?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed,
                          ),
                        ],
                      ),
                    ),
                    verticalSpace(Dimensions.space15),
                  ],
                ),
              ),

              //Buy List

              if (controller.buySideOrderList.isEmpty) ...[
                const SizedBox(
                  height: Dimensions.space100,
                  child: Center(
                    child: NoDataWidget(
                      margin: 40,
                      text: MyStrings.noBuyOrderFound,
                    ),
                  ),
                )
              ] else ...[
                Column(
                  children: List.generate(
                    controller.buySideOrderList.length > 10 ? 10 : controller.buySideOrderList.length,
                    (index) {
                      var item = controller.buySideOrderList[index];
                      return InkWell(
                        onTap: () {
                          controller.setOrderBookPriceToInputBox(item.rate ?? '0.0');
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: FittedBox(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                          style: regularSmall.copyWith(color: MyColor.colorGreen),
                                        ),
                                        if (item.userId == controller.marketTradeRepo.apiClient.getUserID()) ...[
                                          TextSpan(
                                            text: " •",
                                            style: regularSmall.copyWith(
                                              color: MyColor.colorYellow,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: FittedBox(
                                  child: Text(
                                    MyUtils.formatNumberAbbreviated("${item.totalAmount.toString() == "null" ? '0.0' : item.totalAmount?.toString()}"),
                                    style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ));
  }
}
