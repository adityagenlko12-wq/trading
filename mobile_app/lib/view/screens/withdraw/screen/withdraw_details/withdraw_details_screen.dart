import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vinance/core/utils/my_images.dart';
import 'package:vinance/data/controller/dashbaord/dashboard_controller.dart';
import 'package:vinance/view/components/divider/custom_divider.dart';

import '../../../../../core/helper/date_converter.dart';
import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/route/route.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/model/withdraw/withdraw_confirmation_response_model.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/buttons/rounded_button.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import '../../../../components/row_widget/custom_row_without_border.dart';

class WithdrawDetailsScreen extends StatefulWidget {
  final WithdrawConfirmationData? withdrawConfirmationData;
  const WithdrawDetailsScreen({super.key, this.withdrawConfirmationData});

  @override
  State<WithdrawDetailsScreen> createState() => _WithdrawDetailsScreenState();
}

class _WithdrawDetailsScreenState extends State<WithdrawDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.withdrawDetails.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
              child: Ink(
                decoration: ShapeDecoration(
                  color: MyColor.getAppBarBackgroundColor(),
                  shape: const CircleBorder(),
                ),
                child: FittedBox(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.toNamed(
                        RouteHelper.withdrawHistoryScreen,
                      );
                    },
                    icon: MyLocalImageWidget(
                      imagePath: MyIcons.historyIcon,
                      imageOverlayColor: MyColor.getAppBarContentColor(),
                      width: Dimensions.space25,
                    ),
                  ),
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              verticalSpace(Dimensions.space20),
              Center(
                child: LottieBuilder.asset(
                  MyImages.doneAnimationImage,
                  repeat: false,
                  width: Dimensions.space100,
                  height: Dimensions.space100,
                ),
              ),
              verticalSpace(Dimensions.space10),
              Text(
                MyStrings.withdrawRequestSentSuccessful.tr,
                style: boldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
              ),
              verticalSpace(Dimensions.space10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20),
                child: Column(
                  children: [
                    CustomDivider(
                      space: Dimensions.space10,
                      color: MyColor.getBorderColor(),
                    ),
                    verticalSpace(Dimensions.space25),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.amount.tr,
                      lastText: "${StringConverter.formatNumber(widget.withdrawConfirmationData?.amount ?? '0.0', precision: controller.apiClient.getDecimalAfterNumber())} ${widget.withdrawConfirmationData?.currency}",
                    ),
                    verticalSpace(Dimensions.space10),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.charge.tr,
                      lastText: "${StringConverter.formatNumber(widget.withdrawConfirmationData?.charge ?? '0.0', precision: controller.apiClient.getDecimalAfterNumber())} ${widget.withdrawConfirmationData?.currency}",
                    ),
                    verticalSpace(Dimensions.space10),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.afterCharge.tr,
                      lastText: "${StringConverter.formatNumber(widget.withdrawConfirmationData?.afterCharge ?? '0.0', precision: controller.apiClient.getDecimalAfterNumber())} ${widget.withdrawConfirmationData?.currency}",
                    ),
                    verticalSpace(Dimensions.space10),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.finalAmount.tr,
                      lastText: "${StringConverter.formatNumber(widget.withdrawConfirmationData?.finalAmount ?? '0.0', precision: controller.apiClient.getDecimalAfterNumber())} ${widget.withdrawConfirmationData?.currency}",
                    ),
                    verticalSpace(Dimensions.space10),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.trxId.tr,
                      isCopyable: true,
                      lastText: widget.withdrawConfirmationData?.trx ?? '',
                    ),
                    verticalSpace(Dimensions.space10),
                    CustomRowWithoutOrder(
                      firstText: MyStrings.via.tr,
                      lastText: widget.withdrawConfirmationData?.method?.name ?? '',
                    ),
                    verticalSpace(Dimensions.space10),
                    if (widget.withdrawConfirmationData?.status == '2') ...[
                      CustomRowWithoutOrder(
                        firstText: MyStrings.status.tr,
                        lastText: MyStrings.pending,
                        isStatus: true,
                      ),
                      verticalSpace(Dimensions.space10),
                    ],
                    CustomRowWithoutOrder(
                      firstText: MyStrings.date.tr,
                      lastText: DateConverter.isoToLocalDateAndTime(widget.withdrawConfirmationData?.createdAt ?? ''),
                    ),
                    verticalSpace(Dimensions.space25),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColor.getScreenBgColor(),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.getPrimaryColor().withOpacity(0.2),
                    offset: const Offset(0, -4),
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: RoundedButton(
                  color: MyColor.getPrimaryColor(),
                  text: MyStrings.home.tr,
                  press: () {
                    Get.toNamed(RouteHelper.dashboardScreen);
                  })),
        ),
      );
    });
  }
}
