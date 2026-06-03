import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/controller/deposit/deposit_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_icons.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../components/divider/custom_divider.dart';
import '../../../components/image/my_local_image_widget.dart';

class DepositGateWayBottomSheetWidget extends StatelessWidget {
  final DepositController controller;
  const DepositGateWayBottomSheetWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (controller) {
      return Stack(
        children: [
          //Main code
          Container(
            margin: const EdgeInsetsDirectional.only(top: Dimensions.space20),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgColor(),
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(25),
                topStart: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getPrimaryColor().withOpacity(0.2),
                  offset: const Offset(0, -4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: MyStrings.selectPaymentGateway.tr,
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomDivider(
                  height: 1,
                  space: Dimensions.space5,
                  color: MyColor.getBorderColor(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                    child: controller.filteredDepositMethodList.isNotEmpty
                        ? SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: List.generate(
                                controller.filteredDepositMethodList.length,
                                (index) {
                                  var item = controller.filteredDepositMethodList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      controller.selectDepositPaymentMethod(item);
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space20),
                                      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                                        border: Border.all(
                                          color: controller.selectedDepositPaymentMethod == item ? MyColor.getPrimaryColor() : MyColor.getBorderColor(),
                                        ),
                                      ),
                                      child: Text(
                                        item.name ?? '',
                                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space20),
                            margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                              border: Border.all(
                                color: MyColor.getBorderColor(),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const MyLocalImageWidget(
                                  imagePath: MyIcons.noMoneyIcon,
                                  height: Dimensions.space100,
                                  width: Dimensions.space100,
                                ),
                                verticalSpace(Dimensions.space20),
                                Text(
                                  MyStrings.noPaymentMethod.tr.rKv({"currency": controller.selectedCurrency?.name ?? ''}),
                                  textAlign: TextAlign.center,
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          //bottom sheet closer
          Positioned(
            top: 0,
            left: 20,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(),
              child: Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: MyColor.getTabBarTabBackgroundColor(),
                    shape: const CircleBorder(),
                  ),
                  child: FittedBox(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Get.back();
                      },
                      icon: MyLocalImageWidget(
                        imagePath: MyIcons.doubleArrowDown,
                        imageOverlayColor: MyColor.getPrimaryTextColor(),
                        width: Dimensions.space25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
