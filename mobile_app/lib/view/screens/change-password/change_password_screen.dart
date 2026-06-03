import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/account/change_password_controller.dart';
import '../../../data/repo/account/change_password_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/divider/custom_spacer.dart';
import 'widget/change_password_form.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ChangePasswordRepo(apiClient: Get.find()));
    Get.put(ChangePasswordController(changePasswordRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChangePasswordController>().clearData();
    });
  }

  @override
  void dispose() {
    Get.find<ChangePasswordController>().clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: MyStrings.changePassword.tr,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          horizontalSpace(Dimensions.space10),
        ],
      ),
      body: GetBuilder<ChangePasswordController>(
        builder: (controller) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical:  Dimensions.space15, horizontal:  Dimensions.space15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical:  Dimensions.space15, horizontal: Dimensions.space15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MyStrings.createNewPassword.tr,
                    style: regularExtraLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Text(
                      MyStrings.createPasswordSubText.tr,
                      style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor().withOpacity(0.8)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.space30),
                  const ChangePasswordForm()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
