import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/helper/string_format_helper.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../../model/auth/login/login_response_model.dart';
import '../../../model/global/response_model/response_model.dart';
import '../../../repo/biometric/biometric_repo.dart';

class BioMetricController extends GetxController {
  BioMetricController({required this.repo});
  final LocalAuthentication auth = LocalAuthentication();

  BiometricRepo repo;
  bool isLoading = false;
  TextEditingController passwordController = TextEditingController();

  bool alreadySetup = false;
  initValue() {
    alreadySetup = repo.apiClient.getFingerPrintStatus();
    checkBiometricsAvailable();
  }

  disableBiometric() {
    alreadySetup = false;
    repo.apiClient.storeFingerPrintStatus(false);
    update();
  }

  Future<void> enableFingerPrint() async {
    isBioLoading = true;
    update();
    try {
      await biometricLogin();
    } catch (e) {
      printx(e);
    } finally {
      isBioLoading = false;
    }
  }

  bool canCheckBiometricsAvailable = false;
  Future<void> checkBiometricsAvailable() async {
    passwordController.text = '';
    bool t = await auth.isDeviceSupported();

    try {
      await auth.getAvailableBiometrics().then((value) {
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
    }
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
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (authenticated == true) {
        isBioLoading = authenticated;

        String ps = passwordController.text;

        ResponseModel model = await repo.pinValidate(
          password: ps,
        );

        if (model.statusCode == 200) {
          LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(model.responseJson));
          if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
            await repo.apiClient.storeFingerPrintStatus(true);
            alreadySetup = true;
            Get.back();
            CustomSnackBar.success(successList: [MyStrings.bioEnableMsg]);
          } else {
            CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
          }
        } else {
          CustomSnackBar.error(errorList: [model.message]);
        }
      } else {
        isBioLoading = false;
        update();
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
    } finally {
      isBioLoading = false;
    }
    update();
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
}
