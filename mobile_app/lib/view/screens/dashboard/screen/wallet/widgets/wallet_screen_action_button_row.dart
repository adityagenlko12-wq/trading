import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/wallet/wallet_controller.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class WalletScreenButtonRow extends StatelessWidget {
  final WalletController controller;
  const WalletScreenButtonRow({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
      child: Row(
        children: [
          if (controller.walletTabController?.index == 0 ? controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.deposit?.status == '1' : controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.deposit?.status == '1') ...[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyColor.getPrimaryColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
                ),
                onPressed: () {
                  Get.toNamed(
                    RouteHelper.depositScreen,
                    arguments: [controller.walletTabController?.index == 0 ? 'spot' : 'funding', ''],
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ignore: prefer_const_constructors
                    MyLocalImageWidget(
                      imagePath: MyIcons.depositAction,
                      imageOverlayColor: MyColor.colorWhite,
                      width: Dimensions.space15,
                    ),
                    horizontalSpace(Dimensions.space5),
                    Flexible(
                      child: Text(
                        MyStrings.deposit.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: regularLarge.copyWith(
                          color: MyColor.colorWhite,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
          if (controller.walletTabController?.index == 0 ? controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.withdraw?.status == '1' : controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.withdraw?.status == '1') ...[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyColor.getScreenBgSecondaryColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
                ),
                onPressed: () {
                  Get.toNamed(
                    RouteHelper.withdrawScreen,
                    arguments: [controller.walletTabController?.index == 0 ? 'spot' : 'funding', ''],
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyLocalImageWidget(
                      imagePath: MyIcons.withdrawAction,
                      imageOverlayColor: MyColor.getPrimaryTextColor(),
                      width: Dimensions.space15,
                    ),
                    horizontalSpace(Dimensions.space5),
                    Flexible(
                      child: Text(
                        MyStrings.withdraw.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: regularLarge.copyWith(
                          color: MyColor.getPrimaryTextColor(),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
          if (controller.walletTabController?.index == 0
              ? (controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherUser?.status == '1' || controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherWallet?.status == '1')
              : (controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherUser?.status == '1' || controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherWallet?.status == '1')) ...[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: MyColor.getScreenBgSecondaryColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
                ),
                onPressed: () {
                  Get.toNamed(
                    RouteHelper.transferScreen,
                    arguments: [controller.walletTabController?.index == 0 ? 'spot' : 'funding', ''],
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyLocalImageWidget(
                      imagePath: MyIcons.sendAction,
                      imageOverlayColor: MyColor.getPrimaryTextColor(),
                      width: Dimensions.space15,
                    ),
                    horizontalSpace(Dimensions.space5),
                    Flexible(
                      child: Text(
                        MyStrings.transfer.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: regularLarge.copyWith(
                          color: MyColor.getPrimaryTextColor(),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
