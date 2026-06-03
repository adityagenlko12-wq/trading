import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/screens/deposit/widgets/deposit_select_gateway_widget.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/deposit/deposit_controller.dart';
import '../../../../components/buttons/rounded_button.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_network_image_widget.dart';
import '../../../../components/shimmer/text_field_loading_shimmer.dart';
import '../deposit_select_currency_widget.dart';
import 'charge_amount_on_deposit_widget.dart';

class DepositScreenAllWalletFrom extends StatelessWidget {
  final DepositController controller;
  final String walletType;
  final String selectedCurrencyFromParamsID;
  const DepositScreenAllWalletFrom({
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
        child: controller.isDepositMethodLoading
            ? const TextFieldLoadingShimmer()
            : Column(
                children: [
                  verticalSpace(Dimensions.space10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(Dimensions.space20),
                      Text(
                        MyStrings.selectCurrency.tr,
                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space10),
                      DepositSearchCurrencyWidget(
                        selectedCurrencyFromParamsID: selectedCurrencyFromParamsID,
                        controller: controller,
                      ),
                      verticalSpace(Dimensions.space20),
                      Text(
                        MyStrings.gateway.tr,
                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space10),
                      DepositSelectGateWayWidget(
                        controller: controller,
                      ),
                      verticalSpace(Dimensions.space20),
                      const SizedBox(
                        height: Dimensions.space10,
                      ),
                      Text(
                        MyStrings.enterAmount.tr,
                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      ),
                      verticalSpace(Dimensions.space10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 48.3,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space15,
                            ),
                            decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyNetworkImageWidget(
                                  imageUrl: controller.selectedCurrency?.imageUrl ?? '',
                                  height: Dimensions.space20,
                                  width: Dimensions.space20,
                                ),
                                horizontalSpace(Dimensions.space10),
                                Text(
                                  controller.selectedCurrency?.symbol.toString() ?? '',
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                          horizontalSpace(Dimensions.space10),
                          Expanded(
                            child: SizedBox(
                              height: 48.8,
                              child: CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                inputAction: TextInputAction.done,
                                controller: controller.amountController,
                                textInputType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                                ],
                                readOnly: false,
                                fillColor: MyColor.getScreenBgSecondaryColor(),
                                hintText: MyStrings.enterAmount.tr,
                                onChanged: (value) {
                                  if (value.toString().isEmpty) {
                                    controller.changeDepositChargeInfoWidgetValue(0);
                                  } else {
                                    double amount = double.tryParse(value.toString()) ?? 0;
                                    controller.changeDepositChargeInfoWidgetValue(amount);
                                  }
                                  return;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(Dimensions.space20),
                      if (controller.amountController.text.trim() != '') controller.selectedDepositPaymentMethod?.name != MyStrings.selectOne ? const ChargeAmountOnDepositWidget() : const SizedBox(),
                      verticalSpace(Dimensions.space20),
                      RoundedButton(
                        isLoading: controller.submitLoading,
                        horizontalPadding: Dimensions.space10,
                        verticalPadding: Dimensions.space15,
                        text: MyStrings.continueTxt.tr,
                        press: () {
                          // controller.changeSpotWalletStep(2);
                          controller.submitNewDeposit(walletType: walletType);
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
