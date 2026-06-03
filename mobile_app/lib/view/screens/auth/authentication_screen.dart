import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/data/controller/auth/auth/metamask/metamask_login_controller.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/screens/auth/login/login_screen.dart';
import 'package:vinance/view/screens/auth/registration/registration_screen.dart';

import '../../../core/route/route.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/auth/auth/metamask/metamask_reg_controller.dart';
import '../../../data/controller/auth/authentication_controller.dart';
import '../../../data/controller/common/theme_controller.dart';
import '../../../data/repo/auth/login_repo.dart';
import '../../../data/repo/auth/signup_repo.dart';
import '../../../data/services/api_service.dart';

class AuthenticationScreen extends StatefulWidget {
  final bool isShowLoginTab;
  const AuthenticationScreen({super.key, this.isShowLoginTab = true});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(LoginRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()));
    Get.put(AuthenticationController(loginRepo: Get.find(), registrationRepo: Get.find()));
    Get.put(MetaMaskAuthLoginController(loginRepo: Get.find()));
    Get.put(MetaMaskAuthRegController(registrationRepo: Get.find()));

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthenticationController>(builder: (controller) {
      return GetBuilder<ThemeController>(builder: (themeController) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: MyColor.getSystemStatusBarColor(),
            statusBarIconBrightness: MyColor.getSystemStatusBarBrightness(),
            systemNavigationBarColor: MyColor.getSystemNavigationBarColor(),
            systemNavigationBarIconBrightness: MyColor.getSystemNavigationBarBrightness(),
          ),
          child: Scaffold(
            backgroundColor: MyColor.getScreenBgColor(),
            body: SafeArea(
              child: Container(
                padding: Dimensions.screenPaddingHV,
                child: DefaultTabController(
                  length: 2,
                  initialIndex: widget.isShowLoginTab == true ? 0 : 1,
                  child: Column(
                    children: [
                      if (!controller.loginRepo.apiClient.getFingerPrintStatus()) ...[
                        verticalSpace(Dimensions.space10),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.end, children: [
                          TextButton(
                            style: TextButton.styleFrom(padding: const EdgeInsets.all(Dimensions.space2)),
                            onPressed: () {
                              Get.offAllNamed(RouteHelper.dashboardScreen);
                            },
                            child: Row(
                              children: [
                                Text(
                                  MyStrings.skip.tr,
                                  style: regularMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                ),
                                horizontalSpace(Dimensions.space5),
                                Icon(
                                  Icons.close,
                                  color: MyColor.getPrimaryTextColor(),
                                  size: Dimensions.space25,
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ],
                      verticalSpace(Dimensions.space10),
                      //TAB BAR
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space5, horizontal: Dimensions.space5),
                        decoration: BoxDecoration(
                          color: MyColor.getTabBarTabBackgroundColor(),
                          borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: MyColor.getTabBarTabColor(),
                            borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                            border: Border.all(
                              color: MyColor.getTabBarTabColor(),
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: MyColor.getPrimaryTextColor(),
                          labelStyle: semiBoldDefault.copyWith(
                            fontSize: Dimensions.fontLarge,
                          ),
                          unselectedLabelColor: MyColor.getSecondaryTextColor(),
                          unselectedLabelStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge),
                          tabs: [
                            Tab(
                              text: MyStrings.signIn.tr,
                            ),
                            Tab(
                              text: MyStrings.signUp.tr,
                            ),
                          ],
                        ),
                      ),
                      //TAB VIEW DATA
                      const Expanded(
                        child: TabBarView(
                          physics: ClampingScrollPhysics(),
                          // controller: controller.tabController,
                          children: [
                            LoginScreen(),
                            RegistrationScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }
}
