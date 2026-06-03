import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';

class AppDialog {
  void warningAlertDialog(BuildContext context, VoidCallback press, {String? msgText}) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: MyColor.getScreenBgSecondaryColor(),
              insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.space40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: Dimensions.space40, bottom: Dimensions.space15, left: Dimensions.space15, right: Dimensions.space15),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        children: [
                          const SizedBox(height: Dimensions.space20),
                          Text(msgText ?? MyStrings.agreeDialogTitle.tr, style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                          const SizedBox(height: Dimensions.space20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();

                                    press();
                                  },
                                  child: Container(
                                    height: Dimensions.space40,
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space30, vertical: Dimensions.space5),
                                    decoration: BoxDecoration(color: MyColor.greenSuccessColor, borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                                    child: Center(
                                      child: Text(
                                        MyStrings.yes.tr,
                                        style: regularDefault.copyWith(color: MyColor.colorWhite),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              horizontalSpace(Dimensions.space10),
                              Expanded(
                                  child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  height: Dimensions.space40,
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space30, vertical: Dimensions.space5),
                                  decoration: BoxDecoration(color: MyColor.colorRed, borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                                  child: Center(
                                    child: Text(
                                      MyStrings.no.tr,
                                      style: regularDefault.copyWith(color: MyColor.colorWhite),
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                          verticalSpace(Dimensions.space10),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -40,
                      left: MediaQuery.of(context).padding.left,
                      right: MediaQuery.of(context).padding.right,
                      child: Image.asset(
                        MyImages.warningImage,
                        height: 80,
                        width: 80,
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
