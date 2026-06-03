import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/repo/faq/faq_repository.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/faq/faq_controller.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/custom_loader/custom_loader.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/no_data.dart';
import 'widgets/faq_list.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(FaqRepository(apiClient: Get.find()));
    final controller = Get.put(FaqController(faqRepository: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAllFaqList();
      scrollController.addListener(scrollListener);
    });
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<FaqController>().hasNext()) {
        Get.find<FaqController>().getAllFaqList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaqController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.faqFull.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : controller.faqDataList.isEmpty
                ? const Center(
                    child: FittedBox(
                      child: NoDataWidget(
                        text: MyStrings.noNotificationHistoryFound,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.faqDataList.length + 1,
                    itemBuilder: (context, index) {
                      if (controller.faqDataList.length == index) {
                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                      }
                      return FaqListItem(
                          press: () {
                            controller.changeFaqSelectedIndex(index);
                          },
                          selectedIndex: controller.faqSelectedIndex,
                          index: index,
                          item: controller.faqDataList[index]);
                    },
                  ),
      );
    }); //
  }
}
