import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../core/route/route.dart';
import '../../../../../../data/controller/trade_page/trade_page_controller.dart';
import '../../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';
import '../../../../../components/buttons/rounded_button.dart';
import 'change_buy_sell_type_bottom_sheet.dart';
import 'trade_buy_sell_text_field.dart';

class SellFormWidget extends StatelessWidget {
  const SellFormWidget({
    super.key,
    required this.controller,
    required this.tradeCoinSymbol,
  });

  final TradePageController controller;
  final String tradeCoinSymbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TradeBuySellWidgetTextField(
          controller: TextEditingController(text: controller.selectedOrderType == 0 ? MyStrings.limit.tr : MyStrings.market.tr),
          readOnly: true,
          prefixWidget: Icon(
            Icons.info_outline_rounded,
            size: Dimensions.space20,
            color: MyColor.getTextFieldHintColor(),
          ),
          suffixWidget: GestureDetector(
            onTap: () {
              CustomBottomSheetPlus(
                  isNeedPadding: false,
                  bgColor: MyColor.transparentColor,
                  child: ChangeBuySellTypeBottomSheetWidget(
                    tradeCoinSymbol: tradeCoinSymbol,
                    controller: controller,
                    key: key,
                  )).show(context);
            },
            child: Icon(
              Icons.keyboard_double_arrow_down_sharp,
              size: Dimensions.space20,
              color: MyColor.getTextFieldHintColor(),
            ),
          ),
          textInputType: TextInputType.number,
          inputTextAlign: TextAlign.center,
          onTap: () {
            CustomBottomSheetPlus(
                isNeedPadding: false,
                bgColor: MyColor.transparentColor,
                child: ChangeBuySellTypeBottomSheetWidget(
                  tradeCoinSymbol: tradeCoinSymbol,
                  controller: controller,
                  key: key,
                )).show(context);
          },
          onChanged: (v) {},
        ),
        if (controller.selectedOrderType == 0) ...[
          verticalSpace(Dimensions.space10),
          TradeBuySellWidgetTextField(
            controller: controller.myMarketPriceTextController,
            prefixWidget: GestureDetector(
              onTap: () {
                controller.increaseOrDecreaseMyMarketPriceCounter(
                  isIncrease: false,
                );
              },
              onLongPress: () {
                controller.increaseOrDecreaseMyMarketPriceCounter(isIncrease: false, isLongPress: true);
              },
              onLongPressEnd: (_) {
                controller.closeTimer();
              },
              child: Container(
                color: MyColor.getScreenBgSecondaryColor(),
                padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10),
                child: Icon(
                  Icons.remove,
                  size: Dimensions.space20,
                  color: MyColor.getTextFieldHintColor(),
                ),
              ),
            ),
            suffixWidget: GestureDetector(
              onTap: () {
                controller.increaseOrDecreaseMyMarketPriceCounter(isIncrease: true);
              },
              onLongPress: () {
                controller.increaseOrDecreaseMyMarketPriceCounter(isIncrease: true, isLongPress: true);
              },
              onLongPressEnd: (_) {
                controller.closeTimer();
              },
              child: Container(
                color: MyColor.getScreenBgSecondaryColor(),
                padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10),
                child: Icon(
                  Icons.add,
                  size: Dimensions.space20,
                  color: MyColor.getTextFieldHintColor(),
                ),
              ),
            ),
            textInputType: TextInputType.number,
            hintText: "${MyStrings.price.tr} (${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''})",
            inputTextAlign: TextAlign.center,
            onChanged: (v) {
              controller.calculateSellChargeAndTotalPriceFromAmount();
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
            ],
          ),
        ] else ...[
          verticalSpace(Dimensions.space10),
          TradeBuySellWidgetTextField(
            controller: TextEditingController(text: MyStrings.marketPrice.tr),
            readOnly: true,
            disable: true,
            textInputType: TextInputType.number,
            inputTextAlign: TextAlign.center,
            onChanged: (v) {},
          ),
        ],

        verticalSpace(Dimensions.space10),
        TradeBuySellWidgetTextField(
          controller: controller.mySellPriceAmountTextController,
          readOnly: false,
          prefixWidget: GestureDetector(
            onTap: () {
              controller.increaseOrDecreaseSellAmountCounter(
                isIncrease: false,
              );
            },
            onLongPress: () {
              controller.increaseOrDecreaseSellAmountCounter(isIncrease: false, isLongPress: true);
            },
            onLongPressEnd: (_) {
              controller.closeTimer();
            },
            child: Container(
              color: MyColor.getScreenBgSecondaryColor(),
              padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10),
              child: Icon(
                Icons.remove,
                size: Dimensions.space20,
                color: MyColor.getTextFieldHintColor(),
              ),
            ),
          ),
          suffixWidget: GestureDetector(
            onTap: () {
              controller.increaseOrDecreaseSellAmountCounter(isIncrease: true);
            },
            onLongPress: () {
              controller.increaseOrDecreaseSellAmountCounter(isIncrease: true, isLongPress: true);
            },
            onLongPressEnd: (_) {
              controller.calculateSellChargeAndTotalPriceFromAmount();
              controller.closeTimer();
            },
            onTapCancel: () {
              controller.calculateSellChargeAndTotalPriceFromAmount();
            },
            child: Container(
              color: MyColor.getScreenBgSecondaryColor(),
              padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space10),
              child: Icon(
                Icons.add,
                size: Dimensions.space20,
                color: MyColor.getTextFieldHintColor(),
              ),
            ),
          ),
          textInputType: TextInputType.number,
          hintText: "${MyStrings.amount.tr} (${controller.tradeDetailsMarketPair?.coin?.symbol ?? ''})",
          inputTextAlign: TextAlign.center,
          onChanged: (v) {
            controller.calculateSellChargeAndTotalPriceFromAmount();
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
          ],
        ),
        verticalSpace(Dimensions.space10),
        if (controller.checkUserIsLoggedInOrNot()) ...[
          //Range slider
          SizedBox(
            height: 40,
            child: FlutterSlider(
              values: [controller.enterAmountPercentageSell],
              max: 100,
              min: 0,
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: MyColor.getBorderColor(),
                ),
                activeTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: MyColor.getPrimaryColor(),
                ),
              ),
              tooltip: FlutterSliderTooltip(
                textStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                boxStyle: FlutterSliderTooltipBox(
                  decoration: BoxDecoration(color: MyColor.getScreenBgColor()),
                ),
              ),
              handler: FlutterSliderHandler(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.getPrimaryColor().withOpacity(0.003),
                      offset: const Offset(6, 3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  elevation: 3,
                  child: Transform.rotate(
                    angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                    child: Icon(
                      Icons.square_rounded,
                      color: MyColor.getPrimaryColor(),
                      size: Dimensions.space15,
                    ),
                  ),
                ),
              ),
              hatchMark: FlutterSliderHatchMark(
                linesAlignment: FlutterSliderHatchMarkAlignment.left,
                density: 0.5, // means 50 lines, from 0 to 100 percent
                labels: [
                  FlutterSliderHatchMarkLabel(
                    percent: 0,
                    label: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          elevation: 3,
                          child: Transform.rotate(
                            angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.square_rounded,
                              color: controller.enterAmountPercentageSell > 0 ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                              size: Dimensions.space10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlutterSliderHatchMarkLabel(
                    percent: 25,
                    label: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          elevation: 3,
                          child: Transform.rotate(
                            angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.square_rounded,
                              color: controller.enterAmountPercentageSell > 25 ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                              size: Dimensions.space10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlutterSliderHatchMarkLabel(
                    percent: 50,
                    label: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          elevation: 3,
                          child: Transform.rotate(
                            angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.square_rounded,
                              color: controller.enterAmountPercentageSell > 50 ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                              size: Dimensions.space10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlutterSliderHatchMarkLabel(
                    percent: 75,
                    label: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          elevation: 3,
                          child: Transform.rotate(
                            angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.square_rounded,
                              color: controller.enterAmountPercentageSell > 75 ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                              size: Dimensions.space10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlutterSliderHatchMarkLabel(
                    percent: 100,
                    label: Column(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          elevation: 3,
                          child: Transform.rotate(
                            angle: 45 * (3.141592653589793238462 / 180), // Convert degrees to radians
                            child: Icon(
                              Icons.square_rounded,
                              color: controller.enterAmountPercentageSell == 100 ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                              size: Dimensions.space10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onDragging: (handlerIndex, lowerValue, upperValue) {
                // _lowerValue = lowerValue;
                // _upperValue = upperValue;
                printx(lowerValue);
                printx(upperValue);
                controller.calculateTotalPriceAmountFromPercentageSell(lowerValue);
                // MyUtils.vibrationOn();
              },
            ),
          ),
          verticalSpace(Dimensions.space10),
        ],
        TradeBuySellWidgetTextField(
          controller: controller.myTotalPriceAmountTextController,
          readOnly: false,
          textInputType: TextInputType.number,
          hintText: "${MyStrings.total.tr} (${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''})",
          inputTextAlign: TextAlign.center,
          onChanged: (v) {
            controller.calculateSellChargePriceFromTotalPrice();
          },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
          ],
        ),
        verticalSpace(Dimensions.space15),
        //Fee and Balance Counter
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    MyStrings.avbl.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            if (controller.checkUserIsLoggedInOrNot()) {
                              Get.toNamed(RouteHelper.depositScreen, arguments: ['spot', "${controller.tradeDetailsMarketPair?.coinId}"]);
                            } else {
                              Get.toNamed(RouteHelper.authenticationScreen);
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: StringConverter.formatNumber(controller.coinWallet?.balance ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                        style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                      TextSpan(
                                        text: " ${controller.coinWallet?.currency?.symbol ?? ''}",
                                        style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsetsDirectional.only(start: Dimensions.space2),
                                height: Dimensions.space15,
                                width: Dimensions.space15,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Ink(
                                    decoration: ShapeDecoration(
                                      color: MyColor.getSecondaryTextColor(isReverse: true),
                                      shape: const CircleBorder(),
                                    ),
                                    child: FittedBox(
                                      child: IconButton(
                                        color: MyColor.getPrimaryColor(),
                                        padding: EdgeInsets.zero,
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.add_rounded,
                                          color: MyColor.getPrimaryTextColor(isReverse: true),
                                          size: Dimensions.space50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    MyStrings.minSell.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: StringConverter.formatNumber(controller.tradeDetailsMarketPair?.minimumSellAmount ?? '0.0', precision: 2),
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        TextSpan(
                          text: " ${controller.coinWallet?.currency?.symbol ?? ''}",
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    MyStrings.maxSell.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: StringConverter.formatNumber(controller.tradeDetailsMarketPair?.maximumSellAmount ?? '0.0', precision: 2),
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        TextSpan(
                          text: " ${controller.coinWallet?.currency?.symbol ?? ''}",
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    MyStrings.fee.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.tradeDetailsMarketPair?.percentChargeForSell ?? '0'}%",
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    MyStrings.estFee.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                ),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: StringConverter.formatNumber(controller.chargeAmountDataSell.toString(), precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                          style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                        TextSpan(
                          text: " ${controller.coinWallet?.currency?.symbol ?? ''}",
                          style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
        verticalSpace(Dimensions.space20),
        if (controller.checkUserIsLoggedInOrNot()) ...[
          RoundedButton(
            isLoading: controller.orderSellingLoading,
            verticalPadding: Dimensions.space10,
            color: MyColor.colorRed,
            text: MyStrings.sell,
            textStyle: semiBoldLarge.copyWith(color: MyColor.colorWhite),
            press: () {
              controller.sellNewOrderCoin(
                symbolID: tradeCoinSymbol,
              );
            },
          ),
        ] else ...[
          RoundedButton(
            isLoading: controller.orderCreatingLoading,
            verticalPadding: Dimensions.space10,
            color: MyColor.colorRed,
            text: MyStrings.signIn,
            textStyle: semiBoldLarge.copyWith(color: MyColor.colorWhite),
            press: () {
              Get.toNamed(RouteHelper.authenticationScreen, arguments: false);
            },
          ),
        ]
      ],
    );
  }
}
