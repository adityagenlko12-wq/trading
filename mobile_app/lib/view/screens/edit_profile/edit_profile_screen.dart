import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/account/profile_controller.dart';
import '../../../data/repo/account/profile_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/buttons/rounded_button.dart';
import '../../components/card/app_body_card.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_local_image_widget.dart';
import '../../components/image/my_network_image_widget.dart';
import '../../components/text-form-field/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(ProfileController(profileRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadProfileInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.editProfile.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: SingleChildScrollView(
          padding: Dimensions.screenPaddingHV,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            // color: Colors.orange,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Details Section
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: Dimensions.space50),
                      child: AppBodyWidgetCard(
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              verticalSpace(Dimensions.space75),
                              Row(
                                children: [
                                  Container(
                                    width: Dimensions.space5,
                                    height: Dimensions.space25,
                                    decoration: BoxDecoration(color: MyColor.getPrimaryColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(
                                    MyStrings.profileInformation,
                                    style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  )
                                ],
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.firstNameController,
                                labelText: MyStrings.firstName.tr,
                                onChanged: (value) {},
                                focusNode: controller.firstNameFocusNode,
                                nextFocus: controller.lastNameFocusNode,
                                textInputType: TextInputType.text,
                                inputAction: TextInputAction.next,
                                fillColor:  MyColor.getScreenBgColor().withOpacity(0.7),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.lastNameController,
                                labelText: MyStrings.lastName.tr,
                                onChanged: (value) {},
                                focusNode: controller.lastNameFocusNode,
                                nextFocus: controller.stateFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                readOnly: true,
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.emailController,
                                labelText: MyStrings.email.tr,
                                onChanged: (value) {},
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                focusNode: controller.emailFocusNode,
                                // nextFocus: controller.passwordFocusNode,
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
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                readOnly: true,
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.mobileNoController,
                                labelText: MyStrings.phone.tr,
                                onChanged: (value) {},
                                focusNode: controller.mobileNoFocusNode,
                                // nextFocus: controller.stateFocusNode,
                                textInputType: TextInputType.phone,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space40),
                              Row(
                                children: [
                                  Container(
                                    width: Dimensions.space5,
                                    height: Dimensions.space25,
                                    decoration: BoxDecoration(color: MyColor.getPrimaryColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
                                  ),
                                  horizontalSpace(Dimensions.space10),
                                  Text(
                                    MyStrings.addressInformation.tr,
                                    style: boldExtraLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                  )
                                ],
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.stateController,
                                labelText: MyStrings.state.tr,
                                onChanged: (value) {},
                                focusNode: controller.stateFocusNode,
                                nextFocus: controller.cityFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.cityController,
                                labelText: MyStrings.city.tr,
                                onChanged: (value) {},
                                focusNode: controller.cityFocusNode,
                                nextFocus: controller.zipCodeFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.zipCodeController,
                                labelText: MyStrings.zipCode.tr,
                                onChanged: (value) {},
                                focusNode: controller.zipCodeFocusNode,
                                nextFocus: controller.addressFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              CustomTextField(
                                animatedLabel: false,
                                needOutlineBorder: true,
                                controller: controller.addressController,
                                labelText: MyStrings.address.tr,
                                onChanged: (value) {},
                                focusNode: controller.addressFocusNode,
                                // nextFocus: controller.lastNameFocusNode,
                                textInputType: TextInputType.text,
                                fillColor: MyColor.getScreenBgColor().withOpacity(0.7),
                                inputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return MyStrings.fieldErrorMsg.tr;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              verticalSpace(Dimensions.space20),
                              RoundedButton(
                                isLoading: controller.isSubmitLoading,
                                horizontalPadding: Dimensions.space10,
                                verticalPadding: Dimensions.space20,
                                text: MyStrings.updateProfile.tr,
                                press: () {
                                  controller.updateProfile();
                                },
                                cornerRadius: 8,
                                isOutlined: false,
                                color: MyColor.getPrimaryButtonColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: MyColor.getScreenBgColor(), width: Dimensions.cardRadius1), shape: BoxShape.circle),
                              height: Dimensions.space50 + 60,
                              width: Dimensions.space50 + 60,
                              child: (controller.imageFile != null)
                                  ? ClipOval(
                                      child: MyLocalImageWidget(
                                        isFileType: true,
                                        imagePath: controller.imageFile?.path ?? '',
                                        width: Dimensions.space25,
                                      ),
                                    )
                                  : ClipOval(
                                      child: (controller.imageUrl == '' || controller.imageUrl == 'null')
                                          ? const MyLocalImageWidget(
                                              imagePath: MyImages.noProfileImage,
                                              boxFit: BoxFit.cover,
                                              height: Dimensions.space50 + 60,
                                              width: Dimensions.space50 + 60,
                                            )
                                          : MyNetworkImageWidget(
                                              imageUrl: controller.imageUrl,
                                              boxFit: BoxFit.cover,
                                              height: Dimensions.space50 + 60,
                                              width: Dimensions.space50 + 60,
                                            ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        controller.pickAImage(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(color: MyColor.screenBgColor, border: Border.all(color: MyColor.colorWhite, width: Dimensions.space3), shape: BoxShape.circle),
                                        height: Dimensions.space40,
                                        width: Dimensions.space40,
                                        child: ClipOval(
                                          child: Icon(
                                            Icons.add_a_photo_outlined,
                                            size: Dimensions.space20,
                                            color: MyColor.getPrimaryColor(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
