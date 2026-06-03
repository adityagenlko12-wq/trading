import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/model/authorization/authorization_response_model.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';

import '../../core/helper/string_format_helper.dart';

class ApiClient extends GetxService {
  SharedPreferences sharedPreferences;
  ApiClient({required this.sharedPreferences});

  Future<ResponseModel> request(
    String uri,
    String method,
    Map<String, dynamic>? params, {
    bool passHeader = false,
    bool isOnlyAcceptType = false,
    bool needAuthCheck = false,
    Map<String, String>? headers,
  }) async {
    Uri url = Uri.parse(uri);
    http.Response response;

    try {
      if (method == Method.postMethod) {
        if (passHeader) {
          initToken();
          if (isOnlyAcceptType) {
            response = await http.post(url, body: params, headers: {
              "Accept": "application/json",
              ...?headers,
            });
          } else {
            response = await http.post(url, body: params, headers: {
              "Accept": "application/json",
              "Authorization": "$tokenType $token",
              ...?headers,
            });
          }
        } else {
          response = await http.post(url, body: params);
        }
      } else if (method == Method.postMethod) {
        if (passHeader) {
          initToken();
          response = await http.post(url, body: params, headers: {
            "Accept": "application/json",
            "Authorization": "$tokenType $token",
            ...?headers,
          });
        } else {
          response = await http.post(url, body: params);
        }
      } else if (method == Method.deleteMethod) {
        response = await http.delete(url);
      } else if (method == Method.updateMethod) {
        response = await http.patch(url);
      } else {
        if (passHeader) {
          initToken();
          response = await http.get(url, headers: {
            "Accept": "application/json",
            "Authorization": "$tokenType $token",
            ...?headers,
          });
        } else {
          response = await http.get(
            url,
          );
        }
      }

      printx('url--------------${uri.toString()}');
      printx('params-----------${params.toString()}');
      printx('status-----------${response.statusCode}');
      printx('body-------------${response.body.toString()}');
      printx('token------------$token');

      if (response.body.toString() != '') {
        if (response.statusCode == 200) {
          try {
            AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.body));
            if (model.remark == 'profile_incomplete') {
              Get.toNamed(RouteHelper.profileCompleteScreen);
            } else if (model.remark == 'kyc_verification') {
              Get.offAndToNamed(RouteHelper.kycScreen);
            } else if (model.remark == 'unauthenticated') {
              if (needAuthCheck) {
                sharedPreferences.setBool(SharedPreferenceHelper.fingerPrintLoginEnable, false);
                sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
                sharedPreferences.remove(SharedPreferenceHelper.token);
                Get.toNamed(RouteHelper.authenticationScreen);
              }
            } else if (model.remark == 'unverified' && uri != '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}' && uri != '${UrlContainer.baseUrl}${UrlContainer.authorizationCodeEndPoint}') {
              // ignore: unrelated_type_equality_checks
              checkAndGotoNextStep(model);
            }
          } catch (e) {
            e.toString();
          }

          return ResponseModel(true, 'success', 200, response.body);
        } else {
          return ResponseModel(false, 'error', 400, response.body);
        }
      } else if (response.statusCode == 401) {
        sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
        Get.offAllNamed(RouteHelper.authenticationScreen);
        return ResponseModel(false, MyStrings.unAuthorized.tr, 401, response.body);
      } else if (response.statusCode == 500) {
        return ResponseModel(false, MyStrings.serverError.tr, 500, response.body);
      } else {
        return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, response.body);
      }
    } on SocketException {
      return ResponseModel(false, MyStrings.noInternet.tr, 503, '');
    } on FormatException {
      return ResponseModel(false, MyStrings.badResponseMsg.tr, 400, '');
    } catch (e) {
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, 499, '');
    }
  }

  String token = '';
  String tokenType = '';

  initToken() {
    if (sharedPreferences.containsKey(SharedPreferenceHelper.accessTokenKey)) {
      String? t = sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey);
      String? tType = sharedPreferences.getString(SharedPreferenceHelper.accessTokenType);
      token = t ?? '';
      tokenType = tType ?? 'Bearer';
    } else {
      token = '';
      tokenType = 'Bearer';
    }
  }

  void checkAndGotoNextStep(AuthorizationResponseModel responseModel) async {
    bool isBan = responseModel.data?.user?.status == "1" ? false : true;
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete == '0' ? true : false;

    // await sharedPreferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    // await sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, responseModel.data?.accessToken ?? '');
    // await sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, responseModel.data?.tokenType ?? '');
    // await sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    // await sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');
    // await sharedPreferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.profileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    }
  }

  storeGeneralSetting(GeneralSettingResponseModel model) {
    String json = jsonEncode(model.toJson());
    sharedPreferences.setString(SharedPreferenceHelper.generalSettingKey, json);
    getGSData();
  }

  GeneralSettingResponseModel getGSData() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    return model;
  }

  String getCurrencyOrUsername({bool isCurrency = true, bool isSymbol = false}) {
    if (isCurrency) {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      String currency = isSymbol ? model.data?.generalSetting?.curSym ?? '' : model.data?.generalSetting?.curText ?? '';
      return currency;
    } else {
      String username = sharedPreferences.getString(SharedPreferenceHelper.userNameKey) ?? '';
      return username;
    }
  }

  int getDecimalAfterNumber() {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      int result = int.parse(model.data?.generalSetting?.allowDecimalAfterNumber ?? '4');
      return result;
    } catch (e) {
      return 4;
    }
  }

  String getChargePercent({bool isUserCharge = true}) {
    try {
      String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
      String result = isUserCharge ? model.data?.generalSetting?.otherUserTransferCharge ?? '0' : model.data?.generalSetting?.p2PTradeCharge ?? '0';
      return result;
    } catch (e) {
      return '0';
    }
  }

  WalletTypes? getWalletTypes() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    WalletTypes? result = model.data?.generalSetting?.walletTypes;
    return result;
  }

  String getUserEmail() {
    String email = sharedPreferences.getString(SharedPreferenceHelper.userEmailKey) ?? '';
    return email;
  }

  String getUserID() {
    String idKey = sharedPreferences.getString(SharedPreferenceHelper.userIdKey) ?? '';
    return idKey;
  }

  bool getPasswordStrengthStatus() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    bool checkPasswordStrength = model.data?.generalSetting?.securePassword.toString() == '0' ? false : true;
    return checkPasswordStrength;
  }

  PusherConfig getPusherConfigData() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    PusherConfig pusherConfig = model.data?.generalSetting?.pusherConfig ?? PusherConfig();
    return pusherConfig;
  }

  SocialiteCredentials getSocialCredentialsConfigData() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    SocialiteCredentials social = model.data?.generalSetting?.socialiteCredentials ?? SocialiteCredentials();
    return social;
  }

  bool getSocialCredentialsEnabledAll() {
    return getSocialCredentialsConfigData().linkedin?.status == '1' && getSocialCredentialsConfigData().linkedin?.status == '1';
  }

  bool getMetaMetamaskEnableStatus() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));

    return model.data?.generalSetting?.metamaskLogin.toString() == '1';
  }

  String getSocialCredentialsRedirectUrl() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    String redirect = model.data?.socialLoginRedirect ?? "";
    return redirect;
  }

  String getTemplateName() {
    String pre = sharedPreferences.getString(SharedPreferenceHelper.generalSettingKey) ?? '';
    GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(pre));
    String templateName = model.data?.generalSetting?.activeTemplate ?? '';
    return templateName;
  }

  bool getFingerPrintStatus() {
    bool status = sharedPreferences.getBool(SharedPreferenceHelper.fingerPrintLoginEnable) ?? false;
    return status;
  }

  storeFingerPrintStatus(bool status) {
    sharedPreferences.setBool(SharedPreferenceHelper.fingerPrintLoginEnable, status);
  }

  clearOldAuthData() async {
    await sharedPreferences.remove(SharedPreferenceHelper.userIdKey);
    await sharedPreferences.remove(SharedPreferenceHelper.accessTokenKey);
    await sharedPreferences.remove(SharedPreferenceHelper.accessTokenType);
    await sharedPreferences.remove(SharedPreferenceHelper.userEmailKey);
    await sharedPreferences.remove(SharedPreferenceHelper.userPhoneNumberKey);
    await sharedPreferences.remove(SharedPreferenceHelper.userNameKey);
  }
}
