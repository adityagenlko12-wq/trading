import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../../../data/controller/market/market_controller.dart';

class MarketScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? appBarSize;
  final String? title;
  final TextStyle? titleStyle;

  final Color bgColor;
  final bool fromAuth;
  final bool isProfileCompleted;

  final Widget? leadingWidget;
  final MarketController controller;
  final VoidCallback? leadingWidgetOnTap;

  const MarketScreenAppBar({
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
    return Container(
      height: appBarSize ?? 60.0,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space5),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsetsDirectional.only(top: Dimensions.space20),
          decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.radiusMax)),
          padding: const EdgeInsets.all(Dimensions.space5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: Dimensions.space15,
              ),
              Icon(
                CupertinoIcons.search,
                color: MyColor.getSecondaryTextColor(),
              ),
              horizontalSpace(Dimensions.space20),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  child: TextField(
                    controller: controller.searchTextController,
                    onTap: () {},
                    onChanged: (value) {
                      controller.filterMarketPairData(filterTypeParam: 'search');
                    },
                    style: regularDefault.copyWith(
                      fontSize: Dimensions.fontMediumLarge,
                      color: MyColor.getPrimaryTextColor(isReverse: false),
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: const OutlineInputBorder(
                        // Adding a border
                        borderSide: BorderSide.none, // Change the color as needed
                      ),
                      hintText: MyStrings.searchForCrypto.tr, // Adding hint text
                      hintStyle: regularDefault.copyWith(
                        fontSize: Dimensions.fontMediumLarge,
                        color: MyColor.getSecondaryTextColor(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
