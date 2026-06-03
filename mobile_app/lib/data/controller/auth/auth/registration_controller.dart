import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/model/auth/sign_up_model/registration_response_model.dart';
import 'package:vinance/data/model/auth/sign_up_model/sign_up_model.dart';
import 'package:vinance/data/model/country_model/country_model.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/model/model/error_model.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';
import 'package:vinance/data/repo/auth/signup_repo.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart' as gSignIn;
import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/packages/signin_with_linkdin/signin_with_linkedin.dart';
import '../../../../environment.dart';

class RegistrationController extends GetxController {
  RegistrationRepo registrationRepo;
  GeneralSettingRepo generalSettingRepo;

  RegistrationController({required this.registrationRepo, required this.generalSettingRepo});

  bool isLoading = true;
  bool agreeTC = false;

  GeneralSettingResponseModel generalSettingMainModel = GeneralSettingResponseModel();
  final gSignIn.GoogleSignIn googleSignIn = gSignIn.GoogleSignIn();
  bool checkPasswordStrength = false;
  bool needAgree = true;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode referNameFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController referNameController = TextEditingController();

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? referName;

  RegExp regex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  bool submitLoading = false;
  bool isCountryCodeSpaceHide = true;
  toggleHideCountryCodeErrorSpace({bool value = false}) {
    isCountryCodeSpaceHide = value;
    update();
  }

  signUpUser() async {
    if (needAgree && !agreeTC) {
      CustomSnackBar.error(
        errorList: [MyStrings.agreePolicyMessage],
      );
      return;
    }

    submitLoading = true;
    update();

    SignUpModel model = getUserData();
    final responseModel = await registrationRepo.registerUser(model);

    if (responseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
      CustomSnackBar.success(successList: responseModel.message?.success ?? [MyStrings.success.tr]);
      checkAndGotoNextStep(responseModel);
    } else {
      CustomSnackBar.error(errorList: responseModel.message?.error ?? [MyStrings.somethingWentWrong.tr]);
    }

    submitLoading = false;
    update();
  }

  // setCountryNameAndCode(String cName, String countryCode, String mobileCode) {
  //   countryName = cName;
  //   this.countryCode = countryCode;
  //   this.mobileCode = mobileCode;
  //   update();
  // }

  updateAgreeTC() {
    agreeTC = !agreeTC;
    update();
  }

  SignUpModel getUserData() {
    SignUpModel model = SignUpModel(
      firstName: fNameController.text,
      lastName: lNameController.text,
      email: emailController.text.toString(),
      agree: agreeTC ? true : false,
      password: passwordController.text.toString(),
      refer: referNameController.text,
    );

    return model;
  }

