import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/services/api_service.dart';

import '../../../../data/controller/deposit/deposit_history_controller.dart';
import '../../../../data/model/deposit/deposit_history_response_model.dart';
import '../../../../data/repo/deposit/deposit_repo.dart';
import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/no_data.dart';
import 'custom_deposit_card.dart';
import 'deposit_history_top.dart';

class DepositHistoryScreen extends StatefulWidget {
  const DepositHistoryScreen({
    super.key,
  });

  @override
  State<DepositHistoryScreen> createState() => _DepositHistoryScreenState();
}

class _DepositHistoryScreenState extends State<DepositHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<DepositHistoryController>().hasNext()) {
        Get.find<DepositHistoryController>().fetchNewList();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));

    Get.put(DepositRepo(apiClient: Get.find()));

    final controller = Get.put(DepositHistoryController(depositRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.beforeInitLoadData();

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
    return GetBuilder<DepositHistoryController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          title: MyStrings.depositHistory.tr,
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
                      controller.changeIsPress();
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
                          DepositHistoryTop(),
                          SizedBox(height: Dimensions.space10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: controller.depositList.isEmpty && controller.searchLoading == false
                          ? const Center(
                              child: NoDataWidget(
                                text: MyStrings.noDepositHistoryFound,
                              ),
                            )
                          : controller.searchLoading
                              ? const CustomLoader()
                              : RefreshIndicator(
                                  color: MyColor.primaryColor,
                                  onRefresh: () async {
                                    controller.beforeInitLoadData();
                                  },
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                    padding: EdgeInsets.zero,
                                    itemCount: controller.depositList.length + 1,
                                    controller: scrollController,
                                    separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                    itemBuilder: (context, index) {
                                      if (index == controller.depositList.length) {
                                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                                      }
                                      DepositHistoryListModel item = controller.depositList[index];
                                      return CustomDepositCard(
                                        onPressed: () {},
                                        depositHistoryController: controller,
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
