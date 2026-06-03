import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/model/auth/sign_up_model/registration_response_model.dart';
import 'package:vinance/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/services/api_service.dart';

class RegistrationRepo {
  ApiClient apiClient;

  RegistrationRepo({required this.apiClient});

  Future<RegistrationResponseModel> registerUser(SignUpModel model) async {
    final map = modelToMap(model);
    String url = '${UrlContainer.baseUrl}${UrlContainer.registrationEndPoint}';
    final res = await apiClient.request(url, Method.postMethod, map, passHeader: true, isOnlyAcceptType: true);
    final json = jsonDecode(res.responseJson);
    RegistrationResponseModel responseModel = RegistrationResponseModel.fromJson(json);
    return responseModel;
  }

  Map<String, dynamic> modelToMap(SignUpModel model) {
    Map<String, dynamic> bodyFields = {
      'firstname': model.firstName,
      'lastname': model.lastName,
      'email': model.email,
      'agree': model.agree.toString() == 'true' ? 'true' : '',
      'password': model.password,
      'password_confirmation': model.password,
      'reference': model.refer,
    };

    return bodyFields;
  }

  Future<dynamic> getCountryList() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.countryEndPoint}';
    ResponseModel model = await apiClient.request(url, Method.getMethod, null);
    return model;
  }

  Future<bool> sendUserToken() async {
    String deviceToken;
    if (apiClient.sharedPreferences.containsKey(SharedPreferenceHelper.fcmDeviceKey)) {
      deviceToken = apiClient.sharedPreferences.getString(SharedPreferenceHelper.fcmDeviceKey) ?? '';
    } else {
      deviceToken = '';
    }

    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    bool success = false;
    if (deviceToken.isEmpty) {
      firebaseMessaging.getToken().then((fcmDeviceToken) async {
        success = await sendUpdatedToken(fcmDeviceToken ?? '');
      });
    } else {
      firebaseMessaging.onTokenRefresh.listen((fcmDeviceToken) async {
        if (deviceToken == fcmDeviceToken) {
          success = true;
        } else {
          apiClient.sharedPreferences.setString(SharedPreferenceHelper.fcmDeviceKey, fcmDeviceToken);
          success = await sendUpdatedToken(fcmDeviceToken);
        }
      });
    }
    return success;
  }

  Future<bool> sendUpdatedToken(String deviceToken) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.deviceTokenEndPoint}';
    Map<String, String> map = deviceTokenMap(deviceToken);

    await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return true;
  }

  Map<String, String> deviceTokenMap(String deviceToken) {
    Map<String, String> map = {'token': deviceToken.toString()};
    return map;
  }

  Future<ResponseModel> socialLoginUser({
    String accessToken = '',
    String? provider,
  }) async {
    Map<String, String>? map;

    if (provider == 'google') {
      map = {'token': accessToken, 'provider': "google"};
    }
    if (provider == 'linkedin') {
      map = {'token': accessToken, 'provider': "linkedin"};
    }

    String url = '${UrlContainer.baseUrl}${UrlContainer.socialLoginEndPoint}';

    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: false);

    return model;
  }

  //Metamask

  Future<ResponseModel> getMetaMaskLoginMessage(String address) async {
    Map<String, String> map = {
      'wallet_address': address,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.metamaskGetMessageEndPoint}';

    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: false);

    return model;
  }

  Future<ResponseModel> verifyMetaMaskLoginSignature({
    required String walletAddress,
    required String message,
    required String signature,
    required String nonce,
  }) async {
    Map<String, String> map = {
      'message': message,
      'wallet': walletAddress,
      'nonce': nonce,
      'signature': signature,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.metamaskMessageVerifyEndPoint}';

    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: false);

    return model;
  }
}
