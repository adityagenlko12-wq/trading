import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/transfer/transfer_controller.dart';
import '../../../components/row_widget/custom_row.dart';

class ChargeAmountOnTransferWidget extends StatelessWidget {
  const ChargeAmountOnTransferWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                verticalSpace(Dimensions.space10),
                CustomRow(
                  firstText: MyStrings.amount.tr,
                  lastText: "${StringConverter.formatNumber(controller.amountController.text, precision: controller.walletRepository.apiClient.getDecimalAfterNumber())} ${controller.selectedWalletData?.currency?.symbol ?? ""}",
                ),
                CustomRow(
                  firstText: MyStrings.charge.tr,
                  lastText: "${StringConverter.formatNumber(controller.chargeAmount, precision: controller.walletRepository.apiClient.getDecimalAfterNumber())} (${controller.walletRepository.apiClient.getChargePercent()}%})",
                ),
                CustomRow(
                  firstText: MyStrings.amountWithCharge.tr,
                  lastText: "${StringConverter.formatNumber(controller.amountWithCharge, precision: controller.walletRepository.apiClient.getDecimalAfterNumber())} ${controller.selectedWalletData?.currency?.symbol}",
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
