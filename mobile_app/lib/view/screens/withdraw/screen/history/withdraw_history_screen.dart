import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/repo/withdraw/withdraw_history_repo.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/withdraw/withdraw_history_controller.dart';
import '../../../../../data/model/withdraw/withdraw_history_response_model.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/no_data.dart';
import 'custom_withdraw_card.dart';
import 'withdraw_history_top.dart';

class WithdrawHistoryScreen extends StatefulWidget {
  const WithdrawHistoryScreen({
    super.key,
  });

  @override
  State<WithdrawHistoryScreen> createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<WithdrawHistoryController>().hasNext()) {
        Get.find<WithdrawHistoryController>().loadPaginationData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));

    Get.put(WithdrawHistoryRepo(apiClient: Get.find()));

    final controller = Get.put(WithdrawHistoryController(withdrawHistoryRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initData();

      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawHistoryController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.withdrawHistory.tr,
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
                      controller.changeSearchStatus();
                    },
                    icon: Icon(controller.isSearch ? Icons.clear : Icons.search, color: MyColor.getAppBarContentColor(), size: 24),
                  ),
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: const EdgeInsets.only(top: Dimensions.space20, left: Dimensions.space15, right: Dimensions.space15),
                child: Column(
                  children: [
                    Visibility(
                      visible: controller.isSearch,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WithdrawHistoryTop(),
                          SizedBox(height: Dimensions.space10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: controller.withdrawList.isEmpty && controller.filterLoading == false
                          ? const Center(
                              child: NoDataWidget(
                                text: MyStrings.noWithdrawRequestFound,
                              ),
                            )
                          : controller.filterLoading
                              ? const CustomLoader()
                              : RefreshIndicator(
                                  color: MyColor.primaryColor,
                                  onRefresh: () async {
                                    controller.initData();
                                  },
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.withdrawList.length + 1,
                                    controller: scrollController,
                                    separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                    itemBuilder: (context, index) {
                                      if (index == controller.withdrawList.length) {
                                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                                      }
                                      WithdrawListModel item = controller.withdrawList[index];
                                      return CustomWithdrawCard(
                                        withdrawHistoryController: controller,
                                        item: item,
                                        index: index,
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