  bool remember = true;
  void checkAndGotoNextStep(RegistrationResponseModel responseModel) async {
    // bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    // bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    // bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    await registrationRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true);

    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, responseModel.data?.accessToken ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, responseModel.data?.tokenType ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');
    await registrationRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);
    closeAllController();
    Get.offAndToNamed(RouteHelper.profileCompleteScreen);
  }

  void closeAllController() {
    isLoading = false;
    emailController.text = '';
    passwordController.text = '';
    cPasswordController.text = '';
    fNameController.text = '';
    lNameController.text = '';
    referNameController.text = '';
  }

  clearAllData() {
    closeAllController();
  }

  List<ErrorModel> passwordValidationRules = [
    ErrorModel(text: MyStrings.hasUpperLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasLowerLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasDigit.tr, hasError: true),
    ErrorModel(text: MyStrings.hasSpecialChar.tr, hasError: true),
    ErrorModel(text: MyStrings.minSixChar.tr, hasError: true),
  ];

  bool isCountryLoading = true;
  void initData() async {
    isLoading = true;
    toggleHideCountryCodeErrorSpace(value: true);
    update();
    // await getCountryData();

    ResponseModel response = await generalSettingRepo.getGeneralSetting();
    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == 'success') {
        generalSettingMainModel = model;
        registrationRepo.apiClient.storeGeneralSetting(model);
      } else {
        List<String> message = [MyStrings.somethingWentWrong.tr];
        CustomSnackBar.error(errorList: model.message?.error ?? message);
        return;
      }
    } else {
      if (response.statusCode == 503) {
        noInternet = true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
      return;
    }

    needAgree = generalSettingMainModel.data?.generalSetting?.agree.toString() == '0' ? false : true;
    checkPasswordStrength = generalSettingMainModel.data?.generalSetting?.securePassword.toString() == '0' ? false : true;

    isLoading = false;
    update();
  }

  // country data
  TextEditingController searchCountryController = TextEditingController();
  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  String dialCode = Environment.defaultPhoneCode;
  void updateMobilecode(String code) {
    dialCode = code;
    update();
  }

  // Future<dynamic> getCountryData() async {
  //   ResponseModel mainResponse = await registrationRepo.getCountryList();

  //   if (mainResponse.statusCode == 200) {
  //     CountryModel model = CountryModel.fromJson(jsonDecode(mainResponse.responseJson));
  //     List<Countries>? tempList = model.data?.countries;

  //     if (tempList != null && tempList.isNotEmpty) {
  //       countryList.addAll(tempList);
  //       filteredCountries.addAll(tempList);
  //     }
  //     var selectDefCountry = tempList!.firstWhere(
  //       (country) => country.countryCode!.toLowerCase() == Environment.defaultCountryCode.toLowerCase(),
  //       orElse: () => Countries(),
  //     );
  //     if (selectDefCountry.dialCode != null) {
  //       selectCountryData(selectDefCountry);
  //       setCountryNameAndCode(selectDefCountry.country.toString(), selectDefCountry.countryCode.toString(), selectDefCountry.dialCode.toString());
  //     }
  //     countryLoading = false;
  //     update();
  //     return;
  //   } else {
  //     CustomSnackBar.error(errorList: [mainResponse.message]);

  //     countryLoading = false;
  //     update();
  //     return;
  //   }
  // }

  Countries selectedCountryData = Countries();
  selectCountryData(Countries value) {
    selectedCountryData = value;
    update();
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return MyStrings.enterYourPassword_.tr;
    } else {
      if (checkPasswordStrength) {
        if (!regex.hasMatch(value)) {
          return MyStrings.invalidPassMsg.tr;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  bool noInternet = false;
  void changeInternet(bool hasInternet) {
    noInternet = false;
    initData();
    update();
  }

  void updateValidationList(String value) {
    passwordValidationRules[0].hasError = value.contains(RegExp(r'[A-Z]')) ? false : true;
    passwordValidationRules[1].hasError = value.contains(RegExp(r'[a-z]')) ? false : true;
    passwordValidationRules[2].hasError = value.contains(RegExp(r'[0-9]')) ? false : true;
    passwordValidationRules[3].hasError = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? false : true;
    passwordValidationRules[4].hasError = value.length >= 6 ? false : true;

    update();
  }

  bool hasPasswordFocus = false;
  void changePasswordFocus(bool hasFocus) {
    hasPasswordFocus = hasFocus;
    update();
  }

  //SIGN IN With Google
  bool isSocialSubmitLoading = false;
  bool isGoogle = false;
  bool isMetamask = false;
  bool isFacebook = false;
  bool isLinkedin = false;

  Future<void> signInWithGoogle() async {
    try {
      isGoogle = true;
      update();
      final gSignIn.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // throw Exception('Google Sign-In canceled by user');
        isGoogle = false;
        update();
        return;
      }
      final gSignIn.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      await socialLoginUser(provider: 'google', accessToken: googleAuth.accessToken ?? '');
    } catch (e) {
      printx(e.toString());

      CustomSnackBar.error(errorList: [e.toString()]);
    }
  }

  //SIGN IN With LinkeDin

  Future<void> signInWithLinkeDin(BuildContext context) async {
    try {
      isLinkedin = true;
      update();

      SocialiteCredentials linkedinCredential = registrationRepo.apiClient.getSocialCredentialsConfigData();
      String linkedinCredentialRedirectUrl = "${registrationRepo.apiClient.getSocialCredentialsRedirectUrl()}/linkedin";

      SignInWithLinkedIn.signIn(
        context,
        config: LinkedInConfig(clientId: linkedinCredential.linkedin?.clientId ?? '', clientSecret: linkedinCredential.linkedin?.clientSecret ?? '', scope: ['openid', 'profile', 'email'], redirectUrl: "$linkedinCredentialRedirectUrl/linkedin"),
        onGetAuthToken: (data) {
          printx('Auth token data: ${data.toJson()}');
        },
        onGetUserProfile: (token, user) async {
          printx('${token.idToken}-');
          printx('LinkedIn User: ${user.toJson()}');

          await socialLoginUser(provider: 'linkedin', accessToken: token.accessToken ?? '');
        },
        onSignInError: (error) {
          printx('Error on sign in: $error');
        },
      );
    } catch (e) {
      printx(e.toString());

      CustomSnackBar.error(errorList: [e.toString()]);
    }
  }

  //Social Login API PART

  Future socialLoginUser({
    String accessToken = '',
    String? provider,
  }) async {
    isSocialSubmitLoading = true;

    update();

    try {
      ResponseModel responseModel = await registrationRepo.socialLoginUser(
        accessToken: accessToken,
        provider: provider,
      );
      if (responseModel.statusCode == 200) {
        RegistrationResponseModel regModel = RegistrationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (regModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          remember = true;
          update();
          checkAndGotoNextStep(regModel);
        } else {
          isSocialSubmitLoading = false;
          update();
          CustomSnackBar.error(errorList: regModel.message?.error ?? [MyStrings.loginFailedTryAgain.tr]);
        }
      } else {
        isSocialSubmitLoading = false;
        update();
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    }

    isGoogle = false;
    isLinkedin = false;
    isSocialSubmitLoading = false;
    update();
  }

  bool checkUserAccessTokeSaved() {
    String token = registrationRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

    return !((token == '' || token == 'null'));
  }
}
