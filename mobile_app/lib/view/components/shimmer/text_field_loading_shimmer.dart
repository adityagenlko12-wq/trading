import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../core/utils/dimensions.dart';

class TextFieldLoadingShimmer extends StatelessWidget {
  final int length;
  const TextFieldLoadingShimmer({super.key, this.length = 4});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      return Column(
        children: [
          verticalSpace(Dimensions.space20),
          Column(
            children: List.generate(
              length,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: MyColor.getShimmerBaseColor(),
                    highlightColor: MyColor.getShimmerHighLightColor(),
                    child: Container(
                      width: Dimensions.space100,
                      height: 15,
                      decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(100)),
                    ),
                  ),
                  verticalSpace(Dimensions.space10),
                  Container(
                    decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.space10)),
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
                                        height: Dimensions.space30,
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
                ],
              ),
            ),
          ),
          verticalSpace(Dimensions.space10),
          Shimmer.fromColors(
            baseColor: MyColor.getShimmerBaseColor(),
            highlightColor: MyColor.getShimmerHighLightColor(),
            child: Container(
              width: double.infinity,
              height: Dimensions.space50,
              decoration: BoxDecoration(color: MyColor.getShimmerBaseColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
            ),
          ),
        ],
      );
    });
  }
}
