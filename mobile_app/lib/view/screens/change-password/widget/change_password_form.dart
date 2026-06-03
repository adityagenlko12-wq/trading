import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/account/change_password_controller.dart';
import '../../../components/buttons/rounded_button.dart';
import '../../../components/text-form-field/custom_text_field.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
        builder: (controller) => Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    animatedLabel: false,
                    needOutlineBorder: true,
                    hintText: MyStrings.enterCurrentPass.tr,
                    labelText: MyStrings.currentPassword.tr,
                    onChanged: (value) {
                      return;
                    },
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return MyStrings.enterCurrentPass.tr;
                      } else {
                        return null;
                      }
                    },
                    controller: controller.currentPassController,
                    isShowSuffixIcon: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: Dimensions.space20),
                  CustomTextField(
                    animatedLabel: false,
                    needOutlineBorder: true,
                    hintText: MyStrings.enterNewPass.tr,
                    labelText: MyStrings.newPassword.tr,
                    onChanged: (value) {
                      return;
                    },
                    validator: (value) {
                      if (value.toString().isEmpty) {
                        return MyStrings.enterNewPass.tr;
                      } else {
                        return null;
                      }
                    },
                    controller: controller.passController,
                    isShowSuffixIcon: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: Dimensions.space20),
                  CustomTextField(
                    animatedLabel: false,
                    needOutlineBorder: true,
                    hintText: MyStrings.enterConfirmPassword.tr,
                    labelText: MyStrings.confirmPassword.tr,
                    onChanged: (value) {
                      return;
                    },
                    validator: (value) {
                      if (controller.confirmPassController.text != controller.passController.text) {
                        return MyStrings.kMatchPassError.tr;
                      } else {
                        return null;
                      }
                    },
                    controller: controller.confirmPassController,
                    isShowSuffixIcon: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: Dimensions.space25),
                  RoundedButton(
                    isLoading: controller.submitLoading,
                    horizontalPadding: Dimensions.space10,
                    verticalPadding: Dimensions.space15,
                    text: MyStrings.updateProfile.tr,
                    press: () {
                      if (formKey.currentState!.validate()) {
                        controller.changePassword();
                      }
                    },
                    cornerRadius: 8,
                    isOutlined: false,
                    color: MyColor.getPrimaryButtonColor(),
                  ),
                ],
              ),
            ));
  }
}
