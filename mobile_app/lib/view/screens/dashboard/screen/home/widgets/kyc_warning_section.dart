import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../core/route/route.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/home/home_controller.dart';

class KYCWarningSection extends StatelessWidget {
  final HomeController controller;
  const KYCWarningSection({
    super.key,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return controller.isKycVerified == "1" || controller.isLoading
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsetsDirectional.only(top: Dimensions.space15, bottom: Dimensions.space10),
            margin: const EdgeInsets.only(
              left: Dimensions.space15,
              right: Dimensions.space15,
            ),
            child: InkWell(
              onTap: () {
                Get.toNamed(RouteHelper.kycScreen);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space10,
                  vertical: Dimensions.space8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                  color: MyColor.redCancelTextColor.withOpacity(.1),
                  border: Border.all(color: MyColor.redCancelTextColor, width: .5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isKycVerified == '2') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MyStrings.kycVerificationPending.tr,
                            style: boldLarge.copyWith(color: MyColor.colorRed),
                          ),
                          verticalSpace(Dimensions.space10),
                          Text(
                            MyStrings.kycVerificationPendingMSg.tr,
                            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                        ],
                      ),
                    ] else ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MyStrings.kycVerificationRequired.tr,
                            style: boldLarge.copyWith(color: MyColor.colorRed),
                          ),
                          verticalSpace(Dimensions.space10),
                          Text(
                            MyStrings.kycVerificationMsg.tr,
                            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
  }
}
