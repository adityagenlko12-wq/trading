import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vinance/view/screens/withdraw/widgets/withdraw_select_gateway_widget.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/withdraw/withdraw_controller.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/shimmer/text_field_loading_shimmer.dart';
import '../../../components/text-form-field/custom_widget_text_field.dart';
import 'wiithdraw_select_currency_widget.dart';
import 'spot_limit_chage_widget.dart';

class WithdrawScreenWalletFrom extends StatelessWidget {
  final WithdrawController controller;
  final String walletType;
  final String selectedCurrencyFromParamsID;
  const WithdrawScreenWalletFrom({
    super.key,
    required this.controller,
    this.walletType = '',
    required this.selectedCurrencyFromParamsID,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
        child: controller.isLoading
            ? const TextFieldLoadingShimmer()
            : Column(
                children: [
                  verticalSpace(Dimensions.space20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(Dimensions.space20),
                      Text(
                        MyStrings.selectCurrency.tr,
                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space10),
                      WithdrawSearchCurrencyWidget(
                        walletType: walletType,
                        controller: controller,
                        selectedCurrencyFromParamsID: selectedCurrencyFromParamsID,
                      ),
                      verticalSpace(Dimensions.space20),
                      Text(
                        MyStrings.gateway.tr,
                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space10),
                      WithdrawSelectGateWayWidget(
                        controller: controller,
                      ),
                      verticalSpace(Dimensions.space20),
                      const SizedBox(
                        height: Dimensions.space10,
                      ),
                      CustomWidgetTextField(
                        labelText: MyStrings.enterAmount.tr,
                        controller: controller.amountController,
                        readOnly: false,
                        inputTextAlign: TextAlign.left,
                        textInputType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                        ],
                        suffixWidget: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.setAmountToMax(walletType: walletType);
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                // color: MyColor.getScreenBgColor(),
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.space10, horizontal: Dimensions.space10),
                                child: Text(
                                  MyStrings.max.tr, // currency
                                  style: boldLarge.copyWith(color: MyColor.getPrimaryColor()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        hintText: MyStrings.enterAmount.tr,
                        onChanged: (value) {
                          if (value.toString().isEmpty) {
                            controller.changeInfoWidgetValue(0);
                          } else {
                            double amount = double.tryParse(value.toString()) ?? 0;
                            controller.changeInfoWidgetValue(amount);
                          }
                          return;
                        },
                      ),
                      verticalSpace(Dimensions.space20),
                      if (controller.amountController.text.trim() != '') controller.selectedWithdrawMethod?.name != MyStrings.selectOne ? const WithdrawLimitChargeWidget() : const SizedBox(),
                      verticalSpace(Dimensions.space20),
                      RoundedButton(
                        isLoading: controller.submitLoading,
                        horizontalPadding: Dimensions.space10,
                        verticalPadding: Dimensions.space15,
                        text: MyStrings.continueTxt.tr,
                        press: () {
                          controller.submitWithdrawRequest(walletType: walletType);
                        },
                        cornerRadius: 8,
                        isOutlined: false,
                        color: MyColor.getPrimaryButtonColor(),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
