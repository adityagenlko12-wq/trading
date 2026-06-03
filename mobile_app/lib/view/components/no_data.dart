import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vinance/view/components/image/my_local_image_widget.dart';

import '../../core/utils/dimensions.dart';
import '../../core/utils/my_color.dart';
import '../../core/utils/my_images.dart';
import '../../core/utils/my_strings.dart';
import '../../core/utils/style.dart';

class NoDataWidget extends StatelessWidget {
  final double margin;
  final String text;

  const NoDataWidget({super.key, this.margin = 4, this.text = MyStrings.noDataToShow});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height / margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyLocalImageWidget(
              imagePath: MyImages.noDataFound,
              height: Dimensions.space100,
              width: Dimensions.space100,
              imageOverlayColor: MyColor.getSecondaryTextColor(),
            ),
            const SizedBox(height: Dimensions.space3),
            Text(
              text.tr,
              style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
            )
          ],
        ),
      ),
    );
  }
}
