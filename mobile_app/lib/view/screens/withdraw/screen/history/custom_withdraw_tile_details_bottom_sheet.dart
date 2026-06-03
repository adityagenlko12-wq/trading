import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/model/withdraw/withdraw_history_response_model.dart';

import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/url_container.dart';
import '../../../../../data/controller/withdraw/withdraw_history_controller.dart';
import '../../../../components/column_widget/card_column.dart';
import '../../../../components/dialog/download_dialog.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';

class CustomWithdrawTileDetailsBottomSheet extends StatelessWidget {
  final WithdrawListModel item;
  const CustomWithdrawTileDetailsBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
          child: GetBuilder<WithdrawHistoryController>(builder: (controller) {
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
                              text: MyStrings.withdrawDetails,
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

                Column(
                  children: List.generate(item.withdrawInformation?.length ?? 0, (index) {
                    var infoItem = item.withdrawInformation?[index] ?? WithdrawInformationData();
                    return Container(
                      padding: const EdgeInsets.all(Dimensions.space8),
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space10),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColor.getBorderColor(), width: .5),
                        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                      ),
                      child: infoItem.type == "file"
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(infoItem.name ?? '', style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontDefault)),
                                const SizedBox(height: Dimensions.space5),
                                GestureDetector(
                                  onTap: () {
                                    String url = "${UrlContainer.domainUrl}/${controller.imagePath}/${infoItem.value.toString()}";

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DownloadingDialog(isImage: false, url: url, fileName: "Withdraw");
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.file_download,
                                        size: 17,
                                        color: MyColor.primaryColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        MyStrings.attachment.tr,
                                        style: regularDefault.copyWith(color: MyColor.primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: CardColumn(
                                space: Dimensions.space10,
                                header: infoItem.name ?? '',
                                body: StringConverter.removeQuotationAndSpecialCharacterFromString(infoItem.value ?? ''),
                                headerTextStyle: regularLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontDefault),
                                bodyTextStyle: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                bodyMaxLine: 3,
                              ),
                            ),
                    );
                  }),
                ),
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
    );
  }
}
