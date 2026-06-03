import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../components/divider/custom_spacer.dart';
import '../../../../../components/image/my_local_image_widget.dart';

class HomeActionMenuButtonWidget extends StatelessWidget {
  final String image, title;
  final VoidCallback? onTap;
  const HomeActionMenuButtonWidget({super.key, required this.image, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(),
            child: Ink(
              decoration: ShapeDecoration(
                color: MyColor.getAppBarBackgroundColor(),
                shape: const CircleBorder(),
              ),
              child: FittedBox(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onTap,
                  icon: MyLocalImageWidget(
                    imagePath: image,
                    imageOverlayColor: MyColor.getPrimaryColor(),
                    width: Dimensions.space25,
                  ),
                ),
              ),
            ),
          ),
          verticalSpace(Dimensions.space5),
          FittedBox(
            child: Text(
              (title).tr,
              style: semiBoldSmall.copyWith(color: MyColor.getPrimaryTextColor()),
            ),
          )
        ],
      ),
    );
  }
}
