// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/util.dart';
import 'package:vinance/view/components/custom_loader/custom_loader.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/pusher_controller/pusher_service_controller.dart';
import '../../../data/controller/trade_page/trade_page_controller.dart';
import '../../../data/repo/market_trade/market_trade_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_local_image_widget.dart';
import 'widgets/change_trade_currency_symbol_widget.dart';
import 'widgets/order_book_list_widget.dart';
import 'widgets/trade_history_widget.dart';
import 'widgets/trade_screen_bottom_nav_bar.dart';
import 'widgets/trading_view_iframe_widget.dart';

class TradePageScreen extends StatefulWidget {
  final String tradeCoinSymbol;
  const TradePageScreen({super.key, required this.tradeCoinSymbol});

  @override
  State<TradePageScreen> createState() => _TradePageScreenState();
}

class _TradePageScreenState extends State<TradePageScreen> {
  PusherServiceController pusherServiceController = Get.find();
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<TradePageController>().hasNext()) {
        Get.find<TradePageController>().loadOrderListDataList();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(MarketTradeRepo(apiClient: Get.find()));
    final controller = Get.put(TradePageController(marketTradeRepo: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData(symbolID: widget.tradeCoinSymbol);

      scrollController.addListener(scrollListener);
      pusherServiceController.addListener(_onMarketDataUpdate);
    });
  }

  void _onMarketDataUpdate() {
    Get.find<TradePageController>().updateMarketDataBasedOnPusherEvent();
  }

  @override
  void dispose() {
    // Don't forget to remove the listener when the widget is disposed
    pusherServiceController.removeListener(_onMarketDataUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: MyStrings.profile.tr,
            titleWidget: controller.tradeDetailsLoading || controller.marketTradeDetailsModelDATA.status == null
                ? const SizedBox()
                : FittedBox(
                    child: GestureDetector(
                      onTap: () {
                        Get.bottomSheet(ChangeTradeCurrencySymbolWidget(controller: Get.find()), elevation: 0, isScrollControlled: true, ignoreSafeArea: false, backgroundColor: Colors.transparent, barrierColor: Colors.transparent);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyNetworkImageWidget(
                            imageUrl: "${controller.tradeDetailsMarketPair?.coin?.imageUrl}",
                            height: Dimensions.space20,
                            width: Dimensions.space20,
                          ),
                          horizontalSpace(Dimensions.space5),
                          Text(
                            controller.tradeDetailsLoading ? "" : " ${controller.tradeDetailsMarketPair?.coin?.symbol ?? ''}/${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''}",
                            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: MyColor.getAppBarContentColor(),
                            size: Dimensions.space25,
                          )
                        ],
                      ),
                    ),
                  ),
            bgColor: MyColor.getScreenBgColor(),
            titleStyle: boldOverLarge.copyWith(fontSize: Dimensions.fontOverLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
                child: Ink(
                  decoration: ShapeDecoration(
                    color: MyColor.getAppBarBackgroundColor(),
                    shape: const CircleBorder(),
                  ),
                  child: FittedBox(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (controller.checkUserIsLoggedInOrNot()) {
                          controller.addToFav(symbolID: widget.tradeCoinSymbol);
                        } else {
                          Get.toNamed(RouteHelper.authenticationScreen);
                        }
                      },
                      icon: controller.coinAddToFavLoading
                          ? CircularProgressIndicator(
                              color: MyColor.getPrimaryColor(),
                              strokeWidth: 0.5,
                            )
                          : Icon(
                              controller.marketTradeDetailsModelDATA.data?.isFavorite == "true" ? Icons.star_rounded : Icons.star_border_rounded,
                              size: Dimensions.space35,
                              color: controller.marketTradeDetailsModelDATA.data?.isFavorite == "true" ? MyColor.colorYellow : MyColor.getAppBarContentColor(),
                            ),
                    ),
                  ),
                ),
              ),
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: controller.tradeDetailsLoading
              ? const CustomLoader()
              : RefreshIndicator(
                  color: MyColor.getPrimaryColor(),
                  onRefresh: () async {
                    controller.initialDataRefresh();
                  }, // Your refresh logic
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //Left
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          StringConverter.formatNumber(controller.tradeDetailsMarketData?.price ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                          style: boldOverLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontOverLarge),
                                        ),
                                        verticalSpace(Dimensions.space5),
                                        //Rank
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            MyLocalImageWidget(
                                              imagePath: (controller.tradeDetailsMarketData?.htmlClasses?.percentChange1H?.toLowerCase() == 'up') ? MyIcons.arrowUp : MyIcons.arrowDown,
                                              height: Dimensions.space15,
                                              width: Dimensions.space15,
                                              imageOverlayColor: (controller.tradeDetailsMarketData?.htmlClasses?.percentChange1H?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed,
                                            ),
                                            horizontalSpace(Dimensions.space5),
                                            Text(
                                              "${controller.tradeDetailsMarketData?.htmlClasses?.percentChange1H?.toLowerCase() == 'up' ? "+" : "-"}${StringConverter.formatNumber(controller.tradeDetailsMarketData?.percentChange1H ?? '0', precision: 2)}%",
                                              style: regularMediumLarge.copyWith(color: (controller.tradeDetailsMarketData?.htmlClasses?.percentChange1H?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  //Right
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        MyStrings.marketCap.tr,
                                        style: semiBoldLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                      ),
                                      Text(
                                        MyUtils.formatNumberAbbreviated("${controller.tradeDetailsMarketData?.marketCap.toString() == "null" ? '0.0' : controller.tradeDetailsMarketData?.marketCap.toString()}"),
                                        style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                      verticalSpace(Dimensions.space10),
                                      Text(
                                        MyStrings.changes24HSort.tr,
                                        style: semiBoldLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                      ),
                                      Text(
                                        "${controller.tradeDetailsMarketData?.htmlClasses?.percentChange24H?.toLowerCase() == 'up' ? "+" : "-"}${StringConverter.formatNumber(controller.tradeDetailsMarketData?.percentChange24H ?? '0', precision: 2)}%",
                                        style: semiBoldLarge.copyWith(color: (controller.tradeDetailsMarketData?.htmlClasses?.percentChange24H?.toLowerCase() == 'up') ? MyColor.colorGreen : MyColor.colorRed),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            //Tradeview
                            if (controller.tradeDetailsMarketPair != null) ...[
                              Container(
                                margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space15),
                                height: MediaQuery.of(context).size.height / 1.85,
                                  child: () {
                                    final coinSymbol = controller.tradeDetailsMarketPair?.coin?.symbol ?? '';
                                    var tvSymbol = coinSymbol.replaceAll("_", "").replaceAll("/", "");
                                    var exchange = controller.tradeDetailsMarketPair?.listedMarketName ?? 'NSE';
                                    
                                    // Map special index symbols for TradingView
                                    if (tvSymbol == 'FINNIFTY') {
                                      tvSymbol = 'CNXFINANCE';
                                      exchange = 'NSE';
                                    } else if (tvSymbol == 'MIDCPNIFTY') {
                                      tvSymbol = 'NIFTY_MID_SELECT';
                                      exchange = 'NSE';
                                    } else if (tvSymbol == 'SENSEX') {
                                      exchange = 'BSE';
                                    } else if (tvSymbol == 'NIFTY') {
                                      tvSymbol = 'NIFTY_50';
                                      exchange = 'NSE';
                                    } else if (tvSymbol == 'BANKNIFTY') {
                                      tvSymbol = 'NIFTY_BANK';
                                      exchange = 'NSE';
                                    }
                                    
                                    // Default exchange fallback from 'INR' to 'NSE'
                                    if (exchange == 'INR' || exchange == 'USD') {
                                      exchange = 'NSE';
                                    }
                                    
                                    return TreadingViewFrameWidget(
                                      symbolName: "$exchange:$tvSymbol",
                                    );
                                  }(),
                              ),
                            ]
                          ],
                        ),
                      ),
                      SliverStickyHeader(
                        header: Theme(
                          data: ThemeData(),
                          child: Column(
                            children: [
                              Container(
                                color: MyColor.getScreenBgColor(),
                                child: TabBar(
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: controller.tabController,
                                  splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                  dividerColor: MyColor.getBorderColor(),
                                  indicator: null,
                                  indicatorColor: MyColor.getPrimaryColor(),

                                  indicatorSize: TabBarIndicatorSize.label,
                                  labelColor: MyColor.getPrimaryTextColor(),
                                  labelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                                  tabAlignment: TabAlignment.start,

                                  //Unselected
                                  unselectedLabelColor: MyColor.getSecondaryTextColor(),
                                  unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                                  onTap: (value) => controller.changeMainTabIndex(value),
                                  padding: EdgeInsets.zero,
                                  isScrollable: true,
                                  tabs: [
                                    Tab(
                                      text: MyStrings.orderBook.tr,
                                    ),
                                    Tab(
                                      text: MyStrings.tradeHistory.tr,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * (6 / 11)),
                            child: [
                              OrderBookListWidgetList(controller: controller),
                              TradeHistoryListWidget(controller: controller),
                            ].elementAt(controller.currentIndex),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: TradeScreenBottomNavBar(controller: controller, tradeCoinSymbol: widget.tradeCoinSymbol),
        ),
      );
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _SliverAppBarContainerDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final Widget child;

  _SliverAppBarContainerDelegate({
    required this.expandedHeight,
    required this.child,
  });

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.blue, // Adjust the color as needed
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarContainerDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight || child != oldDelegate.child;
  }
}
