import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/trade_page/trade_page_controller.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';

class TradeScreenBottomNavBar extends StatelessWidget {
  final TradePageController controller;
  final String tradeCoinSymbol;
  const TradeScreenBottomNavBar({super.key, required this.controller, required this.tradeCoinSymbol});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MyColor.getScreenBgColor(),
            boxShadow: [
              BoxShadow(
                color: MyColor.getPrimaryColor().withOpacity(0.2),
                offset: const Offset(0, -4),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: RoundedButton(
                      color: MyColor.colorGreen,
                      text: MyStrings.buy.tr,
                      press: () {
                        Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: [controller.tradeSymbol, 'buy']);
                      },
                    ),
                  ),
                  horizontalSpace(Dimensions.space15),
                  Expanded(
                    child: RoundedButton(
                      color: MyColor.colorRed,
                      text: MyStrings.sell.tr,
                      press: () {
                        Get.toNamed(
                          RouteHelper.tradeBuySellScreen,
                          arguments: [controller.tradeSymbol, 'sell'],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
