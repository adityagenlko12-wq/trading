import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../core/utils/style.dart';
import '../../../../data/controller/account/profile_controller.dart';
import '../../../../data/controller/auth/auth/two_factor_controller.dart';
import '../../../../data/repo/account/profile_repo.dart';
import '../../../../data/repo/auth/two_factor_repo.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/divider/custom_divider.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/snack_bar/show_custom_snackbar.dart';
import '../../../components/text/small_text.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(TwoFactorRepo(apiClient: Get.find()));
    final controller = Get.put(TwoFactorController(repo: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final pcontroller = Get.put(ProfileController(profileRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pcontroller.loadProfileInfo();
      controller.get2FaCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boxSize = screenSize.width < 400
        ? const Size(42, 42)
        : screenSize.width < 600
            ? const Size(50, 50)
            : const Size(52, 52);
    return GetBuilder<TwoFactorController>(builder: (controller) {
      return GetBuilder<ProfileController>(builder: (pcontroller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: MyStrings.twoFactorAuth.tr,
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: controller.isLoading || pcontroller.isLoading
              ? const CustomLoader()
              : pcontroller.user2faIsOne == false
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                              decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      MyStrings.addYourAccount.tr,
                                      style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                    ),
                                  ),
                                  CustomDivider(
                                    color: MyColor.getBorderColor(),
                                  ),
                                  Center(
                                    child: Text(MyStrings.useQRCODETips.tr, style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                  ),
                                  const SizedBox(
                                    height: Dimensions.space12,
                                  ),
                                  if (controller.twoFactorCodeModel.data?.qrCodeUrl != null) ...[
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MyColor.transparentColor,
                                          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                                        ),
                                        child: Image.network(controller.twoFactorCodeModel.data?.qrCodeUrl ?? '', width: 220, height: 220, errorBuilder: (ctx, object, trx) {
                                          return Image.asset(
                                            MyImages.placeHolderImage,
                                            fit: BoxFit.cover,
                                            width: 220,
                                            height: 220,
                                          );
                                        }),
                                      ),
                                    ),

                                    //COPY

                                    Text(MyStrings.setupKey.tr, style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.8),
                                        child: DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: MyColor.colorGrey.withOpacity(0.5),
                                          radius: const Radius.circular(Dimensions.cardRadius1),
                                          child: Container(
                                            decoration: BoxDecoration(color: MyColor.colorWhite, borderRadius: BorderRadius.circular(Dimensions.cardRadius1 - 1)),
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(Dimensions.space15),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${controller.twoFactorCodeModel.data?.secret}",
                                                    style: boldExtraLarge.copyWith(
                                                      fontSize: Dimensions.fontMediumLarge,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Clipboard.setData(ClipboardData(
                                                        text: "${controller.twoFactorCodeModel.data?.secret}",
                                                      )).then((_) {
                                                        CustomSnackBar.success(successList: [MyStrings.copiedToClipBoard.tr], duration: 2);
                                                      });
                                                    },
                                                    child: FittedBox(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(Dimensions.space3),
                                                        child: Icon(
                                                          Icons.copy,
                                                          color: MyColor.colorGrey.withOpacity(0.5),
                                                          size: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.space12,
                                    ),

                                    Center(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: MyStrings.useQRCODETips2.tr, style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor())),
                                            TextSpan(
                                                text: ' ${MyStrings.download.tr}',
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    final Uri url = Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en");

                                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                                      throw Exception('Could not launch $url');
                                                    }
                                                  },
                                                style: boldExtraLarge.copyWith(color: MyColor.colorRed)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),

                            // enable

                            Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                                decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(10)),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Center(
                                    child: Text(
                                      MyStrings.enable2Fa.tr,
                                      style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                    ),
                                  ),
                                  const CustomDivider(),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .07),
                                    child: SmallText(text: MyStrings.twoFactorMsg.tr, maxLine: 3, textAlign: TextAlign.center, textStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor())),
                                  ),
                                  const SizedBox(height: Dimensions.space50),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space30),
                                    child: PinCodeTextField(
                                      appContext: context,
                                      pastedTextStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                      length: 6,
                                      textStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                      obscureText: false,
                                      obscuringCharacter: '*',
                                      blinkWhenObscuring: false,
                                      animationType: AnimationType.fade,
                                      pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.box,
                                          borderWidth: 1,
                                          borderRadius: BorderRadius.circular(5),
                                          fieldHeight: 40,
                                          fieldWidth: 40,
                                          inactiveColor: MyColor.getTextFieldDisableBorder(),
                                          inactiveFillColor: MyColor.getTransparentColor(),
                                          activeFillColor: MyColor.getTransparentColor(),
                                          activeColor: MyColor.primaryColor,
                                          selectedFillColor: MyColor.getTransparentColor(),
                                          selectedColor: MyColor.primaryColor),
                                      cursorColor: MyColor.colorWhite,
                                      animationDuration: const Duration(milliseconds: 100),
                                      enableActiveFill: true,
                                      keyboardType: TextInputType.number,
                                      beforeTextPaste: (text) {
                                        return true;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          controller.currentText = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.space30),
                                  RoundedButton(
                                    isLoading: controller.submitLoading,
                                    press: () {
                                      controller.enable2fa(controller.twoFactorCodeModel.data?.secret ?? '', controller.currentText);
                                    },
                                    text: MyStrings.submit.tr,
                                  ),
                                  const SizedBox(height: Dimensions.space30),
                                ])),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                            decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(10)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Center(
                                child: Text(
                                  MyStrings.disable2Fa.tr,
                                  style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                              ),
                              const CustomDivider(),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .07),
                                child: SmallText(text: MyStrings.twoFactorMsg.tr, maxLine: 3, textAlign: TextAlign.center, textStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor())),
                              ),
                              const SizedBox(height: Dimensions.space50),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space30),
                                child: PinCodeTextField(
                                  appContext: context,
                                  pastedTextStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  length: 6,
                                  textStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  obscureText: false,
                                  obscuringCharacter: '*',
                                  blinkWhenObscuring: false,
                                  animationType: AnimationType.fade,
                                  pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.box,
                                      borderWidth: 1,
                                      borderRadius: BorderRadius.circular(5),
                                      fieldHeight: boxSize.width,
                                      fieldWidth: boxSize.width,
                                      inactiveColor: MyColor.getTextFieldDisableBorder(),
                                      inactiveFillColor: MyColor.getTransparentColor(),
                                      activeFillColor: MyColor.getTransparentColor(),
                                      activeColor: MyColor.primaryColor,
                                      selectedFillColor: MyColor.getTransparentColor(),
                                      selectedColor: MyColor.primaryColor),
                                  cursorColor: MyColor.colorWhite,
                                  animationDuration: const Duration(milliseconds: 100),
                                  enableActiveFill: true,
                                  keyboardType: TextInputType.number,
                                  beforeTextPaste: (text) {
                                    return true;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      controller.currentText = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: Dimensions.space30),
                              RoundedButton(
                                isLoading: controller.submitLoading,
                                press: () {
                                  controller.disable2fa(controller.currentText);
                                },
                                text: MyStrings.submit.tr,
                              ),
                              const SizedBox(height: Dimensions.space30),
                            ])),
                      ],
                    ),
        );
      });
    });
  }
}
