import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/notification/notification_controller.dart';
import '../../../data/repo/notification/notification_repository.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/custom_loader/custom_loader.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/no_data.dart';
import 'widgets/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(NotificationRepository(apiClient: Get.find()));
    final controller = Get.put(NotificationController(notificationRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAllNotificationList();
      scrollController.addListener(scrollListener);
    });
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<NotificationController>().hasNext()) {
        Get.find<NotificationController>().getAllNotificationList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.notification.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : controller.notificationList.isEmpty
                ? const Center(
                    child: FittedBox(
                      child: NoDataWidget(text: MyStrings.noNotificationHistoryFound,),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.notificationList.length + 1,
                    itemBuilder: (context, index) {
                      if (controller.notificationList.length == index) {
                        return controller.hasNext() ? const CustomLoader(isPagination: true) : const SizedBox();
                      }
                      return NotificationListItem(
                          press: () {
                            controller.changeNotificationSelectedIndex(index);
                          },
                          selectedIndex: controller.notificationSelectedIndex,
                          index: index,
                          item: controller.notificationList[index]);
                    },
                  ),
      );
    });
  }
}


