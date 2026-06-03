import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart' as gSignIn;
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/model/auth/login/login_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/packages/signin_with_linkdin/signin_with_linkedin.dart';
import '../../../model/general_setting/general_setting_response_model.dart';

class LoginController extends GetxController {
  LoginRepo loginRepo;
  LoginController({required this.loginRepo});

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var firebaseUser = FirebaseAuth.instance.currentUser.obs; // Observe the user
  final gSignIn.GoogleSignIn googleSignIn = gSignIn.GoogleSignIn();
  String? email;
  String? password;

  List<String> errors = [];
  bool remember = true;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = firebaseAuth.currentUser;
    firebaseAuth.authStateChanges().listen((user) {
      firebaseUser.value = user;
    });
  }

  void forgetPassword() {
    Get.toNamed(RouteHelper.forgotPasswordScreen);
  }

  void checkAndGotoNextStep(LoginResponseModel responseModel) async {
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true); // always will be true

    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, responseModel.data?.accessToken ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, responseModel.data?.tokenType ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');
    await loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');

    await loginRepo.sendUserToken();

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete == '0' ? true : false;
    if (needSmsVerification == false && needEmailVerification == false && isTwoFactorEnable == false) {
      if (isProfileCompleteEnable) {
        Get.offAndToNamed(RouteHelper.profileCompleteScreen);
      } else {
        await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);
        clearTextField();
        Get.offAndToNamed(RouteHelper.dashboardScreen);
      }
    } else if (needSmsVerification == true && needEmailVerification == true && isTwoFactorEnable == true) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needSmsVerification == true && needEmailVerification == true) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [true, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen, arguments: [isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen, arguments: [false, isProfileCompleteEnable, isTwoFactorEnable]);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen, arguments: isProfileCompleteEnable);
    }
  }

  bool isSubmitLoading = false;
  void loginUser() async {
    isSubmitLoading = true;
    update();

    ResponseModel model = await loginRepo.loginUser(emailController.text.toString(), passwordController.text.toString());

    if (model.statusCode == 200) {
      LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(model.responseJson));
      if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        checkAndGotoNextStep(loginModel);
      } else {
        CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
      }
    } else {
      CustomSnackBar.error(errorList: [model.message]);
    }

    isSubmitLoading = false;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';

    update();
  }

  bool isDisable = false;
  bool isPermanentlyLocked = false;
  bool isBioLoading = false;

  Future<void> biometricLogin() async {
    bool authenticated = false;
    isDisable = false;
    isPermanentlyLocked = false;
    countdownSeconds = 30;
    update();

    try {
      authenticated = await bioLocalAuth.authenticate(
        localizedReason: MyStrings.fingerPrintScanMsg.tr,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      // .timeout(const Duration(seconds: 10));
      if (authenticated == true) {
        isBioLoading = true;
        update();
        await loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true);
        Get.offAllNamed(RouteHelper.dashboardScreen);
      }
    } on PlatformException catch (e) {
      if (e.code == "PermanentlyLockedOut") {
        // startCountdown();
        isDisable = true;
        isPermanentlyLocked = true;
        update();
      } else if (e.code == "LockedOut") {
        isDisable = true;
        update();
        startCountdown();
      }
      update();
    } finally {
      isBioLoading = false;
      update();
    }
  }

  final LocalAuthentication bioLocalAuth = LocalAuthentication();
  bool canCheckBiometricsAvailable = false;
  Future<void> checkBiometricsAvailable() async {
    bool t = await bioLocalAuth.isDeviceSupported();

    try {
      await bioLocalAuth.getAvailableBiometrics().then((value) {
        for (var element in value) {
          if ((element == BiometricType.fingerprint || element == BiometricType.weak || element == BiometricType.strong) && t == true) {
            canCheckBiometricsAvailable = true;
            update();
          } else {
            canCheckBiometricsAvailable = false;
            update();
          }
        }
      });
    } catch (e) {
      canCheckBiometricsAvailable = false;
      update();
      if (kDebugMode) {
        printx(e);
      }
    }
  }

  int countdownSeconds = 30;
  late Timer countdownTimer;

  void startCountdown() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds > 0) {
        countdownSeconds--;
        update();
      } else {
        timer.cancel(); // Stop the timer when countdown reaches 0
        countdownSeconds = 0;
        isDisable = false;
        update();
      }
    });
  }

  //SIGN IN With Google
  bool isSocialSubmitLoading = false;
  bool isGoogle = false;
  bool isMetamask = false;
  bool isFacebook = false;
  bool isLinkedin = false;

  Future<void> signInWithGoogle() async {
    try {
      isLinkedin = false;
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
      isGoogle = false;
      isLinkedin = true;
      update();

      SocialiteCredentials linkedinCredential = loginRepo.apiClient.getSocialCredentialsConfigData();
      String linkedinCredentialRedirectUrl = "${loginRepo.apiClient.getSocialCredentialsRedirectUrl()}/linkedin";

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
      ResponseModel responseModel = await loginRepo.socialLoginUser(
        accessToken: accessToken,
        provider: provider,
      );
      if (responseModel.statusCode == 200) {
        LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          remember = true;
          update();
          checkAndGotoNextStep(loginModel);
        } else {
          isSocialSubmitLoading = false;
          update();
          CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain.tr]);
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

  bool checkUserAccessTokenSaved() {
    String token = loginRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.accessTokenKey) ?? '';

    return !((token == '' || token == 'null'));
  }
}
