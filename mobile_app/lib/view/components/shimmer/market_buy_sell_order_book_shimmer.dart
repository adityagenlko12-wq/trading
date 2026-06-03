import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../core/utils/dimensions.dart';

class MarketBuySellOrderBookShimmerShimmer extends StatelessWidget {
  const MarketBuySellOrderBookShimmerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return ListView(
        shrinkWrap: true,
        children: List.generate(
          8,
          (index) => Container(
            padding: const EdgeInsets.all(Dimensions.space10),
            margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
            child: Row(
              children: [
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
                            verticalSpace(Dimensions.space10),
                            Shimmer.fromColors(
                              baseColor: MyColor.getShimmerBaseColor(),
                              highlightColor: MyColor.getShimmerHighLightColor(),
                              child: Container(
                                width: 100,
                                height: 5,
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
          ),
        ),
      );
    });
  }
}
