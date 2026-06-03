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
import '../../../components/shimmer/text_field_loading_shimmer.dart';
import '../../../components/text-form-field/custom_text_field.dart';
import '../../../components/text-form-field/custom_widget_text_field.dart';
import 'charge_amount_on_transfer_widget.dart';
import 'select_currency_widget.dart';

class TransferUserToUserFrom extends StatelessWidget {
  final ScrollController scrollController;
  final TransferController controller;
  final String selectedCurrencyFromParamsID;
  const TransferUserToUserFrom({
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
        child: controller.isWalletListLoading
            ? const TextFieldLoadingShimmer()
            : Column(
                children: [
                  verticalSpace(Dimensions.space20),
                  TransferScreenSelectCurrencyWidget(
                    controller: controller,
                    scrollController: scrollController,
                    selectedCurrencyFromParamsID: selectedCurrencyFromParamsID,
                  ),
                  verticalSpace(Dimensions.space10),
                  CustomTextField(
                    controller: controller.usernameController,
                    animatedLabel: false,
                    needOutlineBorder: true,
                    // controller: controller.mobileNoController,
                    labelText: MyStrings.username.tr,
                    hintText: MyStrings.enterReceiverUsername,
                    onChanged: (value) {
                      controller.update();
                    },
                    // focusNode: controller.mobileNoFocusNode,
                    // nextFocus: controller.passwordFocusNode,
                    textInputType: TextInputType.name,
                    fillColor: MyColor.getScreenBgSecondaryColor(),
                    inputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return MyStrings.fieldErrorMsg.tr;
                      } else {
                        return null;
                      }
                    },
                  ),
                  verticalSpace(Dimensions.space20),
                  CustomWidgetTextField(
                    labelText: MyStrings.enterAmount,
                    controller: controller.amountController,
                    readOnly: false,
                    textInputType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                    ],
                    inputTextAlign: TextAlign.start,
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
                    hintText: MyStrings.enterAmount.tr,
                    onChanged: (value) {
                      controller.changeChargeAmount(value);
                    },
                  ),
                  verticalSpace(Dimensions.space10),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: controller.amountController.text.trim().isNotEmpty ? 1 : 0,
                    child: Visibility(
                      visible: controller.amountController.text.trim().isNotEmpty,
                      child: Column(
                        children: [
                          const ChargeAmountOnTransferWidget(),
                          verticalSpace(Dimensions.space20),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(Dimensions.space10),
                  RoundedButton(
                    isLoading: controller.isSubmitLoading,
                    horizontalPadding: Dimensions.space10,
                    verticalPadding: Dimensions.space15,
                    text: MyStrings.submit.tr,

                    // loadingIndicatorColor: MyColor.getPrimaryTextColor(isReverse: true),
                    // textStyle: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor(isReverse: true)),
                    press: () {
                      controller.transferUserToUserData();
                    },
                    cornerRadius: 8,
                    isOutlined: false,
                    color: MyColor.getPrimaryButtonColor(),
                  ),
                  verticalSpace(Dimensions.space10)
                ],
              ),
      ),
    );
  }
}
