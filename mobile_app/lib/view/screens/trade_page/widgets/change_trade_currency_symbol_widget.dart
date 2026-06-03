import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_icons.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/trade_page/trade_page_controller.dart';
import '../../../../data/model/market/market_pair_list_data_model.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/image/my_local_image_widget.dart';
import '../../../components/no_data.dart';
import '../../../components/shimmer/market_page_market_list_data_shimmer.dart';
import 'tarde_page_screen_sort_by.dart';
import 'trade_page_filter_market_pair_list_card.dart';

class ChangeTradeCurrencySymbolWidget extends StatefulWidget {
  final TradePageController controller;
  const ChangeTradeCurrencySymbolWidget({super.key, required this.controller});

  @override
  State<ChangeTradeCurrencySymbolWidget> createState() => _ChangeTradeCurrencySymbolWidgetState();
}

class _ChangeTradeCurrencySymbolWidgetState extends State<ChangeTradeCurrencySymbolWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TradePageController>(builder: (controller) {
      return SafeArea(
        child: Stack(
          children: [
            //Main code
            Container(
              margin: const EdgeInsetsDirectional.only(top: Dimensions.space20),
              decoration: BoxDecoration(
                color: MyColor.getScreenBgColor(),
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(25),
                  topStart: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.getPrimaryColor().withOpacity(0.2),
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  verticalSpace(Dimensions.space30),
                  //search
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: Dimensions.space10, bottom: Dimensions.space10, start: Dimensions.space15, end: Dimensions.space15),
                    padding: const EdgeInsetsDirectional.only(top: Dimensions.space10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: MyColor.getPrimaryColor()),
                              color: MyColor.getScreenBgSecondaryColor(),
                              borderRadius: BorderRadius.circular(Dimensions.radiusMax),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  horizontalSpace(Dimensions.space10),
                                  Icon(Icons.search, size: Dimensions.space25, color: MyColor.getPrimaryColor()),
                                  horizontalSpace(Dimensions.space10),
                                  Expanded(
                                    child: TextField(
                                      controller: controller.searchTextController,
                                      decoration: InputDecoration(
                                        hintText: "${MyStrings.search.tr}...",
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        controller.filterMarketPairData(filterTypeParam: 'search');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        horizontalSpace(Dimensions.space5),
                        TextButton(
                          onPressed: () {
                            controller.searchTextController.clear();
                            controller.filterMarketPairData(filterTypeParam: 'search');
                            Get.back();
                          },
                          child: Text(
                            MyStrings.cancel.tr,
                            style: regularMediumLarge.copyWith(color: MyColor.colorRed),
                          ),
                        )
                      ],
                    ),
                  ),

                  //Filter

                  //Sort by
                  verticalSpace(Dimensions.space10),
                  TradePageScreenSortByWidget(controller: controller),

                  //Data list

                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      width: double.infinity,
                      child: controller.isMarketPairTabDataListLoading
                          ? const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: MarketPageMarketTradeListDataShimmer(
                                length: 8,
                              ),
                            )
                          : controller.filteredMarketPairDataList.isEmpty
                              ? const Center(child: NoDataWidget())
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space25),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.filteredMarketPairDataList.length + 1,
                                  itemBuilder: (context, index) {
                                    if (controller.filteredMarketPairDataList.length == (index)) {
                                      return controller.hasNextMarket() ? const CustomLoader(isPagination: true) : const SizedBox();
                                    }
                                    MarketSinglePairData item = controller.filteredMarketPairDataList[index];
                                    return TradePageFilterMarketPairListCard(
                                      item: item,
                                      controller: controller,
                                    );
                                  }),
                    ),
                  )
                  // Expanded(
                ],
              ),
            ),

            //bottom sheet closer
            Positioned(
              top: 0,
              left: 20,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(),
                child: Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: MyColor.getTabBarTabBackgroundColor(),
                      shape: const CircleBorder(),
                    ),
                    child: FittedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.back();
                        },
                        icon: MyLocalImageWidget(
                          imagePath: MyIcons.doubleArrowDown,
                          imageOverlayColor: MyColor.getPrimaryTextColor(),
                          width: Dimensions.space25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
