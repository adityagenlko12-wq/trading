import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/dashbaord/dashboard_controller.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';

import '../../../../../core/route/route.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_icons.dart';
import '../../../../../core/utils/my_images.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/account/profile_controller.dart';
import '../../../../../data/controller/common/theme_controller.dart';
import '../../../../../data/controller/localization/localization_controller.dart';
import '../../../../../data/controller/profile_and_settings/profile_and_settings_controller.dart';
import '../../../../../data/repo/account/profile_repo.dart';
import '../../../../../data/repo/auth/general_setting_repo.dart';
import '../../../../../data/repo/menu_repo/menu_repo.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/divider/custom_divider.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/image/my_local_image_widget.dart';
import '../../../../components/image/my_network_image_widget.dart';
import '../../../../components/text/header_text.dart';
import 'widgets/account_user_card.dart';
import 'widgets/menu_row_widget.dart';

class ProfileAndSettingsScreen extends StatefulWidget {
  const ProfileAndSettingsScreen({
    super.key,
  });

  @override
  State<ProfileAndSettingsScreen> createState() => _ProfileAndSettingsScreenState();
}

class _ProfileAndSettingsScreenState extends State<ProfileAndSettingsScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));

    Get.put(GeneralSettingRepo(apiClient: Get.find()));

    Get.put(MenuRepo(apiClient: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final profileController = Get.put(ProfileController(profileRepo: Get.find()));
    final controller = Get.put(ProfileAndSettingsController(menuRepo: Get.find(), repo: Get.find()));

    Get.put(LocalizationController(sharedPreferences: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //profile info
      profileController.loadProfileInfo();
      //load Configure
      controller.loadMenuConfigData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return GetBuilder<ProfileAndSettingsController>(builder: (profileAndSettingsController) {
        return GetBuilder<ProfileController>(builder: (profileController) {
          return Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: Dimensions.screenPaddingHV,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (profileAndSettingsController.checkUserIsLoggedInOrNot() == false) ...[
                      horizontalSpace(Dimensions.space15),
                      Align(
                        alignment: Alignment.center,
                        child: MyLocalImageWidget(
                          imagePath: MyColor.checkIsDarkTheme() ? MyImages.appLogoDark : MyImages.appLogoLight,
                          width: MediaQuery.of(context).size.width / 2.5,
                        ),
                      ),
                    ] else ...[
                      //header
                      Container(
                        decoration: BoxDecoration(
                          color: MyColor.getScreenBgSecondaryColor(),
                          borderRadius: BorderRadius.circular(Dimensions.space12),
                          // boxShadow: MyUtils.getCardShadow(),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: Dimensions.space15,
                            end: Dimensions.space15,
                            top: Dimensions.space15,
                            bottom: Dimensions.space15,
                          ),
                          child: AccountUserCard(
                            isLoading: profileController.isLoading,
                            onTap: () => Get.toNamed(RouteHelper.profileScreen),
                            fullName: profileAndSettingsController.profileController.fullName,
                            username: profileAndSettingsController.profileController.userName,
                            subtitle: profileAndSettingsController.profileController.mobileNo,
                            rating: 'hide',
                            imgWidget: Container(
                              decoration: BoxDecoration(border: Border.all(color: MyColor.borderColor, width: 0.5), shape: BoxShape.circle),
                              height: Dimensions.space50 + 35,
                              width: Dimensions.space50 + 35,
                              child: ClipOval(
                                child: (profileController.imageUrl == '' || profileController.imageUrl == 'null')
                                    ? const MyLocalImageWidget(
                                        imagePath: MyImages.noProfileImage,
                                        boxFit: BoxFit.cover,
                                        height: Dimensions.space50 + 60,
                                        width: Dimensions.space50 + 60,
                                      )
                                    : MyNetworkImageWidget(
                                        imageUrl: profileController.imageUrl,
                                        boxFit: BoxFit.cover,
                                        height: Dimensions.space50 + 60,
                                        width: Dimensions.space50 + 60,
                                      ),
                              ),
                            ),
                            imgHeight: 40,
                            imgwidth: 40,
                          ),
                        ),
                      ),
                      verticalSpace(Dimensions.space20),
                      HeaderText(text: MyStrings.account.tr.toUpperCase(), textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor(isReverse: true))),
                      const SizedBox(height: Dimensions.space10),

                      Container(
                        padding: const EdgeInsets.all(Dimensions.space15),
                        decoration: BoxDecoration(
                          color: MyColor.getScreenBgSecondaryColor(),
                          borderRadius: BorderRadius.circular(Dimensions.space12),
                          // boxShadow: MyUtils.getCardShadow(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MenuRowWidget(
                              image: MyIcons.menuProfile,
                              label: MyStrings.profile,
                              onPressed: () => Get.toNamed(RouteHelper.profileScreen),
                            ),
                            CustomDivider(
                              space: Dimensions.space15,
                              color: MyColor.getBorderColor(),
                            ),
                            MenuRowWidget(
                              image: MyIcons.navWallet,
                              label: MyStrings.wallet,
                              onPressed: () {
                                Get.find<DashboardController>().changeSelectedIndex(2);
                              },
                            ),
                            CustomDivider(
                              space: Dimensions.space15,
                              color: MyColor.getBorderColor(),
                            ),
                            MenuRowWidget(
                              image: MyIcons.referralIcon,
                              label: MyStrings.myReferrals,
                              onPressed: () => Get.toNamed(RouteHelper.referralScreen),
                            ),
                            CustomDivider(
                              space: Dimensions.space15,
                              color: MyColor.getBorderColor(),
                            ),
                            MenuRowWidget(
                              image: MyIcons.menuSecurity,
                              label: MyStrings.security,
                              onPressed: () => Get.toNamed(RouteHelper.securitySetupScreen),
                            ),
                            verticalSpace(Dimensions.space10),
                          ],
                        ),
                      ),
                      verticalSpace(Dimensions.space20),
                      HeaderText(text: MyStrings.general.tr.toUpperCase(), textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor(isReverse: true))),
                      const SizedBox(height: Dimensions.space10),
                      Container(
                        padding: const EdgeInsets.all(Dimensions.space15),
                        decoration: BoxDecoration(
                          color: MyColor.getScreenBgSecondaryColor(),
                          borderRadius: BorderRadius.circular(Dimensions.space12),
                          // boxShadow: MyUtils.getCardShadow(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MenuRowWidget(
                              image: MyIcons.menuWithdraw,
                              label: MyStrings.withdraw,
                              onPressed: () {
                                Get.toNamed(RouteHelper.withdrawScreen);
                              },
                            ),
                            CustomDivider(
                              space: Dimensions.space15,
                              color: MyColor.getBorderColor(),
                            ),
                             MenuRowWidget(
                              image: MyIcons.tradeMarketGrowthIconAction,
                              label: "Option Chain",
                              onPressed: () {
                                if (profileAndSettingsController.checkUserIsLoggedInOrNot()) {
                                  Get.toNamed(RouteHelper.optionsChainScreen);
                                } else {
                                  Get.toNamed(RouteHelper.authenticationScreen);
                                }
                              },
                            ),
                            CustomDivider(
                              space: Dimensions.space15,
                              color: MyColor.getBorderColor(),
                            ),
                            MenuRowWidget(
                              image: MyIcons.menuHistory,
                              label: MyStrings.transactions,
                              onPressed: () {
                                Get.toNamed(RouteHelper.walletHistoryScreen);
                              },
                            ),
                            verticalSpace(Dimensions.space10),
                          ],
                        ),
                      ),
                    ],
                    verticalSpace(Dimensions.space20),
                    HeaderText(text: MyStrings.more.tr.toUpperCase(), textStyle: regularLarge.copyWith(color: MyColor.getSecondaryTextColor(isReverse: true))),
                    const SizedBox(height: Dimensions.space10),
                    Container(
                      padding: const EdgeInsets.all(Dimensions.space15),
                      decoration: BoxDecoration(
                        color: MyColor.getScreenBgSecondaryColor(),
                        borderRadius: BorderRadius.circular(Dimensions.space12),
                        // boxShadow: MyUtils.getCardShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MenuRowWidget(
                            image: MyIcons.menuPreference,
                            imageSize: 28,
                            label: MyStrings.theme,
                            onPressed: () {},
                            endWidget: SizedBox(
                              height: 35,
                              child: FittedBox(
                                child: CupertinoSwitch(
                                  value: theme.darkTheme,
                                  onChanged: (value) {
                                    theme.toggleTheme();
                                  },
                                  activeColor: MyColor.greenSuccessColor, // Change the active color
                                  trackColor: MyColor.getPrimaryTextColor(), // Change the track color
                                ),
                              ),
                            ),
                          ),
                          CustomDivider(
                            space: Dimensions.space15,
                            color: MyColor.getBorderColor(),
                          ),
                          MenuRowWidget(
                            image: MyIcons.menuLanguage,
                            imageSize: 28,
                            label: MyStrings.language,
                            onPressed: () {
                              Get.toNamed(RouteHelper.languageScreen);
                            },
                            endWidget: Container(
                              margin: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                              height: 35,
                              child: Center(
                                child: profileAndSettingsController.getCurrentLanguageImage() == "-1"
                                    ? Icon(
                                        Icons.translate,
                                        color: MyColor.getSecondaryTextColor(),
                                      )
                                    : MyNetworkImageWidget(
                                        imageUrl: profileAndSettingsController.getCurrentLanguageImage(),
                                        width: 50,
                                        height: 50,
                                        radius: 4,
                                      ),
                              ),
                            ),
                          ),
                          CustomDivider(
                            space: Dimensions.space15,
                            color: MyColor.getBorderColor(),
                          ),
                          MenuRowWidget(
                            image: MyIcons.support,
                            imageSize: 28,
                            label: MyStrings.supportTicket,
                            onPressed: () {
                              if (profileAndSettingsController.checkUserIsLoggedInOrNot() == true) {
                                Get.toNamed(RouteHelper.allSupportTicketScreen);
                              } else {
                                Get.toNamed(RouteHelper.authenticationScreen);
                              }
                            },
                          ),
                          CustomDivider(
                            space: Dimensions.space15,
                            color: MyColor.getBorderColor(),
                          ),
                          MenuRowWidget(
                            image: MyIcons.menuPolicy,
                            imageSize: 28,
                            label: MyStrings.policies,
                            onPressed: () {
                              Get.toNamed(RouteHelper.privacyScreen);
                            },
                          ),
                          CustomDivider(
                            space: Dimensions.space15,
                            color: MyColor.getBorderColor(),
                          ),
                          MenuRowWidget(
                            image: MyIcons.faqIcon,
                            imageSize: 28,
                            label: MyStrings.faqs,
                            onPressed: () {
                              Get.toNamed(RouteHelper.faqScreenScreen);
                            },
                          ),
                          verticalSpace(Dimensions.space10),
                        ],
                      ),
                    ),
                    verticalSpace(Dimensions.space20),
                    if (profileAndSettingsController.checkUserIsLoggedInOrNot() == true) ...[
                      RoundedButton(
                        isLoading: profileAndSettingsController.logoutLoading,
                        color: MyColor.colorRed,
                        text: MyStrings.logout,
                        press: () {
                          var isFingerEnable = profileAndSettingsController.repo.apiClient.getFingerPrintStatus();
                          if (isFingerEnable) {
                            profileAndSettingsController.logout(); //Permanent logout
                            // profileAndSettingsController.tempLogout(); //Temp logout
                          } else {
                            profileAndSettingsController.logout();
                          }
                        },
                      ),
                      verticalSpace(Dimensions.space75),
                    ] else
                      ...[],
                  ],
                ),
              ),
            ),
          );
        });
      });
    });
  }
}
