import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../core/utils/dimensions.dart';

class AccountInfoCardLoaderShimmer extends StatelessWidget {
  const AccountInfoCardLoaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return Row(
        children: [
          SizedBox(
            height: Dimensions.space50 + 35,
            width: Dimensions.space50 + 35,
            child: Shimmer.fromColors(
              baseColor: MyColor.getShimmerBaseColor(),
              highlightColor: MyColor.getShimmerHighLightColor(),
              child: Container(
                height: Dimensions.space50 + 35,
                width: Dimensions.space50 + 35,
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
                          height: 15,
                          decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      verticalSpace(Dimensions.space10),
                      Shimmer.fromColors(
                        baseColor: MyColor.getShimmerBaseColor(),
                        highlightColor: MyColor.getShimmerHighLightColor(),
                        child: Container(
                          width: 100,
                          height: 15,
                          decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      verticalSpace(Dimensions.space10),
                      Shimmer.fromColors(
                        baseColor: MyColor.getShimmerBaseColor(),
                        highlightColor: MyColor.getShimmerHighLightColor(),
                        child: Container(
                          width: 50,
                          height: 15,
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
      );
    });
  }
}
