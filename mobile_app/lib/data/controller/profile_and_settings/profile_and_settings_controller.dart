import 'dart:convert';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/dashbaord/dashboard_controller.dart';
import 'package:vinance/data/model/authorization/authorization_response_model.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';
import 'package:vinance/data/repo/menu_repo/menu_repo.dart';
import 'package:vinance/environment.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../account/profile_controller.dart';

class ProfileAndSettingsController extends GetxController {
  MenuRepo menuRepo;
  GeneralSettingRepo repo;
  ProfileAndSettingsController({required this.menuRepo, required this.repo});

  ProfileController profileController = Get.find();
  bool logoutLoading = false;
  bool isLoading = true;
  bool noInternet = false;

  bool balTransferEnable = true;
  bool langSwitchEnable = true;

  void loadMenuConfigData() async {
    isLoading = true;
    update();

    await configureMenuItem();
    isLoading = false;
    update();
  }

  Future<void> logout() async {
    logoutLoading = true;
    update();
    try {
      var data = await menuRepo.logout();

      AuthorizationResponseModel authorizationResponseModel = AuthorizationResponseModel.fromJson(jsonDecode(data.responseJson));
      if (authorizationResponseModel.status?.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: authorizationResponseModel.message?.success ?? [MyStrings.logoutSuccessMsg]);
        await menuRepo.clearSharedPrefData();
        if (Environment.isGuestModeEnable) {
          Get.offAllNamed(RouteHelper.dashboardScreen);
        } else {
          Get.offAllNamed(RouteHelper.authenticationScreen);
        }
      } else {
        CustomSnackBar.success(successList: authorizationResponseModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
      }
      logoutLoading = false;
      update();
    } catch (e) {
      await menuRepo.clearSharedPrefData();
      if (Environment.isGuestModeEnable) {
        Get.offAllNamed(RouteHelper.dashboardScreen);
      } else {
        Get.offAllNamed(RouteHelper.authenticationScreen);
      }
      printx(e.toString());
    } finally {
      logoutLoading = false;
      update();
    }
  }

  Future<void> tempLogout() async {
    logoutLoading = true;
    update();
    try {
      await menuRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '');
      await menuRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, '');
      // await menuRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.fingerPrintLoginEnable, false);
      // await menuRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, '');
      await menuRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
      logoutLoading = false;
      update();
      Get.find<DashboardController>().changeSelectedIndex(0);
    } catch (e) {
      printx(e.toString());
    } finally {
      logoutLoading = false;
      update();
    }
  }

  bool isTransferEnable = true;
  bool isWithdrawEnable = true;
  bool isInvoiceEnable = true;

  configureMenuItem() async {
    update();

    ResponseModel response = await repo.getGeneralSetting();

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        bool langStatus = model.data?.generalSetting?.multiLanguage == '0' ? false : true;
        langSwitchEnable = langStatus;
        repo.apiClient.storeGeneralSetting(model);
        update();
      } else {
        List<String> message = [MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList: model.message?.error ?? message);
        return;
      }
    } else {
      if (response.statusCode == 503) {
        //noInternet=true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
      return;
    }
  }

  bool checkUserIsLoggedInOrNot() {
    return repo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }

  String getCurrentLanguageCode() {
    return repo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.languageCode) ?? 'en';
  }

  String getCurrentLanguageImage() {
    return repo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.languageImagePath) ?? '-1';
  }

  bool removeLoading = false;
  Future<void> removeAccount() async {
    removeLoading = true;
    update();

    final responseModal = await menuRepo.removeAccount();
    if (responseModal.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModal.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success) {
        await menuRepo.clearSharedPrefData();
        Get.offAllNamed(RouteHelper.authenticationScreen);
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.accountDeletedSuccessfully]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModal.message]);
    }

    removeLoading = false;
    update();
  }
}
