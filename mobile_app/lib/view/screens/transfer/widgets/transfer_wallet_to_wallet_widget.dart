import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/transfer/transfer_controller.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/text-form-field/custom_widget_text_field.dart';
import 'select_currency_widget.dart';
import 'transfer_swap_wallet_widget.dart';

class TransferWalletToWalletFrom extends StatelessWidget {
  final ScrollController scrollController;
  final TransferController controller;
  final String selectedCurrencyFromParamsID;
  const TransferWalletToWalletFrom({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.selectedCurrencyFromParamsID,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
        child: Column(
          children: [
            verticalSpace(Dimensions.space20),
            TransferScreenSelectCurrencyWidget(
              scrollController: scrollController,
              controller: controller,
              selectedCurrencyFromParamsID: selectedCurrencyFromParamsID,
            ),
            verticalSpace(Dimensions.space20),
            TransferSwapWalletWidget(
              controller: controller,
            ),
            verticalSpace(Dimensions.space20),
            CustomWidgetTextField(
              labelText: MyStrings.enterAmount,
              controller: controller.amountController,
              readOnly: false,
              inputTextAlign: TextAlign.left,
              textInputType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
              ],
              suffixWidget: GestureDetector(
                onTap: () {
                  controller.setAmountToMax();
                },
                child: Container(
                  // color: MyColor.getScreenBgColor(),
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space10),
                  child: Text(
                    MyStrings.max.tr,
                    style: boldLarge.copyWith(color: MyColor.getPrimaryColor()),
                  ),
                ),
              ),
              hintText: MyStrings.enterAmount,
              onChanged: (v) {},
            ),
            verticalSpace(Dimensions.space20),
            RoundedButton(
              isLoading: controller.isSubmitLoading,
              horizontalPadding: Dimensions.space10,
              verticalPadding: Dimensions.space15,
              text: MyStrings.submit,

              // loadingIndicatorColor: MyColor.getPrimaryTextColor(isReverse: true),
              // textStyle: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor(isReverse: true)),
              press: () {
                controller.transferWalletToWalletData();
              },
              cornerRadius: 8,
              isOutlined: false,
              color: MyColor.getPrimaryButtonColor(),
            ),
          ],
        ),
      ),
    );
  }
}
