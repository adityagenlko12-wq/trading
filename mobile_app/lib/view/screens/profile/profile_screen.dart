import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/image/my_local_image_widget.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/account/profile_controller.dart';
import '../../../data/repo/account/profile_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/card/app_body_card.dart';
import '../../components/custom_loader/custom_loader.dart';
import '../../components/divider/custom_divider.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/image/my_network_image_widget.dart';
import 'widget/card_column.dart';
import 'widget/profile_view_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: MyStrings.profile.tr,
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : SingleChildScrollView(
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
                        // Details Section

                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(top: Dimensions.space50),
                              child: AppBodyWidgetCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    verticalSpace(Dimensions.space50),
                                    ProfileCardColumn(
                                      header: MyStrings.name.tr.toUpperCase(),
                                      body: controller.fullName,
                                    ),
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                    ProfileCardColumn(header: MyStrings.email.tr.toUpperCase(), body: controller.emailController.text),
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                    ProfileCardColumn(
                                      header: MyStrings.phone.tr.toUpperCase(),
                                      body: controller.mobileNoController.text,
                                    ),
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                    ProfileCardColumn(
                                      header: MyStrings.country.tr.toUpperCase(),
                                      body:controller.mobileNoController.text,
                                    ),
                                    CustomDivider(
                                      space: Dimensions.space15,
                                      color: MyColor.getBorderColor(),
                                    ),
                                    ProfileCardColumn(
                                      header: MyStrings.address.tr.toUpperCase(),
                                      body: controller.addressController.text,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(border: Border.all(color: MyColor.getScreenBgColor(), width: Dimensions.cardRadius2), shape: BoxShape.circle),
                                  height: Dimensions.space50 + 60,
                                  width: Dimensions.space50 + 60,
                                  child: ClipOval(
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
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: const ProfileViewBottomNavBar(),
        );
      },
    );
  }
}
