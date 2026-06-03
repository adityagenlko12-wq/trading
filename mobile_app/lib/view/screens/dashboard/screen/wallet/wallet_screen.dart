import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/wallet/wallet_controller.dart';
import '../../../../../data/repo/wallet/wallet_repository.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import 'widgets/wallet_all_assets_list_widget.dart';
import 'widgets/wallet_screen_action_button_row.dart';
import 'widgets/wallet_screen_balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<WalletController>().hasNext()) {
        Get.find<WalletController>().loadAllWalletListByWalletType();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WalletRepository(apiClient: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    final controller = Get.put(WalletController(walletRepository: Get.find(), generalSettingRepo: Get.find()));
    super.initState();
    controller.loadWalletTabs();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.updateGeneralSettingsData();
      controller.loadAllWalletListByWalletType(hotRefresh: true);
      scrollController.addListener(scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (controller) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: SafeArea(
            child: Column(
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
                    controller: controller.walletTabController,
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
                    onTap: (value) {
                      // controller.currentTabIndex(value);
                      controller.loadAllWalletListByWalletType(type: value == 0 ? 'spot' : 'funding', hotRefresh: true);
                    },
                    padding: EdgeInsets.zero,

                    tabs: [
                      Tab(
                        text: MyStrings.spotWallets.tr,
                      ),
                      Tab(
                        text: MyStrings.fundingWallets.tr,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: MyColor.getPrimaryColor(),
                    onRefresh: () async {
                      controller.loadAllWalletListByWalletType(hotRefresh: true);
                    },
                    child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            WalletScreenBalanceCard(
                              controller: controller,
                            ),

                            WalletScreenButtonRow(
                              controller: controller,
                            ),
                            //Title
                            Container(
                              margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    MyStrings.wallets.tr,
                                    style: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.only(),
                                        child: Ink(
                                          decoration: ShapeDecoration(
                                            color: MyColor.getAppBarBackgroundColor(),
                                            shape: const CircleBorder(),
                                          ),
                                          child: FittedBox(
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                Get.toNamed(RouteHelper.walletHistoryScreen);
                                              },
                                              icon: MyLocalImageWidget(
                                                imagePath: MyIcons.historyIcon,
                                                imageOverlayColor: MyColor.getSecondaryTextColor(),
                                                width: Dimensions.space25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            verticalSpace(Dimensions.space10),

                            //Coin List

                            WalletAllAssetsListWidget(
                              controller: controller,
                              scrollController: scrollController,
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
