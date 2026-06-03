import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/auth/auth/registration_controller.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/screens/auth/registration/widget/validation_widget.dart';


class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final formKey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                animatedLabel: false,
                needOutlineBorder: true,
                labelText: MyStrings.firstName.tr,
                hintText: MyStrings.enterYourFirstname.tr,
                controller: controller.fNameController,
                focusNode: controller.firstNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.lastNameFocusNode,
                validator: (value) {
                  if (value!.isEmpty) {
                    return MyStrings.kFirstNameNullError.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: false,
                needOutlineBorder: true,
                labelText: MyStrings.lastName.tr,
                hintText: MyStrings.enterYourLastname.tr,
                controller: controller.lNameController,
                focusNode: controller.lastNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.emailFocusNode,
                validator: (value) {
                  if (value!.isEmpty) {
                    return MyStrings.kFirstNameNullError.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: false,
                needOutlineBorder: true,
                labelText: MyStrings.email.tr,
                hintText: MyStrings.enterYourEmail.tr,
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                nextFocus: controller.passwordFocusNode,
                textInputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourEmail.tr;
                  } else if (!MyStrings.emailValidatorRegExp.hasMatch(value ?? '')) {
                    return MyStrings.invalidEmailMsg.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space20),
              // CountryTextField(
              //   press: () {
              //     // CountryBottomSheet.bottomSheet(context, controller);
              //     CountryBottomSheetPlus.showSignUpBottomSheet(context, controller);
              //   },
              //   text: controller.countryName == null ? MyStrings.selectACountry.tr : (controller.countryName)!.tr,
              // ),
              // const SizedBox(height: Dimensions.space20),
              // Visibility(
              //   visible: controller.countryName != null,
              //   child: Form(
              //     key: phoneFormKey,
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       children: [
              //         GestureDetector(
              //           onTap: () {
              //             CountryBottomSheetPlus.showSignUpBottomSheet(context, controller);
              //           },
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             crossAxisAlignment: CrossAxisAlignment.end,
              //             children: [
              //               Column(
              //                 children: [
              //                   Container(
              //                     height: 47,
              //                     padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
              //                     alignment: Alignment.center,
              //                     decoration: BoxDecoration(
              //                       color: MyColor.getTextFieldFillColor(),
              //                       borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
              //                       border: Border.all(
              //                         color: controller.countryName == null ? MyColor.getTextFieldDisableBorder() : MyColor.getTextFieldFillColor(),
              //                         width: 0.5,
              //                       ),
              //                     ),
              //                     child: Row(
              //                       children: [
              //                         MyNetworkImageWidget(
              //                           imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", controller.countryCode.toString().toLowerCase()),
              //                           height: Dimensions.space25,
              //                           width: Dimensions.space40,
              //                         ),
              //                         horizontalSpace(Dimensions.space5),
              //                         Text(
              //                           "+${controller.mobileCode}",
              //                           style: regularDefault.copyWith(color: MyColor.getPrimaryColor()),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                   if ((controller.mobileController.text.isEmpty && (controller.isCountryCodeSpaceHide == false))) ...[verticalSpace(27)]
              //                 ],
              //               ),
              //               const SizedBox(width: Dimensions.space5 + 3),
              //               Expanded(
              //                 child: CustomTextField(
              //                   animatedLabel: true,
              //                   needOutlineBorder: true,
              //                   labelText: MyStrings.phoneNo.tr,
              //                   controller: controller.mobileController,
              //                   focusNode: controller.mobileFocusNode,
              //                   textInputType: TextInputType.phone,
              //                   inputAction: TextInputAction.next,
              //                   onChanged: (value) {
              //                     phoneFormKey.currentState!.validate();
              //                     controller.toggleHideCountryCodeErrorSpace();
              //                     // controller.
              //                   },
              //                   validator: (value) {
              //                     if (value != null && value.isEmpty) {
              //                       return MyStrings.enterYourPhoneNumber.tr;
              //                     } else {
              //                       return null;
              //                     }
              //                   },
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //         const SizedBox(height: Dimensions.space20),
              //       ],
              //     ),
              //   ),
              // ),
              Focus(
                  onFocusChange: (hasFocus) {
                    controller.changePasswordFocus(hasFocus);
                  },
                  child: CustomTextField(
                    animatedLabel: false,
                    needOutlineBorder: true,
                    isShowSuffixIcon: true,
                    isPassword: true,
                    labelText: MyStrings.password.tr,
                    hintText: MyStrings.enterYourPassword_.tr,
                    controller: controller.passwordController,
                    focusNode: controller.passwordFocusNode,
                    nextFocus: controller.confirmPasswordFocusNode,
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      if (controller.checkPasswordStrength) {
                        controller.updateValidationList(value);
                      }
                    },
                    validator: (value) {
                      return controller.validatePassword(value ?? '');
                    },
                  )),
              const SizedBox(height: Dimensions.textToTextSpace),
              Visibility(
                  visible: controller.hasPasswordFocus && controller.checkPasswordStrength,
                  child: ValidationWidget(
                    list: controller.passwordValidationRules,
                  )),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: false,
                needOutlineBorder: true,
                labelText: MyStrings.confirmPassword.tr,
                hintText: MyStrings.enterConfirmPassword.tr,
                controller: controller.cPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                inputAction: TextInputAction.done,
                isShowSuffixIcon: true,
                isPassword: true,
                onChanged: (value) {},
                validator: (value) {
                  if (controller.passwordController.text.toLowerCase() != controller.cPasswordController.text.toLowerCase()) {
                    return MyStrings.kMatchPassError.tr;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: Dimensions.space20),
              CustomTextField(
                animatedLabel: false,
                needOutlineBorder: true,
                labelText: MyStrings.referance.tr,
                hintText: MyStrings.enterYourRefarance.tr,
                controller: controller.referNameController,
                textInputType: TextInputType.text,
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: Dimensions.space25),
              Visibility(
                  visible: controller.needAgree,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                          activeColor: MyColor.primaryColor500,
                          checkColor: MyColor.getPrimaryTextColor(),
                          focusColor: MyColor.primaryColor500,
                          value: controller.agreeTC,
                          fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return MyColor.primaryColor500.withOpacity(.32);
                            }
                            return MyColor.primaryColor500.withOpacity(0.2);
                          }),
                          side: WidgetStateBorderSide.resolveWith(
                            (states) => BorderSide(
                              width: 1.0,
                              color: controller.agreeTC ? MyColor.primaryColor500 : MyColor.primaryColor500,
                            ),
                          ),
                          onChanged: (bool? value) {
                            controller.updateAgreeTC();
                          },
                        ),
                      ),
                      const SizedBox(width: Dimensions.space8),
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                controller.updateAgreeTC();
                              },
                              child: Text(MyStrings.iAgreeWith.tr, style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()))),
                          const SizedBox(width: Dimensions.space3),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteHelper.privacyScreen);
                            },
                            child: Text(MyStrings.policies.tr.toLowerCase(), style: regularDefault.copyWith(color: MyColor.getPrimaryColor(), decoration: TextDecoration.underline, decorationColor: MyColor.getPrimaryColor())),
                          ),
                          const SizedBox(width: Dimensions.space3),
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: Dimensions.space15),
              RoundedButton(
                  isLoading: controller.submitLoading,
                  text: MyStrings.signUp.tr,
                  press: () {
                    if ((phoneFormKey.currentState?.validate() ?? false) == false) {
                      controller.toggleHideCountryCodeErrorSpace();
                    }
                    if ((formKey.currentState?.validate() ?? false) == true) {
                      controller.signUpUser();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}
