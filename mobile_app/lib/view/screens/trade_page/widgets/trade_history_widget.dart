import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';
import 'package:vinance/view/components/no_data.dart';

import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class TradeHistoryListWidget extends StatelessWidget {
  final TradePageController controller;
  const TradeHistoryListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: Dimensions.space10),
          child: Container(
            margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            child: Column(
              children: [
                if (controller.tradesHistoryList.isNotEmpty) ...[
                  Container(
                    // color: Colors.red,
                    margin: const EdgeInsets.symmetric(vertical: Dimensions.space10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              child: Text(
                                "${MyStrings.amount.tr} (${controller.tradeDetailsMarketPair?.coin?.symbol ?? ''})",
                                style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: FittedBox(
                              child: Text(
                                "${MyStrings.price.tr} (${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''})",
                                style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              child: Text(
                                MyStrings.date.tr,
                                style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.tradesHistoryList.length,
                    itemBuilder: (context, index) {
                      var item = controller.tradesHistoryList[index];
        
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  child: Text(
                                    StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                    style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: FittedBox(
                                  child: Text(
                                    StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                    style: regularSmall.copyWith(color: item.tradeSide == '1' ? MyColor.colorGreen : MyColor.colorRed),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  child: Text(
                                    item.formattedDate ?? '',
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
                ] else ...[
                  const NoDataWidget(
                    text: MyStrings.noTradeHistoryFound,
                  )
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
