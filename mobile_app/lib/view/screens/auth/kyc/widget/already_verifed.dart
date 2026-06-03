import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';

import '../../../../../core/utils/url_container.dart';
import '../../../../../data/controller/kyc_controller/kyc_controller.dart';
import '../../../../components/card/app_body_card.dart';
import '../../../../components/dialog/download_dialog.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../../components/image/custom_svg_picture.dart';
import '../../../profile/widget/card_column.dart';

class AlreadyVerifiedWidget extends StatefulWidget {
  final bool isPending;
  const AlreadyVerifiedWidget({super.key, this.isPending = false});

  @override
  State<AlreadyVerifiedWidget> createState() => _AlreadyVerifiedWidgetState();
}

class _AlreadyVerifiedWidgetState extends State<AlreadyVerifiedWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(builder: (controller) {
      return Container(
        padding: const EdgeInsets.all(Dimensions.space20),
        margin: const EdgeInsets.all(5),
        child: controller.pendingData.isNotEmpty
            ? AppBodyWidgetCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.pendingData.length,
                        itemBuilder: (context, index) {
                          return controller.pendingData[index].type == "file"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.pendingData[index].name ?? '',
                                      style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                    ),
                                    const SizedBox(height: Dimensions.space10),
                                    GestureDetector(
                                      onTap: () {
                                        String url = "${UrlContainer.domainUrl}/${controller.path}/${controller.pendingData[index].value.toString()}";
                                        printx(url);
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return DownloadingDialog(
                                              url: url,
                                              fileName: MyStrings.kyc,
                                              isImage: false,
                                            );
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
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    ProfileCardColumn(
                                      header: controller.pendingData[index].name ?? '',
                                      body: StringConverter.removeQuotationAndSpecialCharacterFromString(controller.pendingData[index].value ?? ''),
                                      headerTextDecoration: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                                    ),
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomSvgPicture(
                    image: widget.isPending ? MyIcons.pendingIcon : MyIcons.verifiedIcon,
                    height: 100,
                    width: 100,
                    color: MyColor.getPrimaryColor(),
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(widget.isPending ? MyStrings.kycUnderReviewMsg.tr : MyStrings.kycAlreadyVerifiedMsg.tr,
                      style: regularDefault.copyWith(
                        color: MyColor.getPrimaryTextColor(),
                        fontSize: Dimensions.fontExtraLarge,
                      )),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: RoundedButton(
                      press: () {
                        if (Get.context == null) {
                          Get.back();
                        } else {
                          Get.back();
                        }
                        Get.back();
                      },
                      text: MyStrings.home.tr,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
