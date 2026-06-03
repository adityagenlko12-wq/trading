import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:web3modal_flutter/models/listing.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import '../../../../../core/helper/string_format_helper.dart';
import '../../../../../core/route/route.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../environment.dart';
import '../../../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../../../model/auth/sign_up_model/registration_response_model.dart';
import '../../../../model/global/response_model/response_model.dart';
import '../../../../repo/auth/signup_repo.dart';
import '../../../social_auth/get_message_for_metamsk_model.dart';
import 'utils/crypto/eip155.dart';

class MetaMaskAuthRegController extends GetxController with WidgetsBindingObserver {
  RegistrationRepo registrationRepo;
  MetaMaskAuthRegController({required this.registrationRepo});
  bool isInitializing = true;
  late W3MService w3mService;
  late W3MWalletInfo w3mWalletInfo;
  late W3MChainInfo w3mChainInfo;
  ModalError? walletErrorHandler;

  void initialize() async {
    isInitializing = true;

    update();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        w3mService = W3MService(
          projectId: Environment.walletConnectProjectID,
          logLevel: LogLevel.debug,
          metadata: const PairingMetadata(
            name: Environment.appName,
            description: Environment.appSubTitle,
            url: 'https://www.walletconnect.com/',
            icons: ['https://walletconnect.com/walletconnect-logo.png'],
            redirect: Redirect(
              native: 'flutterdapp://',
              universal: 'https://www.walletconnect.com',
            ),
          ),
        );
        await w3mService.init();

        w3mWalletInfo = W3MWalletInfo(
            listing: Listing(
                id: "c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96",
                name: "MetaMask",
                homepage: "https://metamask.io/",
                imageId: "5195e9db-94d8-4579-6f11-ef553be95100",
                order: 10,
                mobileLink: "metamask://",
                appStore: "https://apps.apple.com/us/app/metamask/id1438144202",
                playStore: "https://play.google.com/store/apps/details?id=io.metamask",
                rdns: "io.metamask",
                injected: [Injected(namespace: "eip155", injectedId: "isMetaMask")]),
            installed: true,
            recent: true);

        w3mChainInfo = W3MChainInfo(
          chainName: "Gnosis",
          chainId: "0x64",
          namespace: "gnosis:0x64",
          tokenName: "xDAI",
          rpcUrl: "https://rpc.ankr.com/gnosis",
          blockExplorer: W3MBlockExplorer(
            name: Environment.appSubTitle,
            url: Environment.appWebUrl,
          ),
        );

        w3mService.addListener(_serviceListener);

        w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
        w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);

