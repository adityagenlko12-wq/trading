import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/onboard/onboard_model.dart';
import '../../repo/onboard/onboard_repo.dart';

class OnboardController extends GetxController {
  OnboardRepo onboardRepo;

  OnboardController({required this.onboardRepo});

  bool isLoading = false;
  List<OnBoard> onboardList = [];
  String onboardImagePath = "";

  Future<void> getAllOnboardDataList() async {
    isLoading = true;
    update();
    try {
      ResponseModel responseModel = await onboardRepo.loadOnboardData();
      if (responseModel.statusCode == 200) {
        OnBoardResponseModel model = onBoardsFromJson(responseModel.responseJson);
        if (model.status == MyStrings.success) {
          List<OnBoard>? tempListData = model.data?.onBoards;
          onboardImagePath = model.data?.imagePath ?? '';
          if (tempListData != null && tempListData.isNotEmpty) {
            onboardList.addAll(tempListData);
          }
        } else {
          // CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    }

    if (onboardList.isEmpty) {
      Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: false);
    }

    isLoading = false;
    update();
  }
}
