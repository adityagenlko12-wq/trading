import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';

import '../../../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../../../data/model/market/market_data_list_model.dart';
import '../../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../../components/image/my_local_image_widget.dart';
import '../../../../../../../components/image/my_network_image_widget.dart';

class HomeMarketPairCoinCardWidget extends StatelessWidget {
final MarketPairSingleData  item;
  final HomeController controller;

  const HomeMarketPairCoinCardWidget({
    super.key,
    required this.item,
    required this.controller,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.tradeViewDetailsScreen, arguments: item.symbol, preventDuplicates: true);
      },
      child: Container(
        decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
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
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: Dimensions.space25),
                        child: Container(
                          decoration: BoxDecoration(color: MyColor.getScreenBgColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                          child: MyNetworkImageWidget(
                            imageUrl: item.market?.currency?.imageUrl ?? '',
                            width: Dimensions.space40,
                            height: Dimensions.space40,
                            radius: Dimensions.radiusMax,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: MyColor.getScreenBgColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                        child: MyNetworkImageWidget(
                          imageUrl: item.coin?.imageUrl ?? '',
                          width: Dimensions.space40,
                          height: Dimensions.space40,
                          radius: Dimensions.radiusMax,
                        ),
                      ),
                    ],
                  ),
                  horizontalSpace(Dimensions.space10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${item.coin?.symbol ?? ''}/${item.market?.currency?.symbol ?? ''}",
                        style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      Text(
                        item.market?.currency?.name ?? '',
                        style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                    ],
                  ),
                  horizontalSpace(Dimensions.space15),
                ],
              ),
            ),

            //Rank
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  StringConverter.formatNumber(item.marketData?.price ?? '', precision: controller.homeRepo.apiClient.getDecimalAfterNumber()),
                  style: regularLarge.copyWith(
                      color: item.marketData?.htmlClasses?.priceChange.toString() == '0'
                          ? MyColor.getPrimaryTextColor()
                          : item.marketData?.htmlClasses?.priceChange.toString() == 'up'
                              ? MyColor.colorGreen
                              : MyColor.colorRed),
                ),
                verticalSpace(Dimensions.space10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyLocalImageWidget(
                      imagePath: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyIcons.arrowUp : MyIcons.arrowDown,
                      height: Dimensions.space12,
                      width: Dimensions.space12,
                      imageOverlayColor: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed,
                    ),
                    horizontalSpace(Dimensions.space5),
                    Text(
                      "${StringConverter.formatNumber("${item.marketData?.percentChange1H.toString()}", precision: 2)}%",
                      style: regularDefault.copyWith(color: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}