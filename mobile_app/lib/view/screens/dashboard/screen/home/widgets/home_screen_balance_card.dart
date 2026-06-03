import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/controller/home/home_controller.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class HomeScreenBalanceCard extends StatelessWidget {
  final HomeController controller;
  const HomeScreenBalanceCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [MyColor.primaryColor500, MyColor.primaryColor700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
          transform: GradientRotation(99 * 3.1415926535 / 180), // Convert degrees to radians
        ),
        borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
      ),
      child: Stack(
        children: [
          //BG Foot Prints
          const Positioned(
              top: 0,
              right: 0,
              child: Opacity(
                opacity: 0.5,
                child: MyLocalImageWidget(
                  imagePath: MyIcons.balanceCardShape1,
                  boxFit: BoxFit.contain,
                ),
              )),
          const Positioned(
              bottom: 10,
              right: 0,
              child: Opacity(
                opacity: 0.8,
                child: MyLocalImageWidget(
                  imagePath: MyIcons.balanceCardShape2,
                  boxFit: BoxFit.contain,
                ),
              )),
          const Positioned(
              top: 0,
              left: 15,
              child: Opacity(
                opacity: 1,
                child: MyLocalImageWidget(
                  imagePath: MyIcons.balanceCardShape3,
                  height: Dimensions.space20,
                  boxFit: BoxFit.contain,
                ),
              )),
          const Positioned(
              bottom: 0,
              left: 0,
              child: Opacity(
                opacity: 1,
                child: MyLocalImageWidget(
                  imagePath: MyIcons.balanceCardShape4,
                  boxFit: BoxFit.contain,
                ),
              )),
          //BG Foot Prints    END

          //Balance Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        MyStrings.accountBalance.tr.toTitleCase(),
                        style: regularOverLarge.copyWith(color: MyColor.secondaryColor50),
                      ),
                    ),
                    Row(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: Ink(
                            decoration: const ShapeDecoration(
                              color: MyColor.primaryColor500,
                              shape: CircleBorder(),
                            ),
                            child: FittedBox(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  controller.changeShowBalanceState();
                                },
                                icon: Icon(
                                  controller.showBalance == true ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: MyColor.colorWhite,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                verticalSpace(Dimensions.space35),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      MyStrings.estimatedAssetValue.tr,
                      style: regularDefault.copyWith(color: MyColor.secondaryColor300),
                    ),
                    verticalSpace(Dimensions.space3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: controller.showBalance
                          ? Text(
                              "${controller.defaultCurrencySymbol}${StringConverter.formatNumber("${controller.estimatedBalance ?? 0.0}", precision: controller.homeRepo.apiClient.getDecimalAfterNumber())}",
                              style: boldOverLarge.copyWith(color: MyColor.secondaryColor50, fontSize: Dimensions.fontOverLarge + 5),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                key: UniqueKey(),
                                children: List.generate(
                                  8,
                                  (index) => Container(
                                    height: 42,
                                    padding: const EdgeInsetsDirectional.only(
                                      end: Dimensions.space5,
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      size: Dimensions.fontOverLarge,
                                      color: MyColor.secondaryColor300,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
