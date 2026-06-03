import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/model/authorization/authorization_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/model/profile/profile_response_model.dart';
import 'package:vinance/data/model/user_post_model/user_post_model.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/auth/sign_up_model/registration_response_model.dart';

class ProfileRepo {
  ApiClient apiClient;

  ProfileRepo({required this.apiClient});
  Future<RegistrationResponseModel> completeProfile(UserPostModel model) async {
    final map = modelToMap(model);
    String url = '${UrlContainer.baseUrl}${UrlContainer.profileCompleteEndPoint}';
    final res = await apiClient.request(
      url,
      Method.postMethod,
      map,
      passHeader: true,
    );
    final json = jsonDecode(res.responseJson);
    RegistrationResponseModel responseModel = RegistrationResponseModel.fromJson(json);
    return responseModel;
  }

  Map<String, dynamic> modelToMap(UserPostModel model) {
    Map<String, dynamic> bodyFields = {
      'address': model.address ?? '',
      'zip': model.zip ?? '',
      'state': model.state ?? "",
      'city': model.city ?? '',
      'mobile': model.mobile,
      'email': model.email,
      'country_code': model.countryCode,
      'country': model.country,
      "mobile_code": model.mobileCode,
    };

    if (model.firstname.isNotEmpty) {
      bodyFields['firstname'] = model.firstname;
    }

    if (model.lastName.isNotEmpty) {
      bodyFields['lastname'] = model.lastName;
    }

    if (model.username.isNotEmpty) {
      bodyFields['username'] = model.username;
    }

    return bodyFields;
  }

  Future<bool> updateProfileInfo(UserPostModel m, bool isProfile) async {
    try {
      apiClient.initToken();

      String url = '${UrlContainer.baseUrl}${isProfile ? UrlContainer.updateProfileEndPoint : UrlContainer.profileCompleteEndPoint}';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      Map<String, String> finalMap = {
        'firstname': m.firstname,
        'lastname': m.lastName,
        'address': m.address ?? '',
        'zip': m.zip ?? '',
        'state': m.state ?? "",
        'city': m.city ?? '',
      };

      request.headers.addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});
      if (m.image != null) {
        request.files.add(http.MultipartFile('image', m.image!.readAsBytes().asStream(), m.image!.lengthSync(), filename: m.image!.path.split('/').last));
      }
      request.fields.addAll(finalMap);

      http.StreamedResponse response = await request.send();

      String jsonResponse = await response.stream.bytesToString();
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(jsonResponse));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.success]);
        return true;
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail.tr]);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<ProfileResponseModel> loadProfileInfo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);

    if (responseModel.statusCode == 200) {
      ProfileResponseModel model = ProfileResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      return model;
    } else {
      return ProfileResponseModel();
    }
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
    return true;
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
}
