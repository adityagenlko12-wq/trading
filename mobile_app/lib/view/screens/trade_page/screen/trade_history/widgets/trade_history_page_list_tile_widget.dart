import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/helper/date_converter.dart';
import '../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/trade_page/trade_history_controller.dart';
import '../../../../../../data/model/trade/trade_history_page_response_model.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class TradeHistoryPageListTileWidget extends StatelessWidget {
  const TradeHistoryPageListTileWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  final TradeHistoryController controller;
  final TradeHistoryPageListData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
      ),
      padding: const EdgeInsets.all(Dimensions.space10),
      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: Dimensions.space15),
            height: Dimensions.space40,
            width: Dimensions.space40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMax), color: item.tradeSide == '1' ? MyColor.colorGreen.withOpacity(0.1) : MyColor.colorRed.withOpacity(0.1)),
            child: Center(
              child: MyLocalImageWidget(
                imagePath: item.tradeSide == '1' ? MyIcons.depositAction : MyIcons.withdrawAction,
                imageOverlayColor: item.tradeSide == '1' ? MyColor.colorGreen : MyColor.colorRed,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.order?.pair?.symbol ?? '',
                      style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: DateConverter.isoToLocalDateAndTime(item.order?.pair?.createdAt ?? ''),
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(Dimensions.space10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.trx.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${item.order?.trx}",
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.amount.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${item.order?.pair?.market?.currency?.sign ?? ''}${StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber())}",
                              style: regularLarge.copyWith(color: item.tradeSide == '1' ? MyColor.colorGreen : MyColor.colorRed),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.rate.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${item.order?.pair?.market?.currency?.sign ?? ''}${StringConverter.formatNumber(item.order?.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber())}",
                              style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.type.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.tradeSide == '1'
                                  ? MyStrings.buy.tr
                                  : item.tradeSide == '2'
                                      ? MyStrings.sell.tr
                                      : '',
                              style: regularLarge.copyWith(
                                  color: item.tradeSide == '1'
                                      ? MyColor.colorGreen
                                      : item.tradeSide == '2'
                                          ? MyColor.colorRed
                                          : MyColor.getPrimaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
