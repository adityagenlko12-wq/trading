import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/model/profile/profile_response_model.dart';
import 'package:vinance/data/model/user/user_model.dart';
import 'package:vinance/data/model/user_post_model/user_post_model.dart';
import 'package:vinance/data/repo/account/profile_repo.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../environment.dart';
import '../../model/country_model/country_model.dart';
import '../../model/global/response_model/response_model.dart';

class ProfileCompleteController extends GetxController {
  ProfileRepo profileRepo;
  ProfileCompleteController({required this.profileRepo});

  ProfileResponseModel model = ProfileResponseModel();
  String? countryName;
  String? countryCode;
  String? mobileCode;
  String? userName;
  String? phoneNo;
  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode userNameFocusNode = FocusNode();
  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  bool isLoading = true;
  bool submitLoading = false;
  RegExp regex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  bool isCountryCodeSpaceHide = true;
  toggleHideCountryCodeErrorSpace({bool value = false}) {
    isCountryCodeSpaceHide = value;
    update();
  }

  updateProfile() async {
    try {
      String email = emailController.text.toString();
      String address = addressController.text.toString();
      String city = cityController.text.toString();
      String zip = zipCodeController.text.toString();
      String state = stateController.text.toString();

      if (emailData.isEmpty && email.isEmpty) {
        CustomSnackBar.error(errorList: [MyStrings.enterYourEmail]);
        return;
      }

      submitLoading = true;
      update();

      UserPostModel model = UserPostModel(
        image: null,
        firstname: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text == '' ? '' : emailController.text,
        username: userNameController.text,
        address: address,
        state: state,
        zip: zip,
        city: city,
        mobile: mobileNoController.text == '' ? '' : mobileNoController.text,
        country: countryName ?? '',
        mobileCode: mobileCode != null ? mobileCode!.replaceAll("[+]", "") : "",
        countryCode: countryCode ?? '',
      );

      final responseModel = await profileRepo.completeProfile(model);

      if (responseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: responseModel.message?.success ?? [MyStrings.success.tr]);
        checkAndGotoNextStep(responseModel.data?.user);
      } else {
        CustomSnackBar.error(errorList: responseModel.message?.error ?? [MyStrings.somethingWentWrong.tr]);
      }
    } catch (e) {
      printx(e.toString());
      submitLoading = false;
      update();
    }

    submitLoading = false;
    update();
  }

  bool remember = true;
  void checkAndGotoNextStep(User? user) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = user?.tv == '1' ? false : true;

    SharedPreferences preferences = profileRepo.apiClient.sharedPreferences;

    await preferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);

    await preferences.setBool(SharedPreferenceHelper.rememberMeKey, true);
    await profileRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);
    await preferences.setString(SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await preferences.setString(SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await preferences.setString(SharedPreferenceHelper.userNameKey, user?.username ?? '');
    await preferences.setString(SharedPreferenceHelper.userPhoneNumberKey, user?.mobile ?? '');
    await profileRepo.sendUserToken();

    if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    } else {
      await profileRepo.sendUserToken();
      Get.offAndToNamed(RouteHelper.dashboardScreen);
    }
  }

  ProfileResponseModel profileResponseModel = ProfileResponseModel();

  String imageUrl = '';

  File? imageFile;
  String userNameData = '';
  String firstNameData = '';
  String lastNameData = '';
  String emailData = '';
  String countryData = '';
  String countryCodeData = '';
  String phoneCodeData = '';
  String phoneData = '';

  initialData() async {
    await loadProfileInfo();
    await getCountryData();
  }

  loadProfileInfo() async {
    isLoading = true;
    update();
    try {
      profileResponseModel = await profileRepo.loadProfileInfo();

      if (profileResponseModel.data != null) {
        emailData = profileResponseModel.data?.user?.email ?? '';
        userNameData = profileResponseModel.data?.user?.username ?? '';
        firstNameData = profileResponseModel.data?.user?.firstname ?? '';
        lastNameData = profileResponseModel.data?.user?.lastname ?? '';
        countryData = profileResponseModel.data?.user?.country ?? '';
        countryCodeData = profileResponseModel.data?.user?.countryCode ?? '';
        phoneData = profileResponseModel.data?.user?.mobile ?? '';
      } else {
        isLoading = false;
        update();
      }
    } catch (e) {
      isLoading = false;
      update();
    }
    isLoading = false;
    update();
  } // country data

  TextEditingController searchCountryController = TextEditingController();
  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  String dialCode = Environment.defaultPhoneCode;
  void updateMobilecode(String code) {
    dialCode = code;
    update();
  }

  Future<dynamic> getCountryData() async {
    ResponseModel mainResponse = await profileRepo.getCountryList();

    if (mainResponse.statusCode == 200) {
      CountryModel model = CountryModel.fromJson(jsonDecode(mainResponse.responseJson));
      List<Countries>? tempList = model.data?.countries;

      if (tempList != null && tempList.isNotEmpty) {
        countryList.addAll(tempList);
        filteredCountries.addAll(tempList);
      }
      var selectDefCountry = tempList!.firstWhere(
        (country) => country.countryCode!.toLowerCase() == Environment.defaultCountryCode.toLowerCase(),
        orElse: () => Countries(),
      );
      if (selectDefCountry.dialCode != null) {
        selectCountryData(selectDefCountry);
        setCountryNameAndCode(selectDefCountry.country.toString(), selectDefCountry.countryCode.toString(), selectDefCountry.dialCode.toString());
      }
      countryLoading = false;
      update();
      return;
    } else {
      CustomSnackBar.error(errorList: [mainResponse.message]);

      countryLoading = false;
      update();
      isLoading = false;
      update();
      return;
    }
  }

  setCountryNameAndCode(String cName, String countryCode, String mobileCode) {
    countryName = cName;
    this.countryCode = countryCode;
    this.mobileCode = mobileCode;
    update();
  }

  Countries selectedCountryData = Countries();
  selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }
}
