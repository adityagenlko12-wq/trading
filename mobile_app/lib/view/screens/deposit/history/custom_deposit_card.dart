import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/date_converter.dart';
import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../data/controller/deposit/deposit_history_controller.dart';
import '../../../../data/model/deposit/deposit_history_response_model.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/image/my_local_image_widget.dart';
import '../../../components/row_widget/status_widget.dart';

class CustomDepositCard extends StatelessWidget {
  final DepositHistoryListModel item;
  final DepositHistoryController depositHistoryController;
  final int index;
  final VoidCallback onPressed;

  const CustomDepositCard({
    super.key,
    required this.item,
    required this.index,
    required this.onPressed,
    required this.depositHistoryController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMax), color: MyColor.colorRed.withOpacity(0.1)),
                child: const Center(
                  child: MyLocalImageWidget(
                    imagePath: MyIcons.withdrawAction,
                    imageOverlayColor: MyColor.colorRed,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                          child: Text(
                            "${item.wallet?.walletType == '1' ? MyStrings.spot.tr : item.wallet?.walletType == '2' ? MyStrings.funding.tr : ''} | ${item.methodCurrency}",
                            style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                        ),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: DateConverter.isoToLocalDateAndTime(item.createdAt ?? ''),
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
                          MyStrings.gateway.tr,
                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "${item.gateway?.name}",
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
                                  text: StringConverter.formatNumber(item.amount ?? '0.0', precision: depositHistoryController.depositRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
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
                          MyStrings.charge.tr,
                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: StringConverter.formatNumber(item.charge ?? '0.0', precision: depositHistoryController.depositRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularLarge.copyWith(color: MyColor.redCancelTextColor),
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
                          MyStrings.afterCharge.tr,
                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: StringConverter.formatNumber(item.finalAmount ?? '0.0', precision: depositHistoryController.depositRepo.apiClient.getDecimalAfterNumber()),
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
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
                          MyStrings.status.tr,
                          style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                        ),
                        StatusWidget(
                          status: depositHistoryController.getStatus(index),
                          color: depositHistoryController.getStatusColor(index),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
