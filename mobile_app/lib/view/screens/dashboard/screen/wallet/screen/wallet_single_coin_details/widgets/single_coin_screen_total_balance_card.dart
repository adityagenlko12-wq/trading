import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/controller/wallet/single_coin_wallet_details_controller.dart';
import '../../../../../../../components/divider/custom_spacer.dart';

class SingleCoinScreenTotalBalanceCard extends StatelessWidget {
  final SingleCoinWalletDetailsController controller;
  const SingleCoinScreenTotalBalanceCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MyStrings.inOrder.tr.toTitleCase(),
                        style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: (controller.showBalance)
                                    ? Text(
                                        "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletDetailsModelData.data?.wallet?.inOrder ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                        style: regularMediumLarge.copyWith(
                                          color: MyColor.getPrimaryTextColor(),
                                        ),
                                      )
                                    : Text(
                                        "**********",
                                        style: regularMediumLarge.copyWith(
                                          color: MyColor.getPrimaryTextColor(),
                                        ),
                                      ))),
                      ),
                    ],
                  ),
                ),
                IntrinsicHeight(
                  child: Container(
                    height: 30,
                    width: 2,
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
                    color: MyColor.getBorderColor(),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          MyStrings.totalBalance.tr.toTitleCase(),
                          style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        verticalSpace(Dimensions.space15),
                        AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: (controller.showBalance)
                                    ? Text(
                                        "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletDetailsModelData.data?.wallet?.totalBalance() ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                        style: regularMediumLarge.copyWith(
                                          color: MyColor.getPrimaryTextColor(),
                                        ),
                                      )
                                    : Text(
                                        "**********",
                                        style: regularMediumLarge.copyWith(
                                          color: MyColor.getPrimaryTextColor(),
                                        ),
                                      ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
