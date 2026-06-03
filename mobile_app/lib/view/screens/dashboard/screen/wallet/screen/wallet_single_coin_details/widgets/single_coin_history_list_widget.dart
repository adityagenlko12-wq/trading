import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/date_converter.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/view/components/image/my_local_image_widget.dart';

import '../../../../../../../../core/helper/string_format_helper.dart';
import '../../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../../core/utils/my_color.dart';
import '../../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../../core/utils/style.dart';
import '../../../../../../../../data/controller/wallet/single_coin_wallet_details_controller.dart';
import '../../../../../../../../data/model/wallet/single_wallet_details.dart';
import '../../../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../../components/no_data.dart';

class SingleCoinHistoryListWidget extends StatelessWidget {
  final SingleCoinWalletDetailsController controller;
  final ScrollController scrollController;
  const SingleCoinHistoryListWidget({super.key, required this.controller, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(Dimensions.space10),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Dimensions.space15,
            vertical: Dimensions.space15,
          ),
          child: Text(
            MyStrings.transactionHistory.tr,
            style: semiBoldMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
          ),
        ),
        verticalSpace(Dimensions.space10),
        if (controller.transactionData.isEmpty) ...[
          Center(
            child: FittedBox(
              child: NoDataWidget(
                text: MyStrings.noDataToShow.tr,
              ),
            ),
          )
        ] else ...[
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
              itemCount: controller.transactionData.length + 1,
              itemBuilder: (context, index) {
                if (controller.transactionData.length == index) {
                  return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                }
                TransactionSingleData item = controller.transactionData[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
                  ),
                  padding: const EdgeInsets.all(Dimensions.space10),
                  margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsetsDirectional.only(end: Dimensions.space15),
                        height: Dimensions.space40,
                        width: Dimensions.space40,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMax), color: item.remark.toString() == 'withdraw' || item.remark.toString() == 'transfer' ? MyColor.colorRed.withOpacity(0.1) : MyColor.colorGreen.withOpacity(0.1)),
                        child: Center(
                          child: MyLocalImageWidget(
                            imagePath: item.remark.toString() == 'withdraw'
                                ? MyIcons.withdrawAction
                                : item.remark.toString() == 'transfer'
                                    ? MyIcons.sendAction
                                    : MyIcons.depositAction,
                            imageOverlayColor: item.remark.toString() == 'withdraw' || item.remark.toString() == 'transfer' ? MyColor.colorRed : MyColor.colorGreen,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item.wallet?.currency?.name}",
                                  style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: DateConverter.isoToLocalDateAndTime(item.wallet?.currency?.createdAt ?? ''),
                                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpace(Dimensions.space10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  MyStrings.trx.tr,
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${item.trx}",
                                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  MyStrings.amount.tr,
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${item.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                          style: regularLarge.copyWith(color: item.trxType == '+' ? MyColor.colorGreen : MyColor.colorRed),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  MyStrings.postBalance.tr,
                                  style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "${item.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(item.postBalance ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                          style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpace(Dimensions.space15),
                            Text(
                              "${item.details}",
                              style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor().withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ]
      ],
    );
  }
}
