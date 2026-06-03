import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../components/no_data.dart';

class OrderBookListWidgetList extends StatelessWidget {
  final TradePageController controller;
  const OrderBookListWidgetList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
          child: Column(
            children: [
              if (controller.buySideOrderList.isNotEmpty || controller.sellSideOrder.isNotEmpty) ...[
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
                              "${MyStrings.amount.tr} (${MyStrings.sell.tr})",
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
                              MyStrings.price.tr,
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
                              "(${MyStrings.buy.tr}) ${MyStrings.amount.tr}",
                              style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Buy List
                      Expanded(
                        child: ListView.builder(
                            // physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: controller.buySideOrderList.length,
                            itemBuilder: (context, index) {
                              var item = controller.buySideOrderList[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: FittedBox(
                                        child: Text(
                                          StringConverter.formatNumber(item.amount ?? '0.0', precision: 4),
                                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: FittedBox(
                                        child: Text(
                                          StringConverter.formatNumber(item.rate ?? '0.0', precision: 4),
                                          style: regularSmall.copyWith(color: MyColor.colorGreen),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                      horizontalSpace(Dimensions.space10),
                      //Sell list
                      Expanded(
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: controller.sellSideOrder.length,
                            itemBuilder: (context, index) {
                              var item = controller.sellSideOrder[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: FittedBox(
                                        child: Text(
                                          StringConverter.formatNumber(item.rate ?? '0.0', precision: 4),
                                          style: regularSmall.copyWith(color: MyColor.colorRed),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: FittedBox(
                                        child: Text(
                                          StringConverter.formatNumber(item.amount ?? '0.0', precision: 4),
                                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const NoDataWidget(
                  text: MyStrings.noOrderHistoryFound,
                )
              ],
            ],
          ),
        ),
      );
    });
  }
}
