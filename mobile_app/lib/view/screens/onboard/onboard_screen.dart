import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/view/screens/onboard/widget/into_page_widget.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/onbaord/onboard_controller.dart';
import '../../../data/repo/onboard/onboard_repo.dart';
import '../../../data/services/api_service.dart';
import '../../components/custom_loader/custom_loader.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(context) async {
    bool isFirstTime = Get.find<ApiClient>().sharedPreferences.getBool(SharedPreferenceHelper.firstTimeOnAppKey) ?? true;

    if (isFirstTime == false) {
      Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.onBoardIsOnKey, false).whenComplete(() {
        Get.offAllNamed(RouteHelper.authenticationScreen, arguments: true);
      });
    } else {
      Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.onBoardIsOnKey, false).whenComplete(() {
        Get.offAllNamed(RouteHelper.authenticationScreen, arguments: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(OnboardRepo(apiClient: Get.find()));
    final controller = Get.put(OnboardController(onboardRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAllOnboardDataList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          body: controller.isLoading || controller.onboardList.isEmpty
              ? const CustomLoader()
              : IntroductionScreen(
                  resizeToAvoidBottomInset: false,
                  key: introKey,
                  globalBackgroundColor: MyColor.getScreenBgColor(),
                  allowImplicitScrolling: true,
                  autoScrollDuration: 500000,
                  globalHeader: null,
                  rawPages: List.generate(controller.onboardList.length, (index) {
                    var item = controller.onboardList[index];
                    return IntoPageWidget(
                      image: '${UrlContainer.domainUrl}/${controller.onboardImagePath}/${item.dataValues?.image ?? ''}',
                      title: item.dataValues?.title ?? '',
                      description: item.dataValues?.subtitle ?? '',
                    );
                  }),
                  onDone: () => _onIntroEnd(context),
                  onSkip: () => _onIntroEnd(context),
                  // You can override onSkip callback
                  showSkipButton: true,
                  skipOrBackFlex: 0,
                  nextFlex: 0,
                  showBackButton: false,
                  showBottomPart: true,
                  //rtl: true, // Display as right-to-left
                  back: const Icon(
                    Icons.arrow_back,
                    color: MyColor.primaryColor500,
                  ),
                  skip: Text(
                    MyStrings.skip.tr,
                    style: regularDefault.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MyColor.primaryColor500,
                    ),
                  ),

                  next: const Icon(
                    Icons.arrow_forward,
                    color: MyColor.primaryColor500,
                  ),
                  done: Text(
                    MyStrings.done.tr,
                    style: regularDefault.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MyColor.primaryColor500,
                    ),
                  ),
                  curve: Curves.fastLinearToSlowEaseIn,
                  controlsMargin: const EdgeInsets.all(16),
                  controlsPadding: kIsWeb ? const EdgeInsets.all(12.0) : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  dotsFlex: 1,
                  dotsDecorator: const DotsDecorator(
                    size: Size(10.0, 10.0),
                    color: MyColor.secondaryColor800,
                    activeColor: MyColor.primaryColor500,
                    activeSize: Size(22.0, 10.0),
                    activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                  dotsContainerDecorator: const ShapeDecoration(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                ),
        );
      },
    );
  }

}
