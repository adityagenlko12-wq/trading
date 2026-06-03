import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/data/controller/market/market_controller.dart';
import 'package:vinance/view/components/no_data.dart';

import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/pusher_controller/pusher_service_controller.dart';
import '../../../../../data/repo/market_trade/market_trade_repo.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import '../../../../components/shimmer/market_page_shimmer.dart';
import 'widgets/market_screen_app_bar.dart';
import 'widgets/market_screen_sort_by.dart';
import 'widgets/market_screen_tread_coin__pair_list.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  PusherServiceController pusherServiceController = Get.find();

  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    var marketController = Get.find<MarketController>();
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (marketController.hasNextMarket()) {
        marketController.loadMarketPairDataList(marketID: marketController.marketID, search: marketController.searchText, shouldShowLoad: false);
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(MarketTradeRepo(apiClient: Get.find()));
    final controller = Get.put(MarketController(marketTradeRepo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pusherServiceController.initPusher("market-data");
      pusherServiceController.initPusher("trade");
      controller.initialMarketData();
      pusherServiceController.addListener(_onMarketDataUpdate);
    });
  }

  void _onMarketDataUpdate() {
    Get.find<MarketController>().updateMarketDataBasedOnPusherEvent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarketController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: MarketScreenAppBar(
          controller: controller,
          appBarSize: Dimensions.space100 + 10,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
        ),
        body: controller.isMarketDataLoading
            ? const MarketPageShimmer()
            : RefreshIndicator(
                color: MyColor.getPrimaryColor(),
                onRefresh: () async {
                  controller.initialMarketData();
                },
                child: Column(
                  children: [
                    //Title
                    Container(
                      margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            MyStrings.trade.tr,
                            style: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton(
                                color: MyColor.getScreenBgSecondaryColor(),
                                offset: const Offset(-10, 60),
                                onSelected: (value) {
                                  if (controller.checkUserIsLoggedInOrNot()) {
                                    if (value == 0) {
                                      Get.toNamed(RouteHelper.tradeHistoryScreen, arguments: 'all');
                                    }
                                    if (value == 1) {
                                      Get.toNamed(RouteHelper.myOrderHistoryScreen, arguments: 'all');
                                    }
                                  } else {
                                    Get.toNamed(RouteHelper.authenticationScreen);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 0,
                                    child: Text(
                                      MyStrings.tradeHistory.tr,
                                      style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(
                                      MyStrings.orderHistory.tr,
                                      style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                    ),
                                  ),
                                ],
                                tooltip: MyStrings.history.tr,
                                icon: Padding(
                                  padding: const EdgeInsetsDirectional.only(),
                                  child: Ink(
                                    decoration: ShapeDecoration(
                                      color: MyColor.getAppBarBackgroundColor(),
                                      shape: const CircleBorder(),
                                    ),
                                    child: FittedBox(
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: null,
                                        icon: MyLocalImageWidget(
                                          imagePath: MyIcons.historyIcon,
                                          imageOverlayColor: MyColor.getSecondaryTextColor(),
                                          width: Dimensions.space25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    verticalSpace(Dimensions.space10),
                    //Tab Bars
                    if (controller.currencyMarketData.isNotEmpty) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                              // padding: const EdgeInsets.all(Dimensions.space15),
                              decoration: BoxDecoration(
                                color: MyColor.getScreenBgSecondaryColor(),
                                borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                border: Border.all(
                                  width: 1,
                                  color: MyColor.getBorderColor(),
                                ),
                              ),
                              child: TabBar(
                                controller: controller.tabController,
                                splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: MyColor.getTabBarTabColor(),
                                  borderRadius: controller.currentIndex == 0
                                      ? const BorderRadiusDirectional.only(
                                          topStart: Radius.circular(Dimensions.cardRadius1),
                                          bottomStart: Radius.circular(Dimensions.cardRadius1),
                                        )
                                      : controller.currentIndex == 6
                                          ? const BorderRadiusDirectional.only(
                                              topEnd: Radius.circular(Dimensions.cardRadius1),
                                              bottomEnd: Radius.circular(Dimensions.cardRadius1),
                                            )
                                          : null,
                                ),

                                indicatorSize: TabBarIndicatorSize.tab,
                                labelColor: MyColor.getPrimaryTextColor(),
                                labelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                                isScrollable: true,
                                physics: const BouncingScrollPhysics(),
                                tabAlignment: TabAlignment.start,
                                //Unselected
                                unselectedLabelColor: MyColor.getSecondaryTextColor(),
                                unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                                onTap: (value) {
                                  var tabItem = controller.currencyMarketData[value];
                                  printx(tabItem.id);
                                  controller.changeTabIndex(value);

                                  controller.loadMarketPairDataList(marketID: tabItem.id == -1 ? '' : tabItem.id.toString(), hotRefresh: true, search: controller.searchTextController.text, shouldShowLoad: true);
                                },
                                padding: EdgeInsets.zero,
                                tabs: List.generate(controller.currencyMarketData.length, (index) {
                                  var tabItem = controller.currencyMarketData[index];
                                  return Tab(
                                    text: (tabItem.id == -1 ? "${tabItem.name?.tr}" : "${tabItem.currency?.symbol}").tr,
                                  );
                                }),
                              ),
                            ),

                            verticalSpace(Dimensions.space20),
                            //Sort by
                            MarketScreenSortByWidget(controller: controller),

                            Expanded(child: MarketScreenCoinPairList(controller: controller, scrollController: scrollController)),
                          ],
                        ),
                      ),
                    ] else ...[
                      const NoDataWidget()
                    ]
                  ],
                ),
              ),
      );
    });
  }
}
