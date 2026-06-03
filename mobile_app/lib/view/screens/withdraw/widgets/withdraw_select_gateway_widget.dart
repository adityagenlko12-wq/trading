import 'package:flutter/material.dart';
import 'package:vinance/data/controller/withdraw/withdraw_controller.dart';
import 'package:vinance/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../components/divider/custom_spacer.dart';
import 'withdraw_gateway_list_widget.dart';

class WithdrawSelectGateWayWidget extends StatelessWidget {
  final WithdrawController controller;
  const WithdrawSelectGateWayWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        CustomBottomSheetPlus(
          child: WithdrawGateWayBottomSheetWidget(
            controller: controller,
          ),
          isNeedPadding: false,
          bgColor: MyColor.transparentColor,
        ).show(context);
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
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.selectedWithdrawMethod?.name ?? '',
                                  style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        horizontalSpace(Dimensions.space10),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: MyColor.getSecondaryTextColor(),
                          size: Dimensions.space20,
                        ),
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
