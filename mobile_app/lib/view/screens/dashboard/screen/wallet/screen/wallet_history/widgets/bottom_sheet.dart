
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/controller/wallet/wallet_history_controller.dart';
import 'package:vinance/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';

import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../components/divider/custom_divider.dart';
import '../../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../../components/image/my_local_image_widget.dart';

showTrxBottomSheet(List<String>? list, int callFrom, String header, {required BuildContext context}) {
  if (list != null && list.isNotEmpty) {
    CustomBottomSheetPlus(
        isNeedPadding: false,
        bgColor: MyColor.transparentColor,
        child: Stack(
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
              child: GetBuilder<WalletHistoryController>(builder: (controller) {
                return Column(
                  children: [
                    verticalSpace(Dimensions.space30),
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
                                  text: header.tr,
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
                    //Data list

                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: double.infinity,
                        child: ListView.builder(
                            itemCount: list.length,
                            shrinkWrap: true,
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  String selectedValue = list[index];
                                  final controller = Get.find<WalletHistoryController>();

                                  if (callFrom == 1) {
                                    controller.changeSelectedTrxType(selectedValue);
                                    controller.filterData();
                                  } else if (callFrom == 2) {
                                    controller.changeSelectedRemark(selectedValue);
                                    controller.filterData();
                                  } else if (callFrom == 3) {
                                    controller.changeSelectedCurrency(selectedValue);
                                    controller.filterData();
                                  }

                                  Navigator.pop(context);
                                  FocusScopeNode currentFocus = FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space20),
                                  margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                                    border: Border.all(
                                      color: callFrom == 1
                                          ? controller.selectedTrxType.toLowerCase() == list[index].toLowerCase()
                                              ? MyColor.getPrimaryColor()
                                              : MyColor.getBorderColor()
                                          : callFrom == 2
                                              ? controller.selectedRemark.toLowerCase() == list[index].toLowerCase()
                                                  ? MyColor.getPrimaryColor()
                                                  : MyColor.getBorderColor()
                                              : callFrom == 3
                                                  ? controller.selectedCurrency.toLowerCase() == list[index].toLowerCase()
                                                      ? MyColor.getPrimaryColor()
                                                      : MyColor.getBorderColor()
                                                  : MyColor.getBorderColor(),
                                    ),
                                  ),
                                  child: Text(
                                    ' ${callFrom == 3 ? list[index].tr : callFrom == 2 ? StringConverter.replaceUnderscoreWithSpace(list[index].capitalizeFirst ?? '').tr : list[index].tr}',
                                    style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                    // Expanded(
                  ],
                );
              }),
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
        )).show(context);
  }
}
