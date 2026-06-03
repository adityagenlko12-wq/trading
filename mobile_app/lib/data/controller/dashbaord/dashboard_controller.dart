import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../services/api_service.dart';

class DashboardController extends GetxController {
  ApiClient apiClient;
  DashboardController({required this.apiClient});
  int selectedBottomNavIndex = 0;

  void changeSelectedIndex(int newIndex) {
    selectedBottomNavIndex = newIndex;
    update();
  }

  bool checkUserIsLoggedInOrNot() {
    return apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
