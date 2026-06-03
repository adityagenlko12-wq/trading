import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/style.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/transfer/transfer_controller.dart';
import '../../../data/repo/transfer/transfer_repository.dart';
import '../../../data/repo/wallet/wallet_repository.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_local_image_widget.dart';
import 'widgets/transfer_user_to_user_form.dart';
import 'widgets/transfer_wallet_to_wallet_widget.dart';

class TransferScreen extends StatefulWidget {
  final String walletType;
  final String selectedCurrencyFromParamsID;
  const TransferScreen({super.key, required this.walletType, this.selectedCurrencyFromParamsID = ''});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<TransferController>().hasNext()) {
        Get.find<TransferController>().loadAllWalletListByWalletType();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WalletRepository(apiClient: Get.find()));
    Get.put(TransferRepository(apiClient: Get.find()));
    final controller = Get.put(TransferController(walletRepository: Get.find(), transferRepository: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadAllWalletListByWalletType(selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID, type: widget.walletType);
      if (widget.walletType == 'funding') {
        controller.swapWalletType();
      }
      scrollController.addListener(scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(builder: (controller) {
      return Scaffold(
        // resizeToAvoidBottomInset: false,
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.transfer.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
              child: Ink(
                decoration: ShapeDecoration(
                  color: MyColor.getAppBarBackgroundColor(),
                  shape: const CircleBorder(),
                ),
                child: FittedBox(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.toNamed(RouteHelper.walletHistoryScreen, arguments: 'transfer');
                    },
                    icon: MyLocalImageWidget(
                      imagePath: MyIcons.historyIcon,
                      imageOverlayColor: MyColor.getAppBarContentColor(),
                      width: Dimensions.space25,
                    ),
                  ),
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: Builder(builder: (context) {
          if ((widget.walletType == 'spot'
              ? (controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherUser?.status == '1' && controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherWallet?.status == '1')
              : (controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherUser?.status == '1' && controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherWallet?.status == '1'))) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                    padding: const EdgeInsets.all(Dimensions.space8),
                    decoration: BoxDecoration(
                      color: MyColor.getScreenBgSecondaryColor(),
                      borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                    ),
                    child: TabBar(
                      physics: const NeverScrollableScrollPhysics(),
                      // controller: controller.transferTabController,
                      splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: MyColor.getPrimaryColor(),
                        borderRadius: const BorderRadiusDirectional.all(
                          Radius.circular(Dimensions.cardRadius2),
                        ),
                      ),
                      labelColor: MyColor.colorWhite,
                      labelStyle: regularLarge.copyWith(color: MyColor.colorWhite, fontSize: Dimensions.fontLarge),

                      //Unselected
                      unselectedLabelColor: MyColor.getSecondaryTextColor(),
                      unselectedLabelStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge),
                      // onTap: (value) => controller.changeTabIndex(value),
                      padding: EdgeInsets.zero,

                      tabs:  [
                        Tab(
                          text: MyStrings.otherUsers.tr,
                        ),
                        Tab(
                          text: MyStrings.otherWallet.tr,
                        ),
                      ],
                    ),
                  ),

                  // Tab bar

                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      // controller: controller.transferTabController,
                      children: [
                        TransferUserToUserFrom(
                          controller: controller,
                          scrollController: scrollController,
                          selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID,
                        ),
                        TransferWalletToWalletFrom(
                          controller: controller,
                          scrollController: scrollController,
                          selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            if ((widget.walletType == 'spot'
                ? (controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherUser?.status == '1' && controller.walletRepository.apiClient.getWalletTypes()?.spot?.configuration?.transferOtherWallet?.status == '0')
                : (controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherUser?.status == '1' && controller.walletRepository.apiClient.getWalletTypes()?.funding?.configuration?.transferOtherWallet?.status == '0'))) {
              return TransferUserToUserFrom(
                controller: controller,
                scrollController: scrollController,
                selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID,
              );
            } else {
              return TransferWalletToWalletFrom(
                controller: controller,
                scrollController: scrollController,
                selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID,
              );
            }
          }
        }),
      );
    });
  }
}
