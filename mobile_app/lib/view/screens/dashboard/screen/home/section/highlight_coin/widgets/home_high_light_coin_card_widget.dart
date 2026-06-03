import 'package:flutter/material.dart';

import '../../../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/controller/home/home_controller.dart';
import '../../../../../../../../data/model/market/market_over_view_model.dart';
import '../../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../../components/image/my_local_image_widget.dart';
import '../../../../../../../components/image/my_network_image_widget.dart';

class HomeHighLightCoinCardWidget extends StatelessWidget {
  final OverViewCoinModel item;
  final HomeController controller;

  const HomeHighLightCoinCardWidget({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
      padding: const EdgeInsets.all(Dimensions.space10),
      margin: const EdgeInsetsDirectional.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Worth
          Container(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyNetworkImageWidget(
                  imageUrl: item.imageUrl ?? '',
                  width: Dimensions.space50,
                  height: Dimensions.space50,
                  radius: Dimensions.cardRadius2,
                ),
                horizontalSpace(Dimensions.space10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.symbol ?? '',
                        style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      FittedBox(
                        child: Text(
                          StringConverter.formatNumber(item.marketData?.price ?? "0.0", precision: controller.homeRepo.apiClient.getDecimalAfterNumber()),
                          style: regularSmall.copyWith(
                              color: item.marketData?.htmlClasses?.priceChange.toString() == '0'
                                  ? MyColor.getPrimaryTextColor()
                                  : item.marketData?.htmlClasses?.priceChange.toString() == 'up'
                                      ? MyColor.colorGreen
                                      : MyColor.colorRed),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
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
                imagePath: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyIcons.arrowUp : MyIcons.arrowDown,
                height: Dimensions.space15,
                width: Dimensions.space15,
                imageOverlayColor: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed,
              ),
              horizontalSpace(Dimensions.space5),
              Text(
                "${StringConverter.formatNumber("${item.marketData?.percentChange1H.toString()}", precision: 2)}%",
                style: semiBoldLarge.copyWith(color: item.marketData?.htmlClasses?.percentChange1H.toString() == 'up' ? MyColor.colorGreen : MyColor.colorRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
