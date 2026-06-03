import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/auth/login_controller.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/components/image/my_local_image_widget.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/default_text.dart';
import '../../../../data/controller/auth/auth/metamask/metamask_login_controller.dart';
import '../../../../environment.dart';
import '../../../components/custom_loader/custom_loader.dart';
import '../../../components/divider/custom_divider_with_center_text.dart';
import '../social_auth/widgets/social_auth_button-widget.dart';
import 'metamask/meta_login_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    Get.put(MetaMaskAuthLoginController(loginRepo: Get.find()));
    Get.put(LoginController(loginRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<LoginController>().remember = false;
      Get.find<LoginController>().checkBiometricsAvailable();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: GetBuilder<LoginController>(
        builder: (controller) => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              verticalSpace(Dimensions.space25),
              //Social Auth

              Padding(
                padding: const EdgeInsets.all(Dimensions.space3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (Environment.enableLoginWithMetamask && controller.loginRepo.apiClient.getMetaMetamaskEnableStatus() == true) ...[
                      Expanded(
                        child: SocialAuthButtonWidget(
                          isLoading: Get.find<MetaMaskAuthLoginController>().isMetaMaskSubmitLoading,
                          assetImage: MyIcons.metaMaskIcon,
                          text: MyStrings.metaMask.tr,
                          showText: !controller.loginRepo.apiClient.getSocialCredentialsEnabledAll(),
                          onPressed: () {
                            CustomBottomSheetPlus(
                              child: const ConnectMetamaskLoginBottomSheet(),
                              isNeedPadding: false,
                              bgColor: MyColor.getScreenBgSecondaryColor(),
                            ).show(context);
                          },
                        ),
                      ),
                    ],
                    if (controller.loginRepo.apiClient.getSocialCredentialsConfigData().google?.status == '1') ...[
                      horizontalSpace(Dimensions.space5),
                      Expanded(
                        child: SocialAuthButtonWidget(
                          isLoading: controller.isSocialSubmitLoading && controller.isGoogle,
                          assetImage: MyIcons.googleIcon,
                          text: MyStrings.google.tr,
                          showText: !controller.loginRepo.apiClient.getSocialCredentialsEnabledAll(),
                          onPressed: () {
                            controller.signInWithGoogle();
                          },
                        ),
                      ),
                    ],
                    if (controller.loginRepo.apiClient.getSocialCredentialsConfigData().linkedin?.status == '1') ...[
                      horizontalSpace(Dimensions.space5),
                      Expanded(
                        child: SocialAuthButtonWidget(
                          isLoading: controller.isSocialSubmitLoading && controller.isLinkedin,
                          assetImage: MyIcons.linkeDinIcon,
                          text: MyStrings.linkedin.tr,
                          showText: !controller.loginRepo.apiClient.getSocialCredentialsEnabledAll(),
                          onPressed: () {
                            controller.signInWithLinkeDin(context);
                          },
                        ),
                      )
                    ],
                  ],
                ),
              ),

              CustomDividerWithCenterText(
                text: MyStrings.orSignInWith.tr,
                height: 2,
              ),
              //General Auth
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomTextField(
                      animatedLabel: false,
                      needOutlineBorder: true,
                      controller: controller.emailController,
                      labelText: MyStrings.usernameOrEmail.tr,
                      hintText: MyStrings.enterYourUsername,
                      onChanged: (value) {},
                      focusNode: controller.emailFocusNode,
                      nextFocus: controller.passwordFocusNode,
                      textInputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.next,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return MyStrings.fieldErrorMsg.tr;
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.space20),
                    CustomTextField(
                      animatedLabel: false,
                      needOutlineBorder: true,
                      labelText: MyStrings.password.tr,
                      hintText: MyStrings.enterYourPassword_.tr,
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      onChanged: (value) {},
                      isShowSuffixIcon: true,
                      isPassword: true,
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.done,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return MyStrings.fieldErrorMsg.tr;
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.clearTextField();
                            Get.toNamed(RouteHelper.forgotPasswordScreen);
                          },
                          child: DefaultText(
                            text: MyStrings.forgotPassword.tr,
                            textStyle: regularLarge.copyWith(color: MyColor.colorRed),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 25),
                    RoundedButton(
                        isLoading: controller.isSubmitLoading,
                        text: MyStrings.signIn.tr,
                        press: () {
                          if (formKey.currentState!.validate()) {
                            controller.loginUser();
                          }
                        }),
                    const SizedBox(height: 35),
                    if (controller.checkUserAccessTokenSaved() && controller.canCheckBiometricsAvailable && controller.loginRepo.apiClient.getFingerPrintStatus()) ...[
                      Column(
                        children: [
                          verticalSpace(Dimensions.space25),
                          GestureDetector(
                            onTap: () async {
                              if (controller.isDisable == false) {
                                controller.biometricLogin();
                              }
                            },
                            child: Center(
                              child: controller.isBioLoading
                                  ? const CustomLoader(
                                      isPagination: false,
                                    )
                                  : const MyLocalImageWidget(
                                      imagePath: MyIcons.fingerPrintIcon,
                                      width: Dimensions.space50,
                                    ),
                            ),
                          ),
                          verticalSpace(Dimensions.space10),
                          Text(
                            MyStrings.useFingerprintInstead.tr,
                            style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          )
                        ],
                      ),
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
