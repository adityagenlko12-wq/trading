// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/route/route.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/util.dart';
import '../../../../../data/controller/pusher_controller/pusher_service_controller.dart';
import '../../../../../data/controller/trade_page/trade_page_controller.dart';
import '../../../../../data/repo/market_trade/market_trade_repo.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import '../../../../components/image/my_network_image_widget.dart';
import '../../widgets/change_trade_currency_symbol_widget.dart';
import '../../widgets/my_order_info_widget.dart';
import '../../widgets/trade_history_widget.dart';

import 'widgets/price_range_slider_widget.dart';
import 'widgets/markets_today_widget.dart';
import 'widgets/historical_performance_widget.dart';
import 'widgets/underlying_performance_widget.dart';
import 'widgets/action_buttons_row_widget.dart';
import 'widgets/simple_line_chart_widget.dart';
import 'widgets/buy_form_widget.dart';
import 'widgets/sell_form_widget.dart';

class TradeBuySellScreen extends StatefulWidget {
  final String tradeCoinSymbol;
  final String typeBuyOrSell;
  const TradeBuySellScreen({super.key, required this.tradeCoinSymbol, required this.typeBuyOrSell});

  @override
  State<TradeBuySellScreen> createState() => _TradeBuySellScreenState();
}

class _TradeBuySellScreenState extends State<TradeBuySellScreen> {
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
      if (widget.typeBuyOrSell == 'sell') {
        Get.find<TradePageController>().changeBuyOrSellTabIndex(1);
      } else {
        Get.find<TradePageController>().changeBuyOrSellTabIndex(0);
      }
      pusherServiceController.addListener(_onMarketDataUpdate);
    });
  }

  void _onMarketDataUpdate() {
    Get.find<TradePageController>().updateMarketDataBasedOnPusherEvent();
  }

  @override
  void dispose() {
    pusherServiceController.removeListener(_onMarketDataUpdate);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      final String symbol = controller.tradeSymbol;
      final String companyName = controller.tradeDetailsMarketPair?.coin?.name ?? symbol;
      final String exchange = controller.tradeDetailsMarketData?.exchange ?? 'NSE';
      final String price = controller.tradeDetailsMarketData?.price ?? '0.0';
      final String pctChange = controller.tradeDetailsMarketData?.percentChange24H ?? '0.0';
      final String amtChange = controller.tradeDetailsMarketData?.dayChange ?? '0.0';
      final bool isUp = (controller.tradeDetailsMarketData?.htmlClasses?.percentChange24H?.toLowerCase() == 'up') || (double.tryParse(pctChange) ?? 0) >= 0;
      
      final double currentPriceVal = double.tryParse(price) ?? 0.0;
      final double yearHighVal = double.tryParse(controller.tradeDetailsMarketData?.yearHigh ?? '') ?? (currentPriceVal * 1.12);
      final double yearLowVal = double.tryParse(controller.tradeDetailsMarketData?.yearLow ?? '') ?? (currentPriceVal * 0.94);

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
                        Get.bottomSheet(
                          ChangeTradeCurrencySymbolWidget(controller: Get.find()),
                          elevation: 0,
                          isScrollControlled: true,
                          ignoreSafeArea: false,
                          backgroundColor: Colors.transparent,
                          barrierColor: Colors.transparent,
                        );
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
                        Get.toNamed(RouteHelper.tradeViewDetailsScreen, arguments: controller.tradeSymbol);
                      },
                      icon: MyLocalImageWidget(
                        imagePath: MyIcons.tradeMarketGrowthIconAction,
                        height: Dimensions.space30,
                        imageOverlayColor: MyColor.getAppBarContentColor(),
                      ),
                    ),
                  ),
                ),
              ),
              horizontalSpace(Dimensions.space10),
            ],
          ),
          bottomNavigationBar: controller.tradeDetailsLoading || controller.marketTradeDetailsModelDATA.status == null
              ? null
              : _buildBottomActionBar(context, controller),
          body: controller.tradeDetailsLoading
              ? const CustomLoader()
              : RefreshIndicator(
                  color: MyColor.getPrimaryColor(),
                  onRefresh: () async {
                    controller.initialDataRefresh();
                  },
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpace(Dimensions.space15),
                              // Live pulsing dot + Exchange + Symbol
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isUp ? MyColor.colorGreen.withOpacity(0.1) : MyColor.colorRed.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          exchange,
                                          style: boldExtraSmall.copyWith(
                                            color: isUp ? MyColor.colorGreen : MyColor.colorRed,
                                          ),
                                        ),
                                      ),
                                      horizontalSpace(8),
                                      Text(
                                        symbol,
                                        style: semiBoldMediumLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                      ),
                                    ],
                                  ),
                                  // Live Pulsing Dot
                                  Row(
                                    children: [
                                      const LiveDot(),
                                      horizontalSpace(6),
                                      Text(
                                        "LIVE",
                                        style: boldExtraSmall.copyWith(color: MyColor.colorRed, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              verticalSpace(Dimensions.space5),
                              // Company Name
                              Text(
                                companyName,
                                style: boldOverLarge.copyWith(
                                  color: MyColor.getPrimaryTextColor(),
                                  fontSize: 24,
                                ),
                              ),
                              verticalSpace(Dimensions.space10),
                              // Current Price and price change info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    "${controller.tradeDetailsMarketPair?.market?.currency?.symbol ?? ''} ${StringConverter.formatNumber(price, precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber())}",
                                    style: boldOverLarge.copyWith(
                                      color: MyColor.getPrimaryTextColor(),
                                      fontSize: 28,
                                    ),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(
                                    "${isUp ? "+" : ""}${StringConverter.formatNumber(amtChange, precision: 2)} (${isUp ? "+" : ""}${StringConverter.formatNumber(pctChange, precision: 2)}%)",
                                    style: regularMediumLarge.copyWith(
                                      color: isUp ? MyColor.colorGreen : MyColor.colorRed,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              verticalSpace(Dimensions.space20),
                              // Simple Line Chart
                              SimpleLineChartWidget(
                                height: 220,
                                lineColor: isUp ? MyColor.colorGreen : MyColor.colorRed,
                              ),
                              verticalSpace(Dimensions.space20),
                              // Action buttons
                              ActionButtonsRowWidget(
                                onChartTap: () {
                                  Get.toNamed(RouteHelper.tradeViewDetailsScreen, arguments: controller.tradeSymbol);
                                },
                                onWatchlistTap: () {
                                  // toggle watchlist
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              // Markets Today Card
                              MarketsTodayWidget(
                                open: controller.tradeDetailsMarketData?.open ?? '0.0',
                                high: controller.tradeDetailsMarketData?.high ?? '0.0',
                                low: controller.tradeDetailsMarketData?.low ?? '0.0',
                                prevClose: controller.tradeDetailsMarketData?.prevClose ?? '0.0',
                                currentPrice: currentPriceVal,
                              ),
                              verticalSpace(Dimensions.space15),
                              // Historical Performance Card
                              HistoricalPerformanceWidget(
                                currentPrice: currentPriceVal,
                                yearHigh: yearHighVal,
                                yearLow: yearLowVal,
                              ),
                              verticalSpace(Dimensions.space15),
                              // Underlying Performance Card
                              const UnderlyingPerformanceWidget(
                                positiveStocks: 27,
                                negativeStocks: 23,
                              ),
                              verticalSpace(Dimensions.space15),
                            ],
                          ),
                        ),
                      ),
                      // Market Depth Card
                      SliverToBoxAdapter(
                        child: _buildMarketDepth(controller),
                      ),
                      // Sliver Sticky Header for Orders & Trade History Tabs
                      SliverStickyHeader(
                        header: Container(
                          color: MyColor.getScreenBgColor(),
                          child: TabBar(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: controller.tabTradePageController,
                            splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                            dividerColor: MyColor.getBorderColor(),
                            indicatorColor: MyColor.getPrimaryColor(),
                            indicatorSize: TabBarIndicatorSize.label,
                            labelColor: MyColor.getPrimaryTextColor(),
                            labelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                            tabAlignment: TabAlignment.start,
                            unselectedLabelColor: MyColor.getSecondaryTextColor(),
                            unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                            onTap: (value) => controller.changeTabTradeIndex(value),
                            padding: EdgeInsets.zero,
                            isScrollable: true,
                            tabs: [
                              Tab(text: MyStrings.myOrder.tr),
                              Tab(text: MyStrings.tradeHistory.tr),
                            ],
                          ),
                        ),
                        sliver: SliverToBoxAdapter(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height * 0.5,
                            ),
                            child: [
                              MyOrderListWidget(
                                controller: controller,
                                scrollController: scrollController,
                                tradeCoinSymbol: widget.tradeCoinSymbol,
                              ),
                              TradeHistoryListWidget(controller: controller),
                            ].elementAt(controller.currentTradePageIndex),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildBottomActionBar(BuildContext context, TradePageController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
      decoration: BoxDecoration(
        color: MyColor.getScreenBgColor(),
        border: Border(
          top: BorderSide(
            color: MyColor.getBorderColor(),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Option Chain Button
            InkWell(
              onTap: () {
                // Navigate to Option Chain Screen
                Get.toNamed(RouteHelper.optionsChainScreen, arguments: controller.tradeSymbol);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  border: Border.all(color: MyColor.getBorderColor(), width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.link,
                      color: MyColor.getPrimaryColor(),
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Option Chain",
                      style: regularExtraSmall.copyWith(
                        color: MyColor.getPrimaryColor(),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Dimensions.space10),
            // SELL Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.colorRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  ),
                ),
                onPressed: () {
                  _showBuySellBottomSheet(context, controller, isBuy: false);
                },
                child: Text(
                  MyStrings.sell.tr.toUpperCase(),
                  style: boldMediumLarge.copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.space10),
            // BUY Button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.colorGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.space12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  ),
                ),
                onPressed: () {
                  _showBuySellBottomSheet(context, controller, isBuy: true);
                },
                child: Text(
                  MyStrings.buy.tr.toUpperCase(),
                  style: boldMediumLarge.copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBuySellBottomSheet(BuildContext context, TradePageController controller, {required bool isBuy}) {
    if (isBuy) {
      controller.changeBuyOrSellTabIndex(0);
    } else {
      controller.changeBuyOrSellTabIndex(1);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              color: MyColor.getScreenBgColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: Dimensions.space15,
              right: Dimensions.space15,
              top: Dimensions.space15,
              bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.space20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull Handle
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MyColor.getBorderColor(),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  verticalSpace(Dimensions.space15),
                  // Header (Title & Price)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${isBuy ? MyStrings.buy.tr : MyStrings.sell.tr} ${controller.tradeDetailsMarketPair?.coin?.symbol ?? ''}",
                            style: boldExtraLarge.copyWith(
                              color: isBuy ? MyColor.colorGreen : MyColor.colorRed,
                            ),
                          ),
                          verticalSpace(Dimensions.space3),
                          Text(
                            controller.tradeDetailsMarketPair?.coin?.name ?? '',
                            style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            StringConverter.formatNumber(controller.tradeDetailsMarketData?.price ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                            style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                          verticalSpace(Dimensions.space3),
                          Row(
                            children: [
                              Text(
                                "${controller.tradeDetailsMarketData?.htmlClasses?.percentChange24H?.toLowerCase() == 'up' ? "+" : "-"}${StringConverter.formatNumber(controller.tradeDetailsMarketData?.percentChange24H ?? '0', precision: 2)}%",
                                style: regularSmall.copyWith(
                                  color: controller.tradeDetailsMarketData?.htmlClasses?.percentChange24H?.toLowerCase() == 'up' ? MyColor.colorGreen : MyColor.colorRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpace(Dimensions.space15),
                  Divider(color: MyColor.getBorderColor(), height: 1, thickness: 0.5),
                  verticalSpace(Dimensions.space15),
                  // Form Widget
                  isBuy
                      ? BuyFormWidget(controller: controller, tradeCoinSymbol: widget.tradeCoinSymbol)
                      : SellFormWidget(controller: controller, tradeCoinSymbol: widget.tradeCoinSymbol),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketDepth(TradePageController controller) {
    double totalBidQty = 0;
    for (var item in controller.buySideOrderList) {
      totalBidQty += double.tryParse(item.totalAmount ?? '0') ?? 0;
    }
    double totalAskQty = 0;
    for (var item in controller.sellSideOrder) {
      totalAskQty += double.tryParse(item.amount ?? '0') ?? 0;
    }
    double totalQty = totalBidQty + totalAskQty;
    double bidPercent = totalQty > 0 ? (totalBidQty / totalQty) : 0.5;
    double askPercent = totalQty > 0 ? (totalAskQty / totalQty) : 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
      decoration: BoxDecoration(
        color: MyColor.colorWhite,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
        border: Border.all(
          color: MyColor.getBorderColor(),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Depth',
            style: semiBoldDefault.copyWith(color: MyColor.getPrimaryTextColor()),
          ),
          verticalSpace(Dimensions.space3),
          Divider(color: MyColor.getBorderColor(), height: 1, thickness: 0.5),
          verticalSpace(Dimensions.space10),
          // Table headers
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bid Price', style: regularExtraSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                    Text('Qty', style: regularExtraSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ask Price', style: regularExtraSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                    Text('Qty', style: regularExtraSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(Dimensions.space8),
          // Table content
          controller.tradeDetailsOrderBookLoading 
            ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bids (Left)
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        if (index >= controller.buySideOrderList.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('-', style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                                Text('-', style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                              ],
                            ),
                          );
                        }
                        var item = controller.buySideOrderList[index];
                        return InkWell(
                          onTap: () => controller.setOrderBookPriceToInputBox(item.rate ?? '0.0'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularSmall.copyWith(color: MyColor.colorGreen, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  MyUtils.formatNumberAbbreviated(item.totalAmount ?? '0'),
                                  style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Asks (Right)
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        if (index >= controller.sellSideOrder.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('-', style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                                Text('-', style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                              ],
                            ),
                          );
                        }
                        var item = controller.sellSideOrder[index];
                        return InkWell(
                          onTap: () => controller.setOrderBookPriceToInputBox(item.rate ?? '0.0'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  StringConverter.formatNumber(item.rate ?? '0.0', precision: controller.marketTradeRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularSmall.copyWith(color: MyColor.colorRed, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  MyUtils.formatNumberAbbreviated(item.amount ?? '0'),
                                  style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
          verticalSpace(Dimensions.space15),
          // Ratio bar
          if (!controller.tradeDetailsOrderBookLoading && (totalBidQty > 0 || totalAskQty > 0)) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(bidPercent * 100).toStringAsFixed(0)}% Buy', style: semiBoldExtraSmall.copyWith(color: MyColor.colorGreen)),
                Text('${(askPercent * 100).toStringAsFixed(0)}% Sell', style: semiBoldExtraSmall.copyWith(color: MyColor.colorRed)),
              ],
            ),
            verticalSpace(Dimensions.space5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Row(
                children: [
                  Expanded(
                    flex: (bidPercent * 100).round().clamp(1, 99),
                    child: Container(height: 6, color: MyColor.colorGreen),
                  ),
                  Expanded(
                    flex: (askPercent * 100).round().clamp(1, 99),
                    child: Container(height: 6, color: MyColor.colorRed),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LiveDot extends StatefulWidget {
  const LiveDot({super.key});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: MyColor.colorRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
