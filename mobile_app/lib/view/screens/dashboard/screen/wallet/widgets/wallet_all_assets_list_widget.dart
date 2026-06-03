import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';

import '../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/wallet/wallet_controller.dart';
import '../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_network_image_widget.dart';
import '../../../../../components/no_data.dart';
import '../../../../../components/shimmer/market_page_market_list_data_shimmer.dart';

class WalletAllAssetsListWidget extends StatelessWidget {
  final WalletController controller;
  final ScrollController scrollController;

  const WalletAllAssetsListWidget({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return controller.isWalletListLoading
        ? SizedBox(height: MediaQuery.of(context).size.height, child: const MarketPageMarketTradeListDataShimmer())
        : controller.walletDataList.isEmpty
            ? const NoDataWidget(
                text: MyStrings.noWalletFound,
              )
            : ListView.builder(
                // controller: scrollController,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space5),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.walletDataList.length,
                itemBuilder: (context, index) {
                  var item = controller.walletDataList[index];
                  if (controller.walletDataList.length == (index + 1)) {
                    return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                  }
                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteHelper.walletSingleCoinDetailsScreen, arguments: [(item.currency?.symbol ?? ''), controller.walletTabController?.index == 0 ? 'spot' : 'funding']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
                      ),
                      padding: const EdgeInsets.all(Dimensions.space10),
                      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Worth
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyNetworkImageWidget(
                                  imageUrl: item.currency?.imageUrl ?? '',
                                  width: Dimensions.space40,
                                  height: Dimensions.space40,
                                  radius: Dimensions.cardRadius2,
                                ),
                                horizontalSpace(Dimensions.space10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.currency?.symbol ?? '',
                                        style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                      Text(
                                        item.currency?.name ?? '',
                                        style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                      ),
                                    ],
                                  ),
                                ),
                                horizontalSpace(Dimensions.space15),
                              ],
                            ),
                          ),

                          //Rank
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (controller.showBalance) ...[
                                  Text(
                                    "${item.currency?.sign ?? ''}${StringConverter.formatNumber(item.currency?.rate ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                    style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                  horizontalSpace(Dimensions.space5),
                                  Text(
                                    "${item.currency?.sign ?? ''}${StringConverter.formatNumber(item.balance ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                    style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                  ),
                                ] else ...[
                                  Text(
                                    "**********",
                                    style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                  horizontalSpace(Dimensions.space5),
                                  Text(
                                    "**********",
                                    style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
  }
}
