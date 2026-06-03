import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../core/utils/my_color.dart';
import 'market_page_market_list_data_shimmer.dart';

class MarketPageShimmer extends StatelessWidget {
  const MarketPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return Column(
        children: [
          verticalSpace(Dimensions.space10),
          SingleChildScrollView(  padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
                  padding: const EdgeInsets.all(Dimensions.space10),
                  margin: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Shimmer.fromColors(
                              baseColor: MyColor.getShimmerBaseColor(),
                              highlightColor: MyColor.getShimmerHighLightColor(),
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: Dimensions.space20,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: MyColor.getShimmerBaseColor(),
                                        highlightColor: MyColor.getShimmerHighLightColor(),
                                        child: Container(
                                          width: double.infinity,
                                          height: 8,
                                          decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      verticalSpace(Dimensions.space10),
                      Container(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Shimmer.fromColors(
                          baseColor: MyColor.getShimmerBaseColor(),
                          highlightColor: MyColor.getShimmerHighLightColor(),
                          child: Container(
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          verticalSpace(Dimensions.space10),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: MarketPageMarketTradeListDataShimmer(length: 10,),
            ),
          ),
        ],
      );
    });
  }
}
