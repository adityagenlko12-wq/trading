import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/deposit/deposit_controller.dart';
import '../../../components/divider/custom_spacer.dart';
import 'search_currency_from_list_widget.dart';

class DepositSearchCurrencyWidget extends StatelessWidget {
  final DepositController controller;
  final String selectedCurrencyFromParamsID;
  const DepositSearchCurrencyWidget({super.key, required this.controller, required this.selectedCurrencyFromParamsID});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        if (selectedCurrencyFromParamsID == '' || selectedCurrencyFromParamsID.toString() == '-1') {
          Get.to(DepositSearchCurrencyFromListWidget(
            controller: controller,
          ));
        }
      },
      child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: Dimensions.space15,
            horizontal: Dimensions.space15,
          ),
          decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyNetworkImageWidget(
                          imageUrl: controller.selectedCurrency?.imageUrl ?? '',
                          height: Dimensions.space30,
                          width: Dimensions.space30,
                        ),
                        horizontalSpace(Dimensions.space10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.selectedCurrency?.symbol ?? '',
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                TextSpan(
                                  text: " ",
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                TextSpan(
                                  text: controller.selectedCurrency?.name ?? '',
                                  style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selectedCurrencyFromParamsID == '' || selectedCurrencyFromParamsID.toString() == '-1') ...[
                          horizontalSpace(Dimensions.space10),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: MyColor.getSecondaryTextColor(),
                            size: Dimensions.space20,
                          ),
                        ]
                      ],
                    )),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
