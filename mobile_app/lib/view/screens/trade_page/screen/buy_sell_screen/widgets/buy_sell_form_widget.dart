import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../data/controller/trade_page/trade_page_controller.dart';
import 'buy_form_widget.dart';
import 'sell_form_widget.dart';

class BuySellFormWidget extends StatelessWidget {
  final TradePageController controller;
  final String tradeCoinSymbol;
  const BuySellFormWidget({super.key, required this.controller, required this.tradeCoinSymbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.75,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              height: Dimensions.space40,
              padding: const EdgeInsets.all(Dimensions.space3),
              decoration: BoxDecoration(
                color: MyColor.getScreenBgSecondaryColor(),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
              ),
              child: TabBar(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.buyOrSellTabController,
                splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: controller.buyOrSellTabController?.index == 0
                      ? MyColor.colorGreen
                      : controller.buyOrSellTabController?.index == 1
                          ? MyColor.colorRed
                          : MyColor.getPrimaryColor(),
                  borderRadius: const BorderRadiusDirectional.all(
                    Radius.circular(Dimensions.cardRadius2),
                  ),
                ),
                labelColor: MyColor.colorWhite,
                labelStyle: regularLarge.copyWith(color: MyColor.colorWhite, fontSize: Dimensions.fontLarge),

                //Unselected
                unselectedLabelColor: MyColor.getSecondaryTextColor(),
                unselectedLabelStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge),
                onTap: (value) => controller.changeBuyOrSellTabIndex(value),
                padding: EdgeInsets.zero,

                tabs: [
                  Tab(
                    text: MyStrings.buy.tr,
                  ),
                  Tab(
                    text: MyStrings.sell.tr,
                  ),
                ],
              ),
            ),
            verticalSpace(Dimensions.space10),
            //Text Form
            if (controller.currentBuyOrSellTabIndex == 0) ...[
              //Market Amount
              BuyFormWidget(controller: controller, tradeCoinSymbol: tradeCoinSymbol),
            ] else ...[
              //Buy Form
              SellFormWidget(controller: controller, tradeCoinSymbol: tradeCoinSymbol),
            ]
          ],
        ),
      ),
    );
  }
}
