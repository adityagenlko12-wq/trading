import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/style.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/transfer/transfer_controller.dart';
import '../../../components/divider/custom_spacer.dart';

class TransferSearchCurrencyBoxAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TransferController controller;
  const TransferSearchCurrencyBoxAppBar({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: Dimensions.space10, bottom: Dimensions.space10, start: Dimensions.space15, end: Dimensions.space15),
        padding: const EdgeInsetsDirectional.only(top: Dimensions.space10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: MyColor.getPrimaryColor()),
                  color: MyColor.getScreenBgSecondaryColor(),
                  borderRadius: BorderRadius.circular(Dimensions.radiusMax),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      horizontalSpace(Dimensions.space10),
                      Icon(Icons.search, size: Dimensions.space25, color: MyColor.getPrimaryColor()),
                      horizontalSpace(Dimensions.space10),
                      Expanded(
                        child: TextField(
                          // controller: controller.searchController,
                          decoration: InputDecoration(
                            hintText: "${MyStrings.searchForCrypto.tr}...",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            controller.filterWalletDataList(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            horizontalSpace(Dimensions.space5),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                MyStrings.cancel.tr,
                style: regularMediumLarge.copyWith(color: MyColor.colorRed),
              ),
            )
          ],
        ),
      ),
    );
  }
}
