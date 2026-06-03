import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/controller/wallet/single_coin_wallet_details_controller.dart';
import '../../../../../../../components/divider/custom_spacer.dart';

class SingleCoinAllWidgetCard extends StatelessWidget {
  final SingleCoinWalletDetailsController controller;
  const SingleCoinAllWidgetCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: controller.showMoreWidget == true ? null : 250,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
              decoration: BoxDecoration(
                color: MyColor.getScreenBgSecondaryColor(),
                // border: Border.all(color: MyColor.getPrimaryColor()),
                // borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
              ),
              child: Column(
                children: [
                  //Deposit and withdraw
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
                                MyStrings.totalDeposit.tr.toTitleCase(),
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
                                                "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletWidgetCounter?.totalDeposit ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
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
                                  MyStrings.totalWithdraw.tr.toTitleCase(),
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
                                                "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletWidgetCounter?.totalWithdraw ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
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
                  //Total transaction and trade
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
                                MyStrings.totalTransaction.tr.toTitleCase(),
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
                                                "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletWidgetCounter?.totalTransaction ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
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
                                  MyStrings.totalTrades.tr.toTitleCase(),
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
                                                "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(controller.singleWalletWidgetCounter?.totalTrade ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
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
                  //Compete order and Open Order
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
                                MyStrings.openOrder.tr.toTitleCase(),
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
                                                controller.singleWalletWidgetCounter?.openOrder ?? '0',
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
                                  MyStrings.completedOrder.tr.toTitleCase(),
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
                                                controller.singleWalletWidgetCounter?.completedOrder ?? '0',
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
                  //Cancel order and total order
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
                                MyStrings.canceledOrder.tr.toTitleCase(),
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
                                                controller.singleWalletWidgetCounter?.canceledOrder ?? '0',
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
                                  MyStrings.totalOrder.tr.toTitleCase(),
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
                                                controller.singleWalletWidgetCounter?.totalOrder ?? '0',
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
    
                  //Space
                  verticalSpace(Dimensions.space50)
                ],
              ),
            ),
          ),
        ),
        //hide show more
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            margin: EdgeInsetsDirectional.symmetric(
              horizontal: Dimensions.space15,
              vertical: controller.showMoreWidget ? 10 : 0,
            ),
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  MyColor.getShadowColor().withOpacity(0.1),
                ],
                stops: const [0.0, 1.0],
              ),
              border: Border(
                bottom: BorderSide(color: MyColor.getPrimaryColor()),
              ),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.cardRadius2), bottomRight: Radius.circular(Dimensions.cardRadius2)),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                  onPressed: () {
                    controller.changeShowMoreWidgetState();
                  },
                  icon: !controller.showMoreWidget
                      ? Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: MyColor.getPrimaryTextColor(),
                          size: Dimensions.space30,
                        )
                      : Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: MyColor.getPrimaryTextColor(),
                          size: Dimensions.space30,
                        )),
            ),
          ),
        )
      ],
    );
  }
}
