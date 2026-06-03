// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:vinance/data/controller/market/market_controller.dart';
import 'package:vinance/view/components/no_data.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../data/model/market/market_pair_list_data_model.dart';
import '../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../components/shimmer/market_page_market_list_data_shimmer.dart';
import 'market_screen_coin_pair_card.dart';

class MarketScreenCoinPairList extends StatelessWidget {
  final MarketController controller;
  final ScrollController scrollController;
  const MarketScreenCoinPairList({super.key, required this.controller, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(
        start: Dimensions.space15,
        end: Dimensions.space15,
        top: Dimensions.space15,
      ),
      alignment: Alignment.centerLeft,
      child: controller.isMarketPairTabDataListLoading
          ? const MarketPageMarketTradeListDataShimmer(
              length: 8,
            )
          : controller.filteredMarketPairDataList.isEmpty
              ? const Center(child: NoDataWidget())
              : ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: controller.filteredMarketPairDataList.length + 1,
                  itemBuilder: (context, index) {
                    if (controller.filteredMarketPairDataList.length == (index)) {
                      return controller.hasNextMarket() ? const CustomLoader(isPagination: true) : const SizedBox();
                    }
                    MarketSinglePairData item = controller.filteredMarketPairDataList[index];
                    return MarketScreenCoinPairListCard(
                      item: item,
                      controller: controller,
                    );
                  },
                ),
    );
  }
}
