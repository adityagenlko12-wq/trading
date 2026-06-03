import 'dart:convert';
import 'package:get/get.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/messages.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/localization/localization_controller.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../environment.dart';
import '../../model/onboard/onboard_model.dart';

class SplashController extends GetxController {
  GeneralSettingRepo repo;
  LocalizationController localizationController;

  SplashController({required this.repo, required this.localizationController});

  bool isLoading = true;

  gotoNextPage() async {
    await loadLanguage();
    bool isRemember = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
    bool isFirstTime = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.firstTimeOnAppKey) ?? true; // we need to check it bcz for first time we will redirect to sign up page
    bool isOnboardEnable = repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.onBoardIsOnKey) ?? true;
    bool fingerEnable = repo.apiClient.getFingerPrintStatus(); // if finger enable then user should redirect to login page and able to login by fingerprint else user will redirect to home page if he/she is already logined
    noInternet = false;
    update();

    initSharedData();
    getGSData(isRemember, isFirstTime, isOnboardEnable, fingerEnable);
  }

  bool noInternet = false;

  void getGSData(bool isRemember, bool isFirstTime, bool isOnboardEnable, bool fingerEnable) async {
    try {
      ResponseModel response = await repo.getGeneralSetting();

      if (response.statusCode == 200) {
        GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
        if (model.status?.toLowerCase() == MyStrings.success) {
          repo.apiClient.storeGeneralSetting(model);
        } else {
          List<String> message = [MyStrings.somethingWentWrong];
          CustomSnackBar.error(errorList: model.message?.error ?? message);
        }
      } else {
        if (response.statusCode == 503) {
          noInternet = true;
          update();
        }
        CustomSnackBar.error(errorList: [response.message]);
      }

      isLoading = false;
      update();

      if (isOnboardEnable && Environment.APP_ONBOARD) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAndToNamed(RouteHelper.onboardScreen);
        });
      } else {
        if (isRemember) {
          if (fingerEnable) {
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: true); // true means we will redirect to authentication page login tab
            });
          } else {
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.dashboardScreen);
            });
          }
        } else {
          if (Environment.isGuestModeEnable) {
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.dashboardScreen);
            });
          } else {
            bool isShouldOpenLoginTab = isFirstTime ? false : true;
            Future.delayed(const Duration(seconds: 1), () {
              Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: isShouldOpenLoginTab);
            });
          }
        }
      }
    } catch (e) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAndToNamed(RouteHelper.authenticationScreen, arguments: true); // true means we will redirect to authentication page login tab
      });
    }
  }

  Future<bool> initSharedData() {
    if (!repo.apiClient.sharedPreferences.containsKey(SharedPreferenceHelper.countryCode)) {
      return repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.countryCode, MyStrings.myLanguages[0].countryCode);
    }
    if (!repo.apiClient.sharedPreferences.containsKey(SharedPreferenceHelper.languageCode)) {
      return repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageCode, MyStrings.myLanguages[0].languageCode);
    }
    return Future.value(true);
  }

  Future<void> loadLanguage() async {
    localizationController.loadCurrentLanguage();
    String languageCode = localizationController.locale.languageCode;
    try {
      ResponseModel response = await repo.getLanguage(languageCode);
      if (response.statusCode == 200) {
        Map<String, Map<String, String>> language = {};
        saveLanguageList(response.responseJson);
        var resJson = jsonDecode(response.responseJson);
        await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, response.responseJson);
        var langKeyList = resJson['data']['file'].toString() == '[]' ? {} : resJson['data']['file'];
        Map<String, String> json = {};
        if (langKeyList is Map<String, dynamic>) {
          langKeyList.forEach((key, value) {
            json[key] = value.toString();
          });
        }
        language['${localizationController.locale.languageCode}_${localizationController.locale.countryCode}'] = json;
        Get.addTranslations(Messages(languages: language).keys);
      } else {
        CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      CustomSnackBar.error(errorList: [e.toString()]);
    }
  }

  void saveLanguageList(String languageJson) async {
    await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, languageJson);
    return;
  }

  bool isOnBoardLoading = false;
  List<OnBoard> onboardList = [];
  String onboardImagePath = "";

  Future<void> getAllOnboardDataList() async {
    isOnBoardLoading = true;
    update();
    try {
      ResponseModel responseModel = await repo.loadOnboardData();
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

    isOnBoardLoading = false;
    update();
  }
}
