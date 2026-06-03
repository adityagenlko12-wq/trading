import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/helper/shared_preference_helper.dart';
import '../../../../../../core/route/route.dart';
import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/messages.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/my_strings.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../data/controller/localization/localization_controller.dart';
import '../../../../../../data/model/global/response_model/response_model.dart';
import '../../../../../../data/model/language/language_model.dart';
import '../../../../../../data/repo/auth/general_setting_repo.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';
import '../../../../../components/snack_bar/show_custom_snackbar.dart';

class LanguageDialogBody extends StatefulWidget {
  final List<MyLanguageModel> langList;
  final bool fromSplashScreen;
  final String selectedlanguageCode;

  const LanguageDialogBody({super.key, required this.langList, this.fromSplashScreen = false, required this.selectedlanguageCode});

  @override
  State<LanguageDialogBody> createState() => _LanguageDialogBodyState();
}

class _LanguageDialogBodyState extends State<LanguageDialogBody> {
  int pressIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            //Main code
            Container(
              margin: const EdgeInsetsDirectional.only(top: Dimensions.space20),
              decoration: BoxDecoration(
                color: MyColor.getScreenBgColor(),
                borderRadius: const BorderRadiusDirectional.only(
                  topEnd: Radius.circular(25),
                  topStart: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: MyColor.getPrimaryColor().withOpacity(0.2),
                    offset: const Offset(0, -4),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15),
              child: Column(
                children: [
                  verticalSpace(Dimensions.space30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          MyStrings.selectALanguage.tr,
                          style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor(), fontSize: Dimensions.fontLarge),
                        ),
                      ),
                      const SizedBox(
                        height: Dimensions.space15,
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.langList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  pressIndex = index;
                                });
                                String languageCode = widget.langList[index].languageCode;
                                final repo = Get.put(GeneralSettingRepo(apiClient: Get.find()));
                                final localizationController = Get.put(LocalizationController(sharedPreferences: Get.find()));
                                ResponseModel response = await repo.getLanguage(languageCode);
                                if (response.statusCode == 200) {
                                  try {
                                    Map<String, Map<String, String>> language = {};
                                    var resJson = jsonDecode(response.responseJson);
                                    await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, response.responseJson);

                                    var value = resJson['data']['file'].toString() == '[]' ? {} : jsonDecode(resJson['data']['file']) as Map<String, dynamic>;
                                    Map<String, String> json = {};
                                    value.forEach((key, value) {
                                      json[key] = value.toString();
                                    });

                                    language['${widget.langList[index].languageCode}_${'US'}'] = json;

                                    Get.clearTranslations();
                                    Get.addTranslations(Messages(languages: language).keys);

                                    Locale local = Locale(widget.langList[index].languageCode, 'US');
                                    localizationController.setLanguage(local, '');
                                    if (widget.fromSplashScreen) {
                                      Get.offAndToNamed(RouteHelper.authenticationScreen);
                                    } else {
                                      Get.back();
                                    }
                                  } catch (e) {
                                    CustomSnackBar.error(errorList: [e.toString()]);
                                    pressIndex = -1;
                                  }
                                } else {
                                  CustomSnackBar.error(errorList: [response.message]);
                                  pressIndex = -1;
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                                decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (widget.langList[index].languageName).tr,
                                      style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                    ),
                                    if (pressIndex == index) ...[
                                      const Center(
                                        child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: MyColor.primaryColor,
                                              strokeWidth: 0.8,
                                            )),
                                      )
                                    ] else ...[
                                      if (widget.selectedlanguageCode == widget.langList[index].languageCode) ...[
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: MyColor.getPrimaryColor(),
                                        )
                                      ]
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //bottom sheet closer
            Positioned(
              top: 0,
              left: 20,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(),
                child: Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: MyColor.getTabBarTabBackgroundColor(),
                      shape: const CircleBorder(),
                    ),
                    child: FittedBox(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.back();
                        },
                        icon: MyLocalImageWidget(
                          imagePath: MyIcons.doubleArrowDown,
                          imageOverlayColor: MyColor.getPrimaryTextColor(),
                          width: Dimensions.space25,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
