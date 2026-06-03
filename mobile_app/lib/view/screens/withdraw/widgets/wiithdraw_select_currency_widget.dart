import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/withdraw/withdraw_controller.dart';
import '../../../components/divider/custom_spacer.dart';
import 'withdraw_search_currency_from_list_widget.dart';

class WithdrawSearchCurrencyWidget extends StatelessWidget {
  final WithdrawController controller;
  final String selectedCurrencyFromParamsID;
  final String walletType;
  const WithdrawSearchCurrencyWidget({super.key, required this.controller, required this.selectedCurrencyFromParamsID, required this.walletType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getScreenBgSecondaryColor(),
        border: Border.all(color: MyColor.getPrimaryColor()),
        borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
      ),
      child: Stack(
        children: [
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
                        MyStrings.walletBalance.tr.toTitleCase(),
                        style: regularOverLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: MyColor.getTabBarTabColor(),
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: Dimensions.space5,
                              )),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (selectedCurrencyFromParamsID == '' || selectedCurrencyFromParamsID.toString() == '-1') {
                              Get.to(WithdrawSearchCurrencyFromListWidget(
                                controller: controller,
                              ));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space12, vertical: Dimensions.space7),
                            decoration: BoxDecoration(
                              // color: MyColor.getTabBarTabColor(),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radiusMax,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyNetworkImageWidget(
                                  imageUrl: controller.selectedWithdrawCurrency?.imageUrl ?? '',
                                  height: Dimensions.space20,
                                  width: Dimensions.space20,
                                ),
                                horizontalSpace(Dimensions.space10),
                                Text(
                                  controller.selectedWithdrawCurrency?.symbol ?? '',
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                if (selectedCurrencyFromParamsID == '' || selectedCurrencyFromParamsID.toString() == '-1') ...[
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: MyColor.getPrimaryTextColor(),
                                    size: Dimensions.space20,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                verticalSpace(Dimensions.space35),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: StringConverter.formatNumber(controller.getCurrentWalletAmount(walletType: walletType), precision: controller.withdrawRepo.apiClient.getDecimalAfterNumber()),
                                    style: boldOverLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontOverLarge + 5),
                                  ),
                                  TextSpan(
                                    text: "  ${controller.selectedWithdrawCurrency?.symbol ?? ""}",
                                    style: regularMediumLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(Dimensions.space10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
