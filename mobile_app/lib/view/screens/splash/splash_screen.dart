import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_images.dart';
import 'package:vinance/core/utils/util.dart';
import 'package:vinance/data/controller/localization/localization_controller.dart';
import 'package:vinance/data/controller/splash/splash_controller.dart';
import 'package:vinance/data/repo/auth/general_setting_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/will_pop_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    MyUtils.splashScreen();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    final controller = Get.put(SplashController(repo: Get.find(), localizationController: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.gotoNextPage();
    });
  }

  @override
  void dispose() {
    MyUtils.allScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GetBuilder<SplashController>(
      builder: (controller) => WillPopWidget(
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: Stack(
            children: [
              Positioned.fill(
                  child: Image.asset(
                MyImages.backgroundImage,
                fit: BoxFit.cover,
              )),
              Align(
                alignment: Alignment.center,
                child: Image.asset(MyImages.appLogoDark, width: size.width / 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
