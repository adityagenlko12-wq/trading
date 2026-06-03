import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/auth/metamask/metamask_login_controller.dart';

import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../components/buttons/rounded_button.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import '../../../../components/loading_border/loading_border.dart';

class ConnectMetamaskLoginBottomSheet extends StatelessWidget {
  const ConnectMetamaskLoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MetaMaskAuthLoginController>(builder: (metaLoginController) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, value) {
          metaLoginController.clearMetamaskOldData();
        },
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                verticalSpace(Dimensions.space20),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20),
                  child: Center(
                      child: Text(
                    MyStrings.metaMask.tr.toUpperCase(),
                    style: boldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                  )),
                ),
                verticalSpace(Dimensions.space20),
                LoadingBorderIndicator(
                  animate: metaLoginController.walletErrorHandler == null,
                  borderRadius: 20,
                  strokeWidth: 3,
                  color: MyColor.pendingColor,
                  bgColor: MyColor.getScreenBgSecondaryColor(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MyLocalImageWidget(
                      imagePath: MyIcons.metaMaskIcon,
                      width: 20.0,
                      height: 20.0,
                    ),
                  ),
                ),
                verticalSpace(Dimensions.space30),
                if (metaLoginController.messageData != '' && metaLoginController.walletAddressData != '') ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20),
                    child: Center(
                        child: Text(
                      metaLoginController.messageData.tr,
                      style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                    )),
                  ),
                  verticalSpace(Dimensions.space30),
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: RoundedButton(
                              isOutlined: true,
                              color: MyColor.colorRed,
                              borderColor: MyColor.getPrimaryTextColor(),
                              text: MyStrings.cancel.tr,
                              child: FittedBox(
                                child: Text(
                                  MyStrings.cancel.tr,
                                  style: regularLarge.copyWith(
                                    color: MyColor.getPrimaryTextColor(),
                                  ),
                                ),
                              ),
                              press: () {
                                metaLoginController.clearMetamaskOldData(disconnected: true);
                              },
                            ),
                          ),
                          horizontalSpace(Dimensions.space15),
                          Expanded(
                            flex: 2,
                            child: RoundedButton(
                              isOutlined: true,
                              color: MyColor.colorRed,
                              borderColor: MyColor.pendingColor,
                              text: MyStrings.verifyMetamaskLogin.tr,
                              child: FittedBox(
                                child: Text(
                                  MyStrings.verifyMetamaskLogin.tr,
                                  style: regularLarge.copyWith(
                                    color: MyColor.getPrimaryButtonTextColor(),
                                  ),
                                ),
                              ),
                              press: () async {
                                await metaLoginController.getSignatureCodeFromMetamask(message: metaLoginController.messageData);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(Dimensions.space10),
                ] else ...[
                  if (metaLoginController.isInitializing == false && metaLoginController.walletErrorHandler != null) ...[
                    verticalSpace(Dimensions.space10),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
                      child: Column(
                        children: [
                          Text(
                            "${MyStrings.donNotHave.tr} ${metaLoginController.w3mWalletInfo.listing.name}?",
                            style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                          verticalSpace(Dimensions.space30),
                          RoundedButton(
                            isOutlined: false,
                            color: MyColor.colorRed,
                            borderColor: MyColor.colorRed,
                            text: MyStrings.download.tr,
                            child: FittedBox(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.download_rounded,
                                    color: MyColor.getPrimaryButtonTextColor(),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(
                                    MyStrings.download.tr,
                                    style: regularLarge.copyWith(
                                      color: MyColor.getPrimaryButtonTextColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            press: () {
                              metaLoginController.launchMetaMaskUrl();
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    verticalSpace(Dimensions.space30),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space10),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: RoundedButton(
                                isOutlined: true,
                                color: MyColor.colorRed,
                                borderColor: MyColor.getPrimaryTextColor(),
                                text: MyStrings.cancel.tr,
                                child: FittedBox(
                                  child: Text(
                                    MyStrings.cancel.tr,
                                    style: regularLarge.copyWith(
                                      color: MyColor.getPrimaryTextColor(),
                                    ),
                                  ),
                                ),
                                press: () {
                                  metaLoginController.clearMetamaskOldData(disconnected: true);
                                  Get.back();
                                },
                              ),
                            ),
                            horizontalSpace(Dimensions.space15),
                            Expanded(
                              flex: 2,
                              child: RoundedButton(
                                isOutlined: false,
                                color: MyColor.pendingColor,
                                borderColor: MyColor.pendingColor,
                                text: MyStrings.verifyMetamaskLogin.tr,
                                child: FittedBox(
                                  child: Text(
                                    MyStrings.connectMetamask.tr,
                                    style: regularLarge.copyWith(
                                      color: MyColor.getPrimaryButtonTextColor(),
                                    ),
                                  ),
                                ),
                                press: () async {
                                  // metaLoginController.w3mService.openModal(context);

                                  metaLoginController.signInWithMetamask(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    verticalSpace(Dimensions.space10),
                  ]
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
