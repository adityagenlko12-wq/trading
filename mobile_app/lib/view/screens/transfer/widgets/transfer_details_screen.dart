import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/my_images.dart';
import 'package:vinance/view/components/divider/custom_divider.dart';

import '../../../../core/helper/date_converter.dart';
import '../../../../core/route/route.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_icons.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/model/transfer/transfer_response_model.dart';
import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/image/my_local_image_widget.dart';
import '../../../components/row_widget/custom_row_without_border.dart';

class TransferDetailsScreen extends StatefulWidget {
  final TransferResponseModel? transferResponseModel;
  const TransferDetailsScreen({super.key, this.transferResponseModel});

  @override
  State<TransferDetailsScreen> createState() => _TransferDetailsScreenState();
}

class _TransferDetailsScreenState extends State<TransferDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: MyStrings.transferDetails.tr,
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
                    Get.toNamed(RouteHelper.walletHistoryScreen, arguments: 'transfer');
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
              MyStrings.transferSuccessful.tr,
              style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
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
                    lastText: widget.transferResponseModel?.data?.amount ?? '',
                  ),
                  verticalSpace(Dimensions.space10),
                  if (widget.transferResponseModel?.data?.chargeAmount.toString() != 'null') ...[
                    CustomRowWithoutOrder(
                      firstText: MyStrings.charge.tr,
                      lastText: widget.transferResponseModel?.data?.chargeAmount ?? '',
                    ),
                    verticalSpace(Dimensions.space10),
                  ],
                  CustomRowWithoutOrder(
                    firstText: MyStrings.postBalance.tr,
                    lastText: widget.transferResponseModel?.data?.transaction?.postBalance ?? '',
                  ),
                  verticalSpace(Dimensions.space10),
                  CustomRowWithoutOrder(
                    firstText: MyStrings.trxId.tr,
                    isCopyable: true,
                    lastText: widget.transferResponseModel?.data?.transaction?.trx ?? '',
                  ),
                  verticalSpace(Dimensions.space10),
                  CustomRowWithoutOrder(
                    firstText: MyStrings.to.tr,
                    lastText: widget.transferResponseModel?.data?.toWallet?.walletType == '1' ? MyStrings.spotWallet : MyStrings.fundingWallet,
                  ),
                  verticalSpace(Dimensions.space10),
                  CustomRowWithoutOrder(
                    firstText: MyStrings.date.tr,
                    lastText: DateConverter.isoToLocalDateAndTime(widget.transferResponseModel?.data?.transaction?.createdAt ?? ''),
                  ),
                  verticalSpace(Dimensions.space25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info,
                        size: Dimensions.space20,
                        color: MyColor.getPrimaryTextColor(),
                      ),
                      horizontalSpace(Dimensions.space10),
                      Expanded(
                        child: Text(
                          (widget.transferResponseModel?.data?.transaction?.details ?? '').toCapitalized(),
                          style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                        ),
                      ),
                    ],
                  ),
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
  }
}
