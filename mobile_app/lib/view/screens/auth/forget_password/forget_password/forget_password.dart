import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/forget_password/forget_password_controller.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/default_text.dart';
import 'package:vinance/view/components/text/header_text.dart';

import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/divider/custom_spacer.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    Get.put(ForgetPasswordController(loginRepo: Get.find()));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: GetBuilder<ForgetPasswordController>(
          builder: (auth) => SingleChildScrollView(
            padding: Dimensions.screenPaddingHV,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: Dimensions.space30),
                  HeaderText(
                    text: MyStrings.forgottenPassword.tr,
                    textStyle: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                  ),
                  const SizedBox(height: 15),
                  DefaultText(text: MyStrings.forgetPasswordSubText.tr, textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor())),
                  const SizedBox(height: Dimensions.space40),
                  CustomTextField(
                      animatedLabel: false,
                      needOutlineBorder: true,
                      labelText: MyStrings.usernameOrEmail.tr,
                      hintText: MyStrings.usernameOrEmailHint.tr,
                      textInputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.done,
                      controller: auth.emailOrUsernameController,
                      onSuffixTap: () {},
                      onChanged: (value) {
                        return;
                      },
                      validator: (value) {
                        if (auth.emailOrUsernameController.text.isEmpty) {
                          return MyStrings.enterEmailOrUserName.tr;
                        } else {
                          return null;
                        }
                      }),
                  const SizedBox(height: Dimensions.space25),
                  RoundedButton(
                    isLoading: auth.submitLoading,
                    press: () {
                      if (_formKey.currentState!.validate()) {
                        auth.submitForgetPassCode();
                      }
                    },
                    text: MyStrings.next.tr,
                  ),
                  const SizedBox(height: Dimensions.space40)
                ],
              ),
            ),
          ),
        ));
  }
}
