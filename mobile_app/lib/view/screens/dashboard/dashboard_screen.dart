import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/util.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/data/services/api_service.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/dashbaord/dashboard_controller.dart';
import '../../../data/controller/pusher_controller/pusher_service_controller.dart';
import '../../components/will_pop_widget.dart';
import 'screen/home/home_screen.dart';
import 'screen/watchlist/watchlist_screen.dart';
import 'screen/portfolio/portfolio_screen.dart';
import 'screen/orders/orders_screen.dart';
import 'screen/money/money_screen.dart';
import 'widgets/nav_bar_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardController dashboardController;
  late PusherServiceController pusherServiceController;
  late GlobalKey<ScaffoldState> _dashBoardScaffoldKey;
  late List<Widget> _widgets;

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    dashboardController = Get.put(DashboardController(apiClient: Get.find()));
    pusherServiceController = Get.put(PusherServiceController(apiClient: Get.find()));
    _dashBoardScaffoldKey = GlobalKey<ScaffoldState>();

    _widgets = <Widget>[
      const HomeScreen(),
      const WatchlistScreen(),
      const PortfolioScreen(),
      const OrdersScreen(),
      const MoneyScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return GetBuilder<ThemeController>(builder: (themeController) {
        return WillPopWidget(
          child: Scaffold(
              backgroundColor: MyColor.getScreenBgColor(),
              key: _dashBoardScaffoldKey,
              extendBody: true,
              body: _widgets[controller.selectedBottomNavIndex],
              bottomNavigationBar: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: 0),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      NavBarItem(
                          label: "Home",
                          imagePath: MyIcons.naveHome,
                          index: 0,
                          isSelected: controller.selectedBottomNavIndex == 0,
                          press: () {
                            controller.changeSelectedIndex(0);
                            MyUtils.vibrationOn();
                          }),
                      NavBarItem(
                          label: "Watchlist",
                          imagePath: MyIcons.navMarket,
                          index: 1,
                          isSelected: controller.selectedBottomNavIndex == 1,
                          press: () {
                            controller.changeSelectedIndex(1);
                            MyUtils.vibrationOn();
                          }),
                      
                      // Central Floating "ध" button for Portfolio (Index 2)
                      GestureDetector(
                        onTap: () {
                          if (controller.checkUserIsLoggedInOrNot()) {
                            controller.changeSelectedIndex(2);
                          } else {
                            Get.toNamed(RouteHelper.authenticationScreen);
                          }
                          MyUtils.vibrationOn();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: controller.selectedBottomNavIndex == 2
                                      ? MyColor.primaryColor500
                                      : Colors.grey.shade400,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: MyColor.primaryColor500.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "ध",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: controller.selectedBottomNavIndex == 2
                                      ? MyColor.primaryColor500
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Portfolio",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: controller.selectedBottomNavIndex == 2
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: controller.selectedBottomNavIndex == 2
                                    ? MyColor.primaryColor500
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      NavBarItem(
                          label: "Orders",
                          imagePath: MyIcons.tradeIconAction,
                          index: 3,
                          isSelected: controller.selectedBottomNavIndex == 3,
                          press: () {
                            if (controller.checkUserIsLoggedInOrNot()) {
                              controller.changeSelectedIndex(3);
                            } else {
                              Get.toNamed(RouteHelper.authenticationScreen);
                            }
                            MyUtils.vibrationOn();
                          }),
                      NavBarItem(
                          label: "Money",
                          imagePath: MyIcons.navWallet,
                          index: 4,
                          isSelected: controller.selectedBottomNavIndex == 4,
                          press: () {
                            if (controller.checkUserIsLoggedInOrNot()) {
                              controller.changeSelectedIndex(4);
                            } else {
                              Get.toNamed(RouteHelper.authenticationScreen);
                            }
                            MyUtils.vibrationOn();
                          }),
                    ],
                  ),
                ),
              )),
        );
      });
    });
  }
}
