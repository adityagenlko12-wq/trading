import 'package:flutter/material.dart';
import 'package:vinance/data/controller/home/home_controller.dart';

import '../../../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/model/market/market_over_view_model.dart';
import '../../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../../components/image/my_local_image_widget.dart';
import '../../../../../../../components/image/my_network_image_widget.dart';

class TopExchangeHorizontalListWidget extends StatelessWidget {
  final TopExchangesCoin item;
  final HomeController controller;

  const TopExchangeHorizontalListWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
      padding: const EdgeInsets.all(Dimensions.space10),
      margin: const EdgeInsetsDirectional.only(end: Dimensions.space10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //Worth
          Container(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyNetworkImageWidget(
                  imageUrl: item.coin?.imageUrl ?? '',
                  width: Dimensions.space50,
                  height: Dimensions.space50,
                  radius: Dimensions.cardRadius2,
                ),
                horizontalSpace(Dimensions.space20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.coin?.symbol ?? '',
                      style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    ),
                    Text(
                      StringConverter.formatNumber(item.coin?.marketData?.price ?? "0.0", precision: controller.homeRepo.apiClient.getDecimalAfterNumber()),
                      style: regularSmall.copyWith(
                          color: item.coin?.marketData?.htmlClasses?.priceChange.toString() == '0'
                              ? MyColor.getPrimaryTextColor()
                              : item.coin?.marketData?.htmlClasses?.priceChange.toString() == 'up'
                                  ? MyColor.colorGreen
                                  : MyColor.colorRed),
                    ),
                  ],
                ),
                horizontalSpace(Dimensions.space15),
              ],
            ),
          ),
          verticalSpace(Dimensions.space15),
          //Rank
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyLocalImageWidget(
                imagePath: item.coin?.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyIcons.arrowUp : MyIcons.arrowDown,
                height: Dimensions.space15,
                width: Dimensions.space15,
                imageOverlayColor: item.coin?.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed,
              ),
              horizontalSpace(Dimensions.space5),
              Text(
                "${StringConverter.formatNumber("${item.coin?.marketData?.percentChange1H.toString()}", precision: 2)}%",
                style: semiBoldLarge.copyWith(color: item.coin?.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
