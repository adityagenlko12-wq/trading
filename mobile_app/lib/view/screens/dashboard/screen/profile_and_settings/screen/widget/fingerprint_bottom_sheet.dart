import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';

import '../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../data/controller/auth/biometric/biometric_controller.dart';
import '../../../../../../components/divider/custom_divider.dart';
import '../../../../../../components/image/my_local_image_widget.dart';
import '../../../../../../components/text-form-field/custom_text_field.dart';

class FingerPrintBottomSheet extends StatelessWidget {
  const FingerPrintBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BioMetricController>(builder: (controller) {
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
                              text: MyStrings.setupYourFingerPrint.tr,
                              style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20),
                  child: Column(
                    children: [
                      const SizedBox(height: Dimensions.space15),
                      Text(MyStrings.fingerPrintSubtitleMsg.tr, style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor())),
                      const SizedBox(height: Dimensions.space15),
                      CustomTextField(
                        animatedLabel: false,
                        needOutlineBorder: true,
                        labelText: MyStrings.password.tr,
                        hintText: MyStrings.enterYourPassword_.tr,
                        controller: controller.passwordController,
                        onChanged: (value) {},
                        isShowSuffixIcon: true,
                        isPassword: true,
                        textInputType: TextInputType.text,
                        inputAction: TextInputAction.done,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return MyStrings.fieldErrorMsg.tr;
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: Dimensions.space15),
                      RoundedButton(
                        isLoading: controller.isBioLoading,
                        text: MyStrings.enableFingerPrint,
                        press: () {
                          if (controller.passwordController.text.isNotEmpty && controller.isDisable == false) {
                            controller.enableFingerPrint();
                          }
                        },
                      ),
                      const SizedBox(height: Dimensions.space30),
                    ],
                  ),
                )
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
