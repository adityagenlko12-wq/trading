import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/repo/referral/referral_repository.dart';
import 'package:vinance/view/components/card/app_body_card.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../../../data/controller/referral/referral_controller.dart';
import '../../../data/services/api_service.dart';
import '../../components/app-bar/app_main_appbar.dart';
import '../../components/custom_loader/custom_loader.dart';
import '../../components/divider/custom_spacer.dart';
import '../../components/snack_bar/show_custom_snackbar.dart';
import 'widgets/all_referral_list_card_widget.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ReferralRepository(apiClient: Get.find()));
    final controller = Get.put(ReferralController(referralRepository: Get.find()));
    super.initState();
    controller.getAllReferralList(isFromLoad: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReferralController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.myReferrals.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: RefreshIndicator(
          color: MyColor.primaryColor,
          onRefresh: () async {
            controller.getAllReferralList(isFromLoad: true);
          },
          child: SingleChildScrollView(
            padding: Dimensions.screenPaddingHV,
            physics: const BouncingScrollPhysics(),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  const SizedBox(
                    height: Dimensions.space15,
                  ),
                  const SizedBox(
                    height: Dimensions.space15,
                  ),
                  AppBodyWidgetCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: Dimensions.space10,
                        ),
                        Text(
                          MyStrings.youReferCode.tr,
                          style: regularDefault.copyWith(
                            color: MyColor.getPrimaryTextColor(),
                            fontSize: Dimensions.fontMediumLarge + 3,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.space5,
                        ),
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.8),
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: MyColor.getPrimaryColor().withOpacity(0.9),
                                radius: const Radius.circular(Dimensions.cardRadius1),
                                child: Container(
                                  decoration: BoxDecoration(color: MyColor.getPrimaryColor().withOpacity(0.3), borderRadius: BorderRadius.circular(Dimensions.cardRadius2 - 1)),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(Dimensions.space15),
                                  child: Container(
                                    margin: const EdgeInsetsDirectional.only(end: Dimensions.space50),
                                    child: Text(
                                      "${UrlContainer.referURl}${controller.referralRepository.apiClient.getCurrencyOrUsername(isSymbol: false, isCurrency: false)}",
                                      style: boldExtraLarge.copyWith(
                                        color: MyColor.colorWhite,
                                        fontSize: Dimensions.fontLarge,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                      text: "${UrlContainer.referURl}${controller.referralRepository.apiClient.getCurrencyOrUsername(isSymbol: false, isCurrency: false)}",
                                    )).then((_) {
                                      CustomSnackBar.success(successList: [MyStrings.copiedToClipBoard.tr], duration: 2);
                                    });
                                  },
                                  child: const FittedBox(
                                    child: Padding(
                                      padding: EdgeInsets.all(Dimensions.space3),
                                      child: Icon(
                                        Icons.copy,
                                        color: MyColor.colorWhite,
                                        size: 3,
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.space20,
                        ),
                        Text(
                          " ${MyStrings.usersReferredByMe.tr}",
                          style: regularDefault.copyWith(
                            color: MyColor.getPrimaryTextColor(),
                            fontSize: Dimensions.fontMediumLarge + 3,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.space20,
                        ),
                        //Ny Referral list
                        // In your main widget build method
                        controller.isLoading
                            ? const SizedBox(height: Dimensions.space100, child: CustomLoader())
                            : Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${controller.myReferralsData?.getFullName()} (${controller.myReferralsData?.username})",
                                      style: regularDefault.copyWith(
                                        color: MyColor.getPrimaryTextColor(),
                                        fontSize: Dimensions.fontLarge,
                                      ),
                                    ),
                                    verticalSpace(Dimensions.space10),
                                    //Level 1
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.only(),
                                        child: ReferralCardWidget(
                                          referrals: controller.myReferralsData?.allReferrals ?? [],
                                          levelNo: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
