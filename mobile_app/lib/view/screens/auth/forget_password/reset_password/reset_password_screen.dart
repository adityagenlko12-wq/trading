import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/forget_password/reset_password_controller.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/default_text.dart';
import 'package:vinance/view/components/text/header_text.dart';
import 'package:vinance/view/components/will_pop_widget.dart';
import 'package:vinance/view/screens/auth/registration/widget/validation_widget.dart';

import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/divider/custom_spacer.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    final controller = Get.put(ResetPasswordController(loginRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.email = Get.arguments[0];
      controller.code = Get.arguments[1];
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: RouteHelper.authenticationScreen,
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          showCrossIconInBackBtn: true,
          isTitleCenter: true,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
          titleStyle: boldOverLarge.copyWith(fontSize: Dimensions.fontOverLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: GetBuilder<ResetPasswordController>(
          builder: (controller) => SingleChildScrollView(
            padding: Dimensions.screenPaddingHV,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: Dimensions.space30),
                  HeaderText(
                    text: MyStrings.resetPassword.tr,
                    textStyle: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                  ),
                  const SizedBox(height: Dimensions.space15),
                  DefaultText(text: MyStrings.createNewPassWordText.tr, textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor())),
                  const SizedBox(height: Dimensions.space40),
                  Focus(
                    onFocusChange: (hasFocus) {
                      controller.changePasswordFocus(hasFocus);
                    },
                    child: CustomTextField(
                        animatedLabel: false,
                        needOutlineBorder: true,
                        focusNode: controller.passwordFocusNode,
                        nextFocus: controller.confirmPasswordFocusNode,
                        labelText: MyStrings.password,
                        hintText: MyStrings.newPasswordHint.tr,
                        isShowSuffixIcon: true,
                        isPassword: true,
                        textInputType: TextInputType.text,
                        inputAction: TextInputAction.next,
                        controller: controller.passController,
                        validator: (value) {
                          return controller.validatePassword(value);
                        },
                        onChanged: (value) {
                          if (controller.checkPasswordStrength) {
                            controller.updateValidationList(value);
                          }
                          return;
                        }),
                  ),
                  Visibility(
                      visible: controller.hasPasswordFocus && controller.checkPasswordStrength,
                      child: ValidationWidget(
                        list: controller.passwordValidationRules,
                        fromReset: true,
                      )),
                  const SizedBox(height: Dimensions.space15),
                  CustomTextField(
                    animatedLabel: false,
                    needOutlineBorder: true,
                    inputAction: TextInputAction.done,
                    isPassword: true,
                    labelText: MyStrings.confirmPassword.tr,
                    hintText: MyStrings.confirmYourPassword.tr,
                 
                    isShowSuffixIcon: true,
                    controller: controller.confirmPassController,
                    onChanged: (value) {
                      return;
                    },
                    validator: (value) {
                      if (controller.passController.text.toLowerCase() != controller.confirmPassController.text.toLowerCase()) {
                        return MyStrings.kMatchPassError.tr;
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.space35),
                  
                   RoundedButton(isLoading: controller.submitLoading,
                          text: MyStrings.submit.tr,
                          press: () {
                            if (formKey.currentState!.validate()) {
                              controller.resetPassword();
                            }
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
