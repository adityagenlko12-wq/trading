import 'package:flutter/material.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/divider/custom_divider.dart';
import 'package:get/get.dart';

import '../../../core/utils/my_color.dart';
import '../buttons/custom_circle_animated_button.dart';

class BottomSheetTopRow extends StatelessWidget {

  final String header;
  final double bottomSpace;
  final Color bgColor;

  const BottomSheetTopRow({
    super.key,
    required this.header,
    this.bottomSpace = 10,
    this.bgColor = MyColor.containerBgColor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(header.tr, style: regularDefault.copyWith(color:  MyColor.getPrimaryTextColor(), fontWeight: FontWeight.w600)),
            CustomCircleAnimatedButton(
              onTap: (){
                Get.back();
              },
              height: 30,
              width: 30,
              backgroundColor: bgColor,
              child:  Icon(Icons.clear, color: MyColor.getPrimaryTextColor(), size: 15),
            )
          ],
        ),
        const CustomDivider(),
      ],
    );
  }
}
