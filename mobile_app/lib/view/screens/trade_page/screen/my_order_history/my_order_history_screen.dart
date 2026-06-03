import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/services/api_service.dart';

import '../../../../../data/controller/my_order/my_order_history_controller.dart';
import '../../../../../data/model/order/order_history_page_response_model.dart';
import '../../../../../data/repo/market_trade/market_trade_repo.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/no_data.dart';
import 'widgets/order_history_page_list_tile_widget.dart';

class MyOrderHistoryScreen extends StatefulWidget {
  final String orderHistoryType;
  const MyOrderHistoryScreen({super.key, this.orderHistoryType = 'all'});

  @override
  State<MyOrderHistoryScreen> createState() => _MyOrderHistoryScreenState();
}

class _MyOrderHistoryScreenState extends State<MyOrderHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  fetchData() {
    Get.find<MyOrderHistoryController>().loadOrderHistoryData();
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<MyOrderHistoryController>().hasNext()) {
        fetchData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(MarketTradeRepo(apiClient: Get.find()));
    final controller = Get.put(MyOrderHistoryController(marketTradeRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialOrderHistory(orderHistoryTypeParams: widget.orderHistoryType);
      if (widget.orderHistoryType == 'open') {
        controller.historyTabController?.animateTo(1);
      }
      if (widget.orderHistoryType == 'completed') {
        controller.historyTabController?.animateTo(2);
      }
      if (widget.orderHistoryType == 'canceled') {
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
    return GetBuilder<MyOrderHistoryController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.orderHistory.tr,
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

                  tabs: [
                    Tab(
                      text: MyStrings.all.tr,
                    ),
                    Tab(
                      text: MyStrings.open.tr,
                    ),
                    Tab(
                      text: MyStrings.completed.tr,
                    ),
                    Tab(
                      text: MyStrings.canceled.tr,
                    ),
                  ],
                ),
              ),
            ),
            controller.isLoading
                ? const SizedBox(height: Dimensions.space100, child: CustomLoader())
                : Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: controller.orderHistoryDataList.isEmpty && controller.filterLoading == false
                                    ? Center(
                                        child: NoDataWidget(
                                          text: MyStrings.noTradeHistoryFound.tr,
                                        ),
                                      )
                                    : controller.filterLoading
                                        ? const CustomLoader()
                                        : RefreshIndicator(
                                            color: MyColor.getPrimaryColor(),
                                            onRefresh: () async {
                                              controller.initialOrderHistory(orderHistoryTypeParams: widget.orderHistoryType);
                                            }, // Your refresh logic

                                            child: SizedBox(
                                              height: MediaQuery.of(context).size.height,
                                              child: ListView.separated(
                                                controller: scrollController,
                                                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                                shrinkWrap: true,
                                                padding: const EdgeInsetsDirectional.only(top: Dimensions.space15),
                                                scrollDirection: Axis.vertical,
                                                itemCount: controller.orderHistoryDataList.length + 1,
                                                separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                                itemBuilder: (context, index) {
                                                  if (controller.orderHistoryDataList.length == index) {
                                                    return controller.hasNext()
                                                        ? const CustomLoader(
                                                            isPagination: true,
                                                          )
                                                        : const SizedBox();
                                                  }
                                                  OrderHistoryPageResponseModelData item = controller.orderHistoryDataList[index];

                                                  return OrderHistoryPageListTileWidget(item: item, controller: controller);
                                                },
                                              ),
                                            ),
                                          ))
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
