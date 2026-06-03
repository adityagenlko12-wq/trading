import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/helper/date_converter.dart';
import '../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/my_order/my_order_history_controller.dart';
import '../../../../../../data/model/order/order_history_page_response_model.dart';
import '../../../../../components/dialog/app_dialog.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';
import '../../../../../components/text-form-field/custom_widget_text_field.dart';

class OrderHistoryPageListTileWidget extends StatelessWidget {
  const OrderHistoryPageListTileWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  final MyOrderHistoryController controller;
  final OrderHistoryPageResponseModelData item;

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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMax), color: item.orderSide.toString() != '1' ? MyColor.colorRed.withOpacity(0.1) : MyColor.colorGreen.withOpacity(0.1)),
            child: Center(
              child: MyLocalImageWidget(
                imagePath: item.orderSide.toString() == '1' ? MyIcons.addAction : MyIcons.minusAction,
                imageOverlayColor: item.orderSide.toString() != '1' ? MyColor.colorRed : MyColor.colorGreen,
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
                      "${item.pair?.symbol}",
                      style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: DateConverter.isoToLocalDateAndTime(item.createdAt ?? ''),
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
                              text: "${item.trx}",
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: item.status == '0'
                      ? () {
                          controller.changeOrderUpdateID(orderUpdateType: 'amount', orderID: item.id ?? '-1', amountValue: StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()));
                        }
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        MyStrings.amount.tr,
                        style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                      ),
                      if (item.status == '0') ...[
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: Dimensions.space2),
                                child: Icon(
                                  Icons.edit,
                                  color: MyColor.getPrimaryTextColor(),
                                  size: Dimensions.space15,
                                ),
                              )
                            ],
                          ),
                        ),
                      ] else ...[
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: item.status == '0'
                      ? () {
                          controller.changeOrderUpdateID(orderUpdateType: 'rate', orderID: item.id ?? '-1', amountValue: StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()));
                        }
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        MyStrings.rate.tr,
                        style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                      ),
                      if (item.status == '0') ...[
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(start: Dimensions.space2),
                                child: Icon(
                                  Icons.edit,
                                  color: MyColor.getPrimaryTextColor(),
                                  size: Dimensions.space15,
                                ),
                              )
                            ],
                          ),
                        ),
                      ] else ...[
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      MyStrings.total.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: StringConverter.formatNumber(item.total ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
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
                      MyStrings.filled.tr,
                      style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                    ),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: StringConverter.formatNumber(item.filledAmount ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
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
                              text: item.orderType == '1'
                                  ? MyStrings.limit.tr
                                  : item.orderType == '2'
                                      ? MyStrings.market.tr
                                      : '',
                              style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                            ),
                            TextSpan(
                              text: " | ",
                              style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                            ),
                            TextSpan(
                              text: item.orderSide == '1'
                                  ? MyStrings.buy.tr
                                  : item.orderSide == '2'
                                      ? MyStrings.sell.tr
                                      : '',
                              style: regularLarge.copyWith(color:  item.orderSide == '1' ?  MyColor.colorGreen : item.orderSide == '2' ? MyColor.colorRed  : MyColor.getPrimaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.status == '0') ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: ((controller.cancelOrderRateLoadingID == item.id))
                            ? null
                            : () {
                                AppDialog().warningAlertDialog(
                                  context,
                                  () {
                                    controller.cancelOrderRate(
                                      orderID: item.id ?? '-1',
                                    );
                                  },
                                  msgText: MyStrings.agreeCancelOrder.tr,
                                );
                              },
                        icon: ((controller.cancelOrderRateLoadingID == item.id))
                            ? SizedBox(
                                height: Dimensions.space20,
                                width: Dimensions.space20,
                                child: CircularProgressIndicator(
                                  color: MyColor.getPrimaryColor(),
                                  strokeWidth: 0.8,
                                ),
                              )
                            : const Icon(
                                Icons.close,
                                color: MyColor.colorRed,
                                size: Dimensions.space20,
                              ),
                      )
                    ],
                  ),
                ],
                if (controller.updateOrderRateOrAmountOrderID == item.id) ...[
                  verticalSpace(Dimensions.space5),
                  CustomWidgetTextField(
                    controller: controller.amountController,
                    readOnly: false,
                    inputTextAlign: TextAlign.start,
                    suffixWidget: Row(
                      children: [
                        IconButton(
                          onPressed: ((controller.updateOrderRateAmountButtonLoadingID == item.id))
                              ? null
                              : () {
                                  controller.updateOrderRate(tradeCoinSymbol: item.pair?.symbol ?? '', orderID: item.id ?? '-1');
                                },
                          icon: ((controller.updateOrderRateAmountButtonLoadingID == item.id))
                              ? SizedBox(
                                  height: Dimensions.space20,
                                  width: Dimensions.space20,
                                  child: CircularProgressIndicator(
                                    color: MyColor.getPrimaryColor(),
                                    strokeWidth: 0.8,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_rounded,
                                  color: MyColor.colorGreen,
                                  size: Dimensions.space20,
                                ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.changeOrderUpdateID(orderUpdateType: 'amount', orderID: '-1');
                          },
                          icon: const Icon(
                            Icons.close,
                            color: MyColor.colorRed,
                            size: Dimensions.space20,
                          ),
                        ),
                      ],
                    ),
                    hintText: controller.updateOrderRateOrderType == 'amount' ? MyStrings.enterAmount.tr : MyStrings.enterRate.tr,
                    onChanged: (value) {},
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
