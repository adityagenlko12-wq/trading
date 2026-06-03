import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/utils/util.dart';
import '../../../../data/controller/trade_page/trade_page_controller.dart';
import '../../../../data/model/market/market_pair_list_data_model.dart';
import '../../../components/divider/custom_spacer.dart';

class TradePageFilterMarketPairListCard extends StatelessWidget {
  final MarketSinglePairData item;
  final TradePageController controller;
  const TradePageFilterMarketPairListCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
      ),
      padding: const EdgeInsets.all(Dimensions.space10),
      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
      child: GestureDetector(
        onTap: () {
          controller.initialData(
            symbolID: '${item.symbol}',
            isBgLoad: true,
          );
          Get.back();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Worth
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (controller.checkUserIsLoggedInOrNot()) {
                            controller.addToFavFromSearch(symbolID: item.symbol ?? '', itemID: (item.id ?? '').toString());
                          } else {
                            Get.toNamed(RouteHelper.authenticationScreen);
                          }
                        },
                        child: Container(
                          color: MyColor.getScreenBgColor(),
                          padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10),
                          child: controller.coinAddToFavSymbol == (item.symbol ?? '')
                              ? SizedBox(
                                  width: Dimensions.space20,
                                  height: Dimensions.space20,
                                  child: CircularProgressIndicator(
                                    color: MyColor.getPrimaryColor(),
                                    strokeWidth: 0.8,
                                  ))
                              : Icon(
                                  Icons.star_rounded,
                                  color: controller.checkItemIsFavorite(itemID: (item.id ?? '-1').toString()) == true ? MyColor.colorYellow : MyColor.getAppBarContentColor(),
                                  size: Dimensions.space20,
                                ),
                        ),
                      ),
                      horizontalSpace(Dimensions.space10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: item.coin?.symbol ?? '',
                                  style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                TextSpan(
                                  text: "/${item.market?.currency?.symbol ?? ''}",
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                          verticalSpace(Dimensions.space5),
                          Text(
                            "${MyStrings.volDot.tr} "
                            "${MyUtils.formatNumberAbbreviated("${item.marketData?.marketCap.toString() == "null" ? '0.0' : item.marketData?.marketCap.toString()}")}",
                            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  horizontalSpace(Dimensions.space15),
                ],
              ),
            ),

            //Rank
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StringConverter.formatNumber(item.marketData?.price ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                  ),
                  verticalSpace(Dimensions.space5),
                  Text(
                    "${StringConverter.formatNumber("${item.marketData?.percentChange1H.toString()}", precision: 2)}%",
                    style: semiBoldLarge.copyWith(color: (item.marketData?.htmlClasses?.percentChange1H?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
