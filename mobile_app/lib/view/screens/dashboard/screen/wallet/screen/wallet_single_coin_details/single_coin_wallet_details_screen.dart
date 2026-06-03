import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/custom_loader/custom_loader.dart';

import '../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/controller/wallet/single_coin_wallet_details_controller.dart';
import '../../../../../../../data/repo/wallet/wallet_repository.dart';
import '../../../../../../../data/services/api_service.dart';
import '../../../../../../components/app-bar/app_main_appbar.dart';
import '../../../../../../components/divider/custom_spacer.dart';
import 'widgets/single_coin_history_list_widget.dart';
import 'widgets/single_coin_screen_action_button_row.dart';
import 'widgets/single_coin_screen_all_widget_card.dart';
import 'widgets/single_coin_screen_balance_card.dart';
import 'widgets/single_coin_screen_total_balance_card.dart';

class SingleCoinWalletDetailsScreen extends StatefulWidget {
  final String coinSymbol;
  final String walletType;
  const SingleCoinWalletDetailsScreen({super.key, required this.coinSymbol, required this.walletType});

  @override
  State<SingleCoinWalletDetailsScreen> createState() => _SingleCoinWalletDetailsScreenState();
}

class _SingleCoinWalletDetailsScreenState extends State<SingleCoinWalletDetailsScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<SingleCoinWalletDetailsController>().hasNext()) {
        Get.find<SingleCoinWalletDetailsController>().loadSingleWalletDataByWalletType(symbolCurrency: widget.coinSymbol, type: widget.walletType);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WalletRepository(apiClient: Get.find()));
    final controller = Get.put(SingleCoinWalletDetailsController(walletRepository: Get.find()));
    super.initState();
    controller.loadWalletTabs();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadSingleWalletDataByWalletType(hotRefresh: true, symbolCurrency: widget.coinSymbol, type: widget.walletType);
      scrollController.addListener(scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SingleCoinWalletDetailsController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: "",
          titleWidget: Text(
            controller.singleWalletDetailsModelData.data?.wallet?.currency != null ? "${controller.singleWalletDetailsModelData.data?.wallet?.currency?.name ?? ''} (${controller.singleWalletDetailsModelData.data?.wallet?.currency?.symbol ?? ''})" : "",
            style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
          ),
          bgColor: MyColor.getScreenBgColor(),
          titleStyle: boldOverLarge.copyWith(fontSize: Dimensions.fontOverLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: controller.isWalletDataLoading
            ? const CustomLoader()
            : RefreshIndicator(
                color: MyColor.getPrimaryColor(),
                onRefresh: () async {
                  controller.loadSingleWalletDataByWalletType(hotRefresh: true, symbolCurrency: widget.coinSymbol, type: widget.walletType);
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                  child: Column(
                    children: [
                      SingleCoinScreenBalanceCard(
                        controller: controller,
                      ),
                      SingleCoinScreenButtonRow(
                        walletType: widget.walletType,
                        controller: controller,
                      ),
                      SingleCoinScreenTotalBalanceCard(
                        controller: controller,
                      ),
                      SingleCoinAllWidgetCard(
                        controller: controller,
                      ),
                      SingleCoinHistoryListWidget(
                        scrollController: scrollController,
                        controller: controller,
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}
