import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/auth/auth/metamask/metamask_reg_controller.dart';
import 'package:vinance/data/controller/auth/auth/registration_controller.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';
import 'package:vinance/data/repo/auth/signup_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/will_pop_widget.dart';
import 'package:vinance/view/screens/auth/registration/widget/registration_form.dart';

import '../../../../core/utils/my_icons.dart';
import '../../../../environment.dart';
import '../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';
import '../../../components/divider/custom_divider_with_center_text.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/no_data.dart';
import '../../../components/shimmer/text_field_loading_shimmer.dart';
import '../login/metamask/meta_reg_bottom_sheet.dart';
import '../social_auth/widgets/social_auth_button-widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(RegistrationRepo(apiClient: Get.find()));
    Get.put(MetaMaskAuthRegController(registrationRepo: Get.find()));
    Get.put(RegistrationController(registrationRepo: Get.find(), generalSettingRepo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RegistrationController>().initData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) => WillPopWidget(
        nextRoute: RouteHelper.authenticationScreen,
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.noInternet
              ? const Center(
                  child: NoDataWidget(
                  text: MyStrings.noInternet,
                ))
              : controller.isLoading
                  ? const TextFieldLoadingShimmer()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          verticalSpace(Dimensions.space25),
                          //Social Auth
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.space3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (Environment.enableLoginWithMetamask && controller.registrationRepo.apiClient.getMetaMetamaskEnableStatus() == true) ...[
                                  Expanded(
                                    child: SocialAuthButtonWidget(
                                      isLoading: Get.find<MetaMaskAuthRegController>().isMetaMaskSubmitLoading,
                                      assetImage: MyIcons.metaMaskIcon,
                                      text: MyStrings.metaMask.tr,
                                      showText: !controller.registrationRepo.apiClient.getSocialCredentialsEnabledAll(),
                                      onPressed: () {
                                        CustomBottomSheetPlus(
                                          child: const ConnectToMetamaskRegistrationBottomSheet(),
                                          isNeedPadding: false,
                                          bgColor: MyColor.getScreenBgSecondaryColor(),
                                        ).show(context);
                                      },
                                    ),
                                  ),
                                ],
                                if (controller.registrationRepo.apiClient.getSocialCredentialsConfigData().google?.status == '1') ...[
                                  horizontalSpace(Dimensions.space5),
                                  Expanded(
                                    child: SocialAuthButtonWidget(
                                      isLoading: controller.isSocialSubmitLoading && controller.isGoogle,
                                      assetImage: MyIcons.googleIcon,
                                      text: MyStrings.google.tr,
                                      showText: !controller.registrationRepo.apiClient.getSocialCredentialsEnabledAll(),
                                      onPressed: () {
                                        controller.signInWithGoogle();
                                      },
                                    ),
                                  ),
                                ],
                                if (controller.registrationRepo.apiClient.getSocialCredentialsConfigData().linkedin?.status == '1') ...[
                                  horizontalSpace(Dimensions.space5),
                                  Expanded(
                                    child: SocialAuthButtonWidget(
                                      isLoading: controller.isSocialSubmitLoading && controller.isLinkedin,
                                      assetImage: MyIcons.linkeDinIcon,
                                      text: MyStrings.linkedin.tr,
                                      showText: !controller.registrationRepo.apiClient.getSocialCredentialsEnabledAll(),
                                      onPressed: () {
                                        controller.signInWithLinkeDin(context);
                                      },
                                    ),
                                  )
                                ],
                              ],
                            ),
                          ),
                          CustomDividerWithCenterText(
                            text: MyStrings.orSignUpWith.tr,
                            height: 2,
                          ),
                          //General Auth
                          const RegistrationForm(),
                          const SizedBox(height: Dimensions.space30),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