        w3mService.onModalConnect.subscribe(_onSessionConnect);
        w3mService.onModalDisconnect.subscribe(_onSessionDelete);
        w3mService.onModalError.subscribe(_onWalletConnectedError);
      } catch (e) {
        printx(e.toString());
      }

      isInitializing = false;

      update();
    });
  }

  void _serviceListener() async {
    update();
  }

  void _onSessionEvent(SessionEvent? args) {
    printx('[$runtimeType] _onSessionEvent $args');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    printx('[$runtimeType] _onSessionUpdate $args');
  }

  bool _messageSent = false; // Flag to track if the message has been sent

  void _onSessionConnect(ModalConnect? args) async {
    printx('[$runtimeType] _onSessionConnect $args');

    if (!_messageSent && args?.session.acknowledged == true) {
      var address = "${w3mService.session?.address?.toLowerCase()}";
      if (address.toString() != 'null') {
        await getMetaMaskLoginMessage(address).whenComplete(() {});
        _messageSent = true; // Set the flag to true after sending the message
      }
    }
  }

  void _onSessionDelete(ModalDisconnect? args) {
    printx('[$runtimeType] _onSessionDelete $args');
  }

  void _onWalletConnectedError(ModalError? args) {
    walletErrorHandler = args;

    printx("Error1000");
    printx('[$runtimeType] _onWalletConnectedError $args');
  }

  bool isLoading = false;

  @override
  void onInit() {
    initialize();
    super.onInit();
  }

  // @override
  // void onReady() {
  //   initialize();
  //   super.onReady();
  // }

  @override
  void onClose() {
    printx("close all reg metamask");
    try {
      w3mService.disconnect();
      w3mService.dispose();
    } catch (e) {
      printx(e);
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final isOpen = w3mService.isOpen;
      final isConnected = w3mService.isConnected;
      if (isOpen && isConnected) {
        printx("Close Pop up");
      }
    }
  }

  Future<dynamic> personalSignFortSignatureVerification({
    required W3MService w3mService,
    required String topic,
    required String chainId,
    required String address,
    required String message,
  }) async {
    w3mService.launchConnectedWallet();
    return await w3mService.request(
      topic: topic,
      chainId: chainId,
      request: SessionRequestParams(
        method: EIP155UIMethods.personalSign.name,
        params: [message, address],
      ),
    );
  }

  //Reg
  //SIGN Up With Metamask
  bool isMetaMaskSubmitLoading = false;

  Future<void> signInWithMetamask(BuildContext context) async {
    try {
      w3mService.disconnect();
      if (w3mService.isConnected) {
        try {
          var address = "${w3mService.session?.address?.toLowerCase()}";
          printx("Wallet Already Connected");
          if (address.toString() != 'null') {
            await getMetaMaskLoginMessage(address);
          }
        } catch (e) {
          printx("connected error");
          printx(e.toString());
          isMetaMaskSubmitLoading = false;
          update();
        }
      } else {
        clearMetamaskOldData(disconnected: false);
        await w3mService.selectChain(w3mChainInfo);
        w3mService.selectWallet(w3mWalletInfo);
        update();
        printx("Wallet Connecting");
        await w3mService.connectSelectedWallet();
      }
    } catch (e) {
      printx("Error catch: ${e.toString()}");
      isMetaMaskSubmitLoading = false;
      update();
    } finally {
      isMetaMaskSubmitLoading = false;
      update();
    }
  }

  clearMetamaskOldData({bool disconnected = true}) {
    //reset connection and established new connection
    walletErrorHandler = null;
    _messageSent = false;
    walletAddressData = '';
    messageData = '';
    signatureCodeData = '';
    if (disconnected) {
      w3mService.disconnect();
    }
  }

  MetamaskGetMessageResponseModel messageResponseModelData = MetamaskGetMessageResponseModel();
  String walletAddressData = '';
  String messageData = '';
  String signatureCodeData = '';
  Future getMetaMaskLoginMessage(String walletAddress) async {
    walletAddressData = walletAddress;
    isMetaMaskSubmitLoading = false;

    update();
    try {
      ResponseModel model = await registrationRepo.getMetaMaskLoginMessage(walletAddress);

      if (model.statusCode == 200) {
        MetamaskGetMessageResponseModel messageResponseModel = MetamaskGetMessageResponseModel.fromJson(jsonDecode(model.responseJson));
        if (messageResponseModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          messageResponseModelData = messageResponseModel;
          messageData = messageResponseModel.data?.message ?? '';
          update();
        } else {
          CustomSnackBar.error(errorList: messageResponseModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
        }
      } else {
        CustomSnackBar.error(errorList: [model.message]);
      }
    } catch (e) {
      printx(e.toString());
      isMetaMaskSubmitLoading = false;
      update();
    } finally {
      isMetaMaskSubmitLoading = false;
      update();
    }
  }

  bool remember = true;

  Future getSignatureCodeFromMetamask({required String message}) async {
    //Verify Message
    printx("Signature");
    if (walletAddressData.toString() != 'null') {
      String signatureCode = await personalSignFortSignatureVerification(
        address: walletAddressData,
        w3mService: w3mService,
        topic: w3mService.session?.topic ?? '',
        chainId: 'eip155:1',
        message: message,
      );

      printx("Signature Code");
      printx("$signatureCode ");
      signatureCodeData = signatureCode;
      update();
      verifyMetaMakSignatureCode(messageResponseModelData, signatureCode);
    }
  }

  Future verifyMetaMakSignatureCode(MetamaskGetMessageResponseModel metamaskGetMessageResponseModel, String signature) async {
    isMetaMaskSubmitLoading = true;
    update();
    try {
      ResponseModel responseModel = await registrationRepo.verifyMetaMaskLoginSignature(
        walletAddress: metamaskGetMessageResponseModel.data?.wallet ?? '',
        message: metamaskGetMessageResponseModel.data?.message ?? '',
        signature: signature,
        nonce: metamaskGetMessageResponseModel.data?.nonce ?? '',
      );
      if (responseModel.statusCode == 200) {
        RegistrationResponseModel regModel = RegistrationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (regModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          remember = true;
          update();
          checkAndGotoNextStep(regModel);
          //close metamask
          w3mService.disconnect();
          w3mService.dispose();
        } else {
          isMetaMaskSubmitLoading = false;
          update();
          CustomSnackBar.error(errorList: regModel.message?.error ?? [MyStrings.loginFailedTryAgain.tr]);
        }
      } else {
        isMetaMaskSubmitLoading = false;
        update();
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
      isMetaMaskSubmitLoading = false;
      update();
    } finally {
      printx("Finally Done");
      isMetaMaskSubmitLoading = false;
      update();
    }
  }

  void checkAndGotoNextStep(RegistrationResponseModel responseModel) async {
    bool needEmailVerification = responseModel.data?.user?.ev == "1" ? false : true;
    bool needSmsVerification = responseModel.data?.user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = responseModel.data?.user?.tv == '1' ? false : true;

    await registrationRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, true);

    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userIdKey, responseModel.data?.user?.id.toString() ?? '-1');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, responseModel.data?.accessToken ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenType, responseModel.data?.tokenType ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, responseModel.data?.user?.email ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, responseModel.data?.user?.mobile ?? '');
    await registrationRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, responseModel.data?.user?.username ?? '');

    bool isProfileCompleteEnable = responseModel.data?.user?.profileComplete == '0' ? true : false;

    if (needSmsVerification == false && needEmailVerification == false && isTwoFactorEnable == false) {
      if (isProfileCompleteEnable) {
        Get.offAndToNamed(RouteHelper.profileCompleteScreen);
      } else {
        await registrationRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.firstTimeOnAppKey, false);

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

  //Download app

  Future<void> launchMetaMaskUrl() async {
    String appStoreUrl = "https://apps.apple.com/us/app/metamask/id1438144202";
    String playStoreUrl = "https://play.google.com/store/apps/details?id=io.metamask";

    if (Platform.isIOS) {
      // Check if the current platform is iOS
      if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
        await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch MetaMask store URL';
      }
    } else if (Platform.isAndroid) {
      // Check if the current platform is Android
      if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
        await launchUrl(Uri.parse(playStoreUrl), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch MetaMask store URL';
      }
    } else {
      throw 'Unsupported platform';
    }
  }
}
