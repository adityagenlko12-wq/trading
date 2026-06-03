import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/withdraw/withdraw_controller.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../components/row_widget/custom_row.dart';

class WithdrawLimitChargeWidget extends StatelessWidget {
  const WithdrawLimitChargeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawController>(builder: (controller) {
      bool showRate = controller.isShowRate();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: Dimensions.space5,
                ),
                CustomRow(
                  firstText: MyStrings.withdrawLimit.tr,
                  lastText: controller.withdrawLimit,
                ),
                CustomRow(
                  firstText: MyStrings.charge.tr,
                  lastText: controller.charge,
                ),
                CustomRow(
                  firstText: MyStrings.receivable.tr,
                  lastText: controller.payableText,
                  showDivider: showRate,
                ),
                showRate
                    ? CustomRow(
                        firstText: MyStrings.conversionRate.tr,
                        lastText: controller.conversionRate,
                        showDivider: showRate,
                      )
                    : const SizedBox.shrink(),
                showRate
                    ? CustomRow(
                        firstText: '${MyStrings.in_.tr} ${controller.selectedWithdrawMethod?.currency}',
                        lastText: controller.inLocal,
                        showDivider: false,
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ],
      );
    });
  }
}
