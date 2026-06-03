import 'package:get/get.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/notification/notification_model.dart';
import '../../repo/notification/notification_repository.dart';

class NotificationController extends GetxController {
  NotificationRepository notificationRepo;

  NotificationController({required this.notificationRepo});

  bool isLoading = false;
  List<NotificationsData> notificationList = [];
  int page = 0;
  int notificationSelectedIndex = -1;
  String? imagePath;
  String? nextPageUrl;

  Future<void> getAllNotificationList({bool isFromLoad = false}) async {
  
    page = page + 1;
    if (page == 1) {
      notificationList.clear();
      isLoading = true;
      update();
    }

    try {
      ResponseModel responseModel = await notificationRepo.fetchAllNotification(page.toString());
      if (responseModel.statusCode == 200) {
        NotificationResponseModel model = notificationResponseModelFromJson(responseModel.responseJson);
        if (model.status == MyStrings.success) {
          nextPageUrl = model.data?.notifications?.nextPageUrl;
          imagePath = model.data?.notifications?.path;
          printx(nextPageUrl);

          List<NotificationsData>? tempNotifications = model.data?.notifications?.data;
          if (tempNotifications != null && tempNotifications.isNotEmpty) {
            notificationList.addAll(tempNotifications);
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  changeNotificationSelectedIndex(int index) {
    if (notificationSelectedIndex == index) {
      notificationSelectedIndex = -1;
      update();
      return;
    }
    notificationSelectedIndex = index;
    update();
  }
}
