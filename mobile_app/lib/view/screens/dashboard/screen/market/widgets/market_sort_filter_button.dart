import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/my_icons.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class MarketSortFilterButton extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final bool isAsc;
  final bool isActive;
  final bool showAscOrDescIcon;
  final Widget? iconWidget;

  const MarketSortFilterButton({
    super.key,
    required this.name,
    this.onTap,
    this.isAsc = false,
    this.isActive = false,
    this.showAscOrDescIcon = true,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? MyColor.getFilterTapActionButtonBgColorActive() : MyColor.getFilterTapActionButtonBgColorInActive(),
          borderRadius: BorderRadius.circular(Dimensions.radiusMax),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
        child: Row(
          children: [
            if (iconWidget != null) ...[
              iconWidget!
            ] else ...[
              Text(
                name.tr,
                style: boldDefault.copyWith(color: MyColor.getPrimaryTextColor()),
              ),
            ],
            if (showAscOrDescIcon) horizontalSpace(Dimensions.space8),
            if (showAscOrDescIcon)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyLocalImageWidget(
                    imagePath: MyIcons.arrowUp,
                    height: Dimensions.space10,
                    imageOverlayColor: isActive ? (isAsc == false ? MyColor.getPrimaryTextColor() : MyColor.getSecondaryTextColor().withOpacity(0.3)) : MyColor.getSecondaryTextColor().withOpacity(0.3),
                  ),
                  MyLocalImageWidget(
                    imagePath: MyIcons.arrowDown,
                    height: Dimensions.space10,
                    imageOverlayColor: isActive ? (isAsc == true ? MyColor.getPrimaryTextColor() : MyColor.getSecondaryTextColor().withOpacity(0.3)) : MyColor.getSecondaryTextColor().withOpacity(0.3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
