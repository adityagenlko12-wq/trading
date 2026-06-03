import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../data/controller/home/home_controller.dart';
import 'home_action_menu_button_widget.dart';

class HomeScreenActionMenu extends StatelessWidget {
  const HomeScreenActionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          HomeActionMenuButtonWidget(
            image: MyIcons.tradeIconAction,
            title: MyStrings.trade,
            onTap: () {
              Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: ['', 'buy'], preventDuplicates: true);
            },
          ),
          HomeActionMenuButtonWidget(
            image: MyIcons.sendAction,
            title: MyStrings.transfer,
            onTap: () {
              Get.toNamed(
                RouteHelper.transferScreen,
              );
            },
          ),
          HomeActionMenuButtonWidget(
            image: MyIcons.tradeMarketGrowthIconAction,
            title: "Options",
            onTap: () {
              final homeController = Get.find<HomeController>();
              if (homeController.checkUserIsLoggedInOrNot()) {
                Get.toNamed(RouteHelper.optionsChainScreen);
              } else {
                Get.toNamed(RouteHelper.authenticationScreen);
              }
            },
          ),
          HomeActionMenuButtonWidget(
            image: MyIcons.withdrawAction,
            title: MyStrings.withdraw,
            onTap: () {
              Get.toNamed(
                RouteHelper.withdrawScreen,
              );
            },
          ),
          HomeActionMenuButtonWidget(
            image: MyIcons.transactionAction,
            title: MyStrings.transaction,
            onTap: () {
              Get.toNamed(
                RouteHelper.walletHistoryScreen,
              );
            },
          ),
        ],
      ),
    );
  }
}
