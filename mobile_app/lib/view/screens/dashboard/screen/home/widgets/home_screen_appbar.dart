import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../../../core/utils/my_images.dart';
import '../../../../../../data/controller/home/home_controller.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? appBarSize;
  final String? title;
  final TextStyle? titleStyle;

  final Color bgColor;
  final bool fromAuth;
  final bool isProfileCompleted;
  final HomeController controller;
  final Widget? leadingWidget;
  final VoidCallback? leadingWidgetOnTap;

  const HomeScreenAppBar({
    super.key,
    this.fromAuth = false,
    this.bgColor = MyColor.primaryColorDark,
    this.title,
    required this.isProfileCompleted,
    this.titleStyle,
    this.appBarSize,
    this.leadingWidget,
    this.leadingWidgetOnTap,
    required this.controller,
  });

  @override
  Size get preferredSize => Size.fromHeight(appBarSize ?? 60.0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: MyColor.getSystemStatusBarColor(),
        statusBarIconBrightness: MyColor.getSystemStatusBarBrightness(),
        systemNavigationBarColor: MyColor.getSystemNavigationBarColor(),
        systemNavigationBarIconBrightness: MyColor.getSystemNavigationBarBrightness(),
      ),
      child: Container(
        height: appBarSize ?? 60.0,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space5),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (controller.checkUserIsLoggedInOrNot() == true && controller.dashboardResponseModel.data?.user != null) ...[
                      if (controller.profileImageUrl == '' || controller.profileImageUrl == 'null') ...[
                        const MyLocalImageWidget(
                          imagePath: MyImages.noProfileImage,
                          boxFit: BoxFit.cover,
                          width: Dimensions.space40,
                          height: Dimensions.space40,
                          radius: Dimensions.radiusMax,
                        )
                      ] else ...[
                        MyNetworkImageWidget(
                          imageUrl: controller.profileImageUrl,
                          boxFit: BoxFit.cover,
                          width: Dimensions.space40,
                          height: Dimensions.space40,
                          radius: Dimensions.radiusMax,
                        ),
                      ],
                      horizontalSpace(Dimensions.space10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.fullName,
                              style: semiBoldExtraLarge.copyWith(
                                color: MyColor.getPrimaryTextColor(),
                              ),
                            ),
                            verticalSpace(1),
                            Text(
                              "@${controller.username}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: regularLarge.copyWith(
                                color: MyColor.getSecondaryTextColor(),
                              ),
                            ),
                          ],
                        ),
                      )
                    ] else ...[
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: MyLocalImageWidget(
                          imagePath: MyColor.checkIsDarkTheme() ? MyImages.appLogoDark : MyImages.appLogoLight,
                          width: MediaQuery.of(context).size.width / 2.8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              controller.checkUserIsLoggedInOrNot()
                  ? Material(
                      type: MaterialType.transparency,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: MyColor.getScreenBgSecondaryColor(),
                          shape: const CircleBorder(),
                        ),
                        child: FittedBox(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Get.toNamed(RouteHelper.notificationScreen);
                            },
                            icon: Icon(
                              CupertinoIcons.bell,
                              color: MyColor.getAppBarContentTextColor(),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
