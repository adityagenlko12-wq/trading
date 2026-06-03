import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/account/profile_complete_controller.dart';
import 'package:vinance/data/repo/account/profile_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/shimmer/home_page_market_list_data_shimmer.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/will_pop_widget.dart';

import '../../../../core/route/route.dart';
import '../../../../core/utils/style.dart';
import '../../../../core/utils/url_container.dart';
import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/image/my_network_image_widget.dart';
import '../../../components/text/default_text.dart';
import '../../../components/text/header_text.dart';
import '../registration/widget/country_bottom_sheet_plus.dart';
import '../registration/widget/country_text_field.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    var controller = Get.put(ProfileCompleteController(profileRepo: Get.find()));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialData();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  final phoneFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: GetBuilder<ProfileCompleteController>(builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            appBar: AppMainAppBar(
              isTitleCenter: true,
              isProfileCompleted: true,
              bgColor: MyColor.transparentColor,
              titleStyle: boldOverLarge.copyWith(fontSize: Dimensions.fontOverLarge, color: MyColor.getPrimaryTextColor()),
              leadingWidgetOnTap: () {
                controller.profileRepo.apiClient.clearOldAuthData();
                Get.offAllNamed(RouteHelper.authenticationScreen);
              },
              actions: [
                horizontalSpace(Dimensions.space10),
              ],
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: Dimensions.screenPaddingHV,
              child: controller.isLoading
                  ? const HomePageMarketListDataShimmer(length: 10)
                  : Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: Dimensions.space20),
                                HeaderText(text: MyStrings.completeYourProfile.tr, textStyle: semiBoldOverLarge.copyWith(color: MyColor.getPrimaryTextColor())),
                                const SizedBox(height: 15),
                                DefaultText(text: MyStrings.completeYourProfileSubText.tr, textAlign: TextAlign.center, textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor())),
                                const SizedBox(height: Dimensions.space40),
                                if (controller.userNameData == '') ...[
                                  CustomTextField(
                                    animatedLabel: false,
                                    needOutlineBorder: true,
                                    labelText: MyStrings.username.tr,
                                    hintText: "${MyStrings.enterYour.tr} ${MyStrings.username.tr.toLowerCase()}",
                                    textInputType: TextInputType.text,
                                    inputAction: TextInputAction.next,
                                    focusNode: controller.userNameFocusNode,
                                    controller: controller.userNameController,
                                    nextFocus: controller.lastNameFocusNode,
                                    onChanged: (value) {
                                      return;
                                    },
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return MyStrings.kUserNameNullError.tr;
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                            if (controller.firstNameData == '') ...[
                              const SizedBox(height: Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                labelText: MyStrings.firstName.tr,
                                hintText: "${MyStrings.enterYour.tr} ${MyStrings.firstName.tr.toLowerCase()}",
                                textInputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                focusNode: controller.firstNameFocusNode,
                                controller: controller.firstNameController,
                                nextFocus: controller.lastNameFocusNode,
                                onChanged: (value) {
                                  return;
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.kFirstNameNullError.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                            if (controller.lastNameData == '') ...[
                              const SizedBox(height: Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                labelText: MyStrings.lastName.tr,
                                hintText: "${MyStrings.enterYour.tr} ${MyStrings.lastName.tr.toLowerCase()}",
                                textInputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                focusNode: controller.lastNameFocusNode,
                                controller: controller.lastNameController,
                                nextFocus: controller.addressFocusNode,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.kLastNameNullError.tr;
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  return;
                                },
                              ),
                            ],
                            if (controller.emailData == '') ...[
                              const SizedBox(height: Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                labelText: MyStrings.email.tr,
                                hintText: MyStrings.enterYourEmail.tr,
                                controller: controller.emailController,
                                focusNode: controller.emailFocusNode,
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
                            ],
                            const SizedBox(height: Dimensions.space20),
                            CountryTextField(
                              press: () {
                                CountryBottomSheetPlus.showProfileCompleteBottomSheet(context, controller);
                              },
                              text: controller.countryName == null ? MyStrings.selectACountry.tr : (controller.countryName)!.tr,
                            ),
                            const SizedBox(height: Dimensions.space20),
                            Visibility(
                              visible: controller.countryName != null,
                              child: Form(
                                key: phoneFormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        CountryBottomSheetPlus.showProfileCompleteBottomSheet(context, controller);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                height: 47,
                                                padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: MyColor.getTextFieldFillColor(),
                                                  borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                                                  border: Border.all(
                                                    color: controller.countryName == null ? MyColor.getTextFieldDisableBorder() : MyColor.getTextFieldFillColor(),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    MyNetworkImageWidget(
                                                      imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", controller.countryCode.toString().toLowerCase()),
                                                      height: Dimensions.space25,
                                                      width: Dimensions.space40,
                                                    ),
                                                    horizontalSpace(Dimensions.space5),
                                                    Text(
                                                      "+${controller.mobileCode}",
                                                      style: regularDefault.copyWith(color: MyColor.getPrimaryColor()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if ((controller.mobileNoController.text.isEmpty && (controller.isCountryCodeSpaceHide == false))) ...[verticalSpace(27)]
                                            ],
                                          ),
                                          const SizedBox(width: Dimensions.space5 + 3),
                                          Expanded(
                                            child: CustomTextField(
                                              animatedLabel: true,
                                              needOutlineBorder: true,
                                              labelText: MyStrings.phoneNo.tr,
                                              controller: controller.mobileNoController,
                                              focusNode: controller.mobileNoFocusNode,
                                              textInputType: TextInputType.phone,
                                              inputAction: TextInputAction.next,
                                              onChanged: (value) {
                                                phoneFormKey.currentState!.validate();
                                                controller.toggleHideCountryCodeErrorSpace();
                                                // controller.
                                              },
                                              validator: (value) {
                                                if (value != null && value.isEmpty) {
                                                  return MyStrings.enterYourPhoneNumber.tr;
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.space20),
                                  ],
                                ),
                              ),
                            ),
                            CustomTextField(
                              animatedLabel: false,
                              needOutlineBorder: true,
                              labelText: MyStrings.address.tr,
                              hintText: "${MyStrings.enterYour.tr} ${MyStrings.address.tr.toLowerCase()}",
                              textInputType: TextInputType.text,
                              inputAction: TextInputAction.next,
                              focusNode: controller.addressFocusNode,
                              controller: controller.addressController,
                              nextFocus: controller.stateFocusNode,
                              onChanged: (value) {
                                return;
                              },
                            ),
                            const SizedBox(height: Dimensions.space20),
                            CustomTextField(
                              animatedLabel: false,
                              needOutlineBorder: true,
                              labelText: MyStrings.state.tr,
                              hintText: "${MyStrings.enterYour.tr} ${MyStrings.state.tr.toLowerCase()}",
                              textInputType: TextInputType.text,
                              inputAction: TextInputAction.next,
                              focusNode: controller.stateFocusNode,
                              controller: controller.stateController,
                              nextFocus: controller.cityFocusNode,
                              onChanged: (value) {
                                return;
                              },
                            ),
                            const SizedBox(height: Dimensions.space20),
                            CustomTextField(
                              animatedLabel: false,
                              needOutlineBorder: true,
                              labelText: MyStrings.city.tr,
                              hintText: "${MyStrings.enterYour.tr} ${MyStrings.city.tr.toLowerCase()}",
                              textInputType: TextInputType.text,
                              inputAction: TextInputAction.next,
                              focusNode: controller.cityFocusNode,
                              controller: controller.cityController,
                              nextFocus: controller.zipCodeFocusNode,
                              onChanged: (value) {
                                return;
                              },
                            ),
                            const SizedBox(height: Dimensions.space20),
                            CustomTextField(
                              animatedLabel: false,
                              needOutlineBorder: true,
                              labelText: MyStrings.zipCode.tr,
                              hintText: "${MyStrings.enterYour.tr} ${MyStrings.zipCode.tr.toLowerCase()}",
                              textInputType: TextInputType.text,
                              inputAction: TextInputAction.done,
                              focusNode: controller.zipCodeFocusNode,
                              controller: controller.zipCodeController,
                              onChanged: (value) {
                                return;
                              },
                            ),
                            const SizedBox(height: Dimensions.space20),
                            RoundedButton(
                              isLoading: controller.submitLoading,
                              text: MyStrings.updateProfile.tr,
                              press: () {
                                if ((phoneFormKey.currentState?.validate() ?? false) == false) {
                                  controller.toggleHideCountryCodeErrorSpace();
                                }
                                if ((formKey.currentState?.validate() ?? false) == true) {
                                  controller.updateProfile();
                                }
                              },
                            ),
                            const SizedBox(height: Dimensions.space40),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
