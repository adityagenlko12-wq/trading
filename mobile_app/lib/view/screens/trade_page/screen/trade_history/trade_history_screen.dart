import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/services/api_service.dart';

import '../../../../../data/controller/trade_page/trade_history_controller.dart';
import '../../../../../data/model/trade/trade_history_page_response_model.dart';
import '../../../../../data/repo/market_trade/market_trade_repo.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/no_data.dart';
import 'widgets/trade_history_page_list_tile_widget.dart';

class TradeHistoryScreen extends StatefulWidget {
  final String tradeType;
  const TradeHistoryScreen({super.key, this.tradeType = 'all'});

  @override
  State<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends State<TradeHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  fetchData() {
    Get.find<TradeHistoryController>().loadTradeHistoryData();
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<TradeHistoryController>().hasNext()) {
        fetchData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(MarketTradeRepo(apiClient: Get.find()));
    final controller = Get.put(TradeHistoryController(marketTradeRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialTransactionHistory(tradeTypeParams: widget.tradeType);
      if (widget.tradeType == 'buy') {
        controller.historyTabController?.animateTo(1);
      }
      if (widget.tradeType == 'sell') {
        controller.historyTabController?.animateTo(2);
      }

      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradeHistoryController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.tradeHistory.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
         
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: Column(
          children: [
            verticalSpace(Dimensions.space5),
            Theme(
              data: ThemeData(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                // padding: const EdgeInsets.all(Dimensions.space15),

                child: TabBar(
                  controller: controller.historyTabController,
                  splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  dividerColor: MyColor.getBorderColor(),
                  indicator: null,
                  indicatorColor: MyColor.getPrimaryColor(),

                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: MyColor.getPrimaryTextColor(),
                  labelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  //Unselected
                  unselectedLabelColor: MyColor.getSecondaryTextColor(),
                  unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                  onTap: (value) => controller.changeTabIndex(value),
                  padding: EdgeInsets.zero,

                  tabs:  [
                    Tab(
                      text: MyStrings.all.tr,
                    ),
                    Tab(
                      text: MyStrings.buy.tr,
                    ),
                    Tab(
                      text: MyStrings.sell.tr,
                    ),
                  ],
                ),
              ),
            ),
            verticalSpace(Dimensions.space10),
            controller.isLoading
                ? const SizedBox(height: Dimensions.space100, child: CustomLoader())
                : Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: controller.tradeHistoryDataList.isEmpty && controller.filterLoading == false
                                ? Center(
                                    child: NoDataWidget(
                                      text: MyStrings.noTradeHistoryFound.tr,
                                    ),
                                  )
                                : controller.filterLoading
                                    ? const CustomLoader()
                                    : SizedBox(
                                        height: MediaQuery.of(context).size.height,
                                        child: ListView.separated(
                                          controller: scrollController,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          
                                          padding: Dimensions.screenPaddingHV,
                                          scrollDirection: Axis.vertical,
                                          itemCount: controller.tradeHistoryDataList.length + 1,
                                          separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                          itemBuilder: (context, index) {
                                            if (controller.tradeHistoryDataList.length == index) {
                                              return controller.hasNext()
                                                  ? const CustomLoader(
                                                      isPagination: true,
                                                    )
                                                  : const SizedBox();
                                            }
                                            TradeHistoryPageListData item = controller.tradeHistoryDataList[index];
                    
                                            return TradeHistoryPageListTileWidget(item: item, controller: controller);
                                          },
                                        ),
                                      ))
                      ],
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
