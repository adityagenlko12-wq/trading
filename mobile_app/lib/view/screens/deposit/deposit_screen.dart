import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_icons.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/deposit/deposit_controller.dart';
import '../../../data/repo/deposit/deposit_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_local_image_widget.dart';
import 'widgets/wallet/deposit_screen_all_wallet_widget.dart';

class DepositScreen extends StatefulWidget {
  final String walletType;
  final String selectedCurrencyFromParamsID;
  const DepositScreen({
    super.key,
    required this.walletType,
    this.selectedCurrencyFromParamsID = '',
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  @override
  void initState() {
    super.initState();

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DepositRepo(apiClient: Get.find()));
    var controller = Get.put(DepositController(depositRepo: Get.find()));
    controller.loadDepositTabsData();
    controller.changeTabIndex(widget.walletType == 'spot' ? 0 : 1);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getDepositAllMethodAndCurrencyList(selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (controller) {
      return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: MyStrings.deposit.tr,
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              if (controller.checkUserIsLoggedInOrNot()) ...[
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
                          if (controller.checkUserIsLoggedInOrNot()) {
                            Get.toNamed(
                              RouteHelper.depositHistoryScreen,
                            );
                          } else {
                            Get.toNamed(RouteHelper.authenticationScreen);
                          }
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
              ],
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: Column(
            children: [
              verticalSpace(Dimensions.space10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                padding: const EdgeInsets.all(Dimensions.space8),
                decoration: BoxDecoration(
                  color: MyColor.getScreenBgSecondaryColor(),
                  borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                ),
                child: TabBar(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.depositTabController,
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

                  onTap: (value) => controller.changeTabIndex(value),
                  padding: EdgeInsets.zero,

                  tabs:  [
                    Tab(
                      text: MyStrings.spotWallets.tr,
                    ),
                    Tab(
                      text: MyStrings.fundingWallets.tr,
                    ),
                  ],
                ),
              ),

              // Tab bar

              Expanded(
                child: TabBarView(physics: const NeverScrollableScrollPhysics(), controller: controller.depositTabController, children: [
                  DepositScreenAllWalletFrom(controller: controller, walletType: 'spot', selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID),
                  DepositScreenAllWalletFrom(controller: controller, walletType: 'funding', selectedCurrencyFromParamsID: widget.selectedCurrencyFromParamsID),
                ]),
              ),
            ],
          ));
    });
  }
}
