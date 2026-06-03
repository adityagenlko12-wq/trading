import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../data/controller/transfer/transfer_controller.dart';

class TransferSwapWalletWidget extends StatelessWidget {
  final TransferController controller;
  const TransferSwapWalletWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: Dimensions.space15,
        horizontal: Dimensions.space15,
      ),
      decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                //First Row
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_exchange_outlined,
                              color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              size: Dimensions.space17,
                            ),
                            horizontalSpace(Dimensions.space10),
                            Text(
                              MyStrings.from.tr,
                              style: regularLarge.copyWith(
                                color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              ),
                            ),
                            horizontalSpace(Dimensions.space10),
                          ],
                        ),
                      ),
                    ),
                    horizontalSpace(Dimensions.space10),
                    Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.transferWalletType[0]['fullName'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                              ),
                            ),
                            horizontalSpace(Dimensions.space10),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              size: Dimensions.space15,
                            ),
                          ],
                        )),
                  ],
                ),
                //Second Row

                verticalSpace(Dimensions.space10),
                Container(
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsetsDirectional.only(start: 1),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                    size: Dimensions.space15,
                  ),
                ),
                verticalSpace(Dimensions.space10),
                //First Row
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_exchange_outlined,
                              color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              size: Dimensions.space17,
                            ),
                            horizontalSpace(Dimensions.space10),
                            Text(
                              MyStrings.to.tr,
                              style: regularLarge.copyWith(
                                color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              ),
                            ),
                            horizontalSpace(Dimensions.space10),
                          ],
                        ),
                      ),
                    ),
                    horizontalSpace(Dimensions.space10),
                    Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.transferWalletType[1]['fullName'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                              ),
                            ),
                            horizontalSpace(Dimensions.space10),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: MyColor.getSecondaryTextColor().withOpacity(0.3),
                              size: Dimensions.space15,
                            ),
                          ],
                        )),
                  ],
                )
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsetsDirectional.only(start: Dimensions.space5),
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    controller.swapWalletType();
                  },
                  icon: Icon(
                    Icons.swap_vert_outlined,
                    color: MyColor.getPrimaryColor(),
                    size: Dimensions.space20,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
