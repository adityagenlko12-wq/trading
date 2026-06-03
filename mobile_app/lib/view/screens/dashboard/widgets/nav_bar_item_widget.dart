import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class NavBarItem extends StatelessWidget {
  final String imagePath;
  final int index;
  final String label;
  final VoidCallback press;
  final bool isSelected;

  const NavBarItem({
    super.key,
    required this.imagePath,
    required this.index,
    required this.label,
    required this.isSelected,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
        onTap: press,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
          // color: MyColor.redCancelTextColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imagePath.contains('svg')
                  ? SvgPicture.asset(
                      imagePath,
                      colorFilter: ColorFilter.mode(
                        isSelected ? MyColor.getNavBarIconTextColorActive() : MyColor.getNavBarIconTextColorInActive(),
                        BlendMode.srcIn,
                      ),
                      width: Dimensions.space25,
                      height: Dimensions.space25,
                    )
                  : Image.asset(
                      imagePath,
                      color: isSelected ? MyColor.getNavBarIconTextColorActive() : MyColor.getNavBarIconTextColorInActive(),
                      width: Dimensions.space25,
                      height: Dimensions.space25,
                    ),
              const SizedBox(height: Dimensions.space10 / 2),
              Text(label.tr, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,maxLines: 1, style: regularSmall.copyWith(color: isSelected ? MyColor.getNavBarIconTextColorActive() : MyColor.getNavBarIconTextColorInActive()))
            ],
          ),
        ),
      ),
    );
  }
}
