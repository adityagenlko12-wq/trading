import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/forget_password/verify_password_controller.dart';
import 'package:vinance/data/repo/auth/login_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/text/default_text.dart';

import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/otp_field_widget/otp_field_widget.dart';
import '../../../../components/text/header_text.dart';

class VerifyForgetPassScreen extends StatefulWidget {
  const VerifyForgetPassScreen({super.key});

  @override
  State<VerifyForgetPassScreen> createState() => _VerifyForgetPassScreenState();
}

class _VerifyForgetPassScreenState extends State<VerifyForgetPassScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    final controller = Get.put(VerifyPasswordController(loginRepo: Get.find()));

    controller.email = Get.arguments;

    super.initState();
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
        body: GetBuilder<VerifyPasswordController>(
            builder: (controller) => controller.isLoading
                ? Center(child: CircularProgressIndicator(color: MyColor.getPrimaryColor()))
                : SingleChildScrollView(
                    padding: Dimensions.screenPaddingHV,
                    physics: const BouncingScrollPhysics(),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: Dimensions.space30),
                          HeaderText(
                            text: MyStrings.enterYourOTP.tr,
                            textStyle: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                          ),
                          const SizedBox(height: 15),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 25), child: DefaultText(text: MyStrings.verifyPasswordSubText.tr.rKv({"email": controller.getFormattedMail()}), textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()))),
                          const SizedBox(height: Dimensions.space40),
                          OTPFieldWidget(
                            onChanged: (value) {
                              setState(() {
                                controller.currentText = value;
                              });
                            },
                          ),
                          const SizedBox(height: Dimensions.space25),
                          RoundedButton(
                              isLoading: controller.verifyLoading,
                              text: MyStrings.verify.tr,
                              isDisabled: controller.currentText.trim().length == 6 ? false : true,
                              press: () {
                                if (controller.currentText.length != 6) {
                                  controller.hasError = true;
                                } else {
                                  controller.verifyForgetPasswordCode(controller.currentText);
                                }
                              }),
                          const SizedBox(height: Dimensions.space25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DefaultText(text: MyStrings.didNotReceiveCode.tr, textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor())),
                              const SizedBox(width: Dimensions.space5),
                              controller.isResendLoading
                                  ? const SizedBox(
                                      height: 17,
                                      width: 17,
                                      child: CircularProgressIndicator(
                                        color: MyColor.primaryColorDark,
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: () {
                                        controller.resendForgetPassCode();
                                      },
                                      child: DefaultText(text: MyStrings.resend.tr, textStyle: regularDefault.copyWith(color: MyColor.getPrimaryColor())),
                                    )
                            ],
                          )
                        ],
                      ),
                    ))));
  }
}
