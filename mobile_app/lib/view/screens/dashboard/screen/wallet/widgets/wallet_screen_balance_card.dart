import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/wallet/wallet_controller.dart';
import '../../../../../components/divider/custom_spacer.dart';

class WalletScreenBalanceCard extends StatelessWidget {
  final WalletController controller;
  const WalletScreenBalanceCard({
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        MyStrings.totalBalance.tr.toTitleCase(),
                        style: regularOverLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                      ),
                    ),
                    Row(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: Ink(
                            decoration: ShapeDecoration(
                              color: MyColor.getTabBarTabColor(),
                              shape: const CircleBorder(),
                            ),
                            child: FittedBox(
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  controller.changeShowBalanceState();
                                },
                                icon: Icon(
                                  controller.showBalance == true ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: MyColor.getPrimaryTextColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                      child: Container(
                        padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: controller.showBalance
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Text(
                                    "${controller.walletRepository.apiClient.getCurrencyOrUsername(isSymbol: true)}${StringConverter.formatNumber(controller.walletListModelData.data?.estimatedBalance ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                    style: boldOverLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontOverLarge + 2),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    key: UniqueKey(),
                                    children: List.generate(
                                      8,
                                      (index) => Container(
                                        height: 36,
                                        padding: const EdgeInsetsDirectional.only(
                                          end: Dimensions.space5,
                                        ),
                                        child: Icon(
                                          Icons.circle,
                                          size: Dimensions.fontOverLarge,
                                          color: MyColor.getSecondaryTextColor(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
