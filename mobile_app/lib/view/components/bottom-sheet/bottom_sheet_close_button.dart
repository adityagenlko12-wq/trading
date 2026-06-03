import 'package:flutter/material.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';

class BottomSheetCloseButton extends StatelessWidget {
  const BottomSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        height: 30, width: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(Dimensions.space5),
        decoration:  BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), shape: BoxShape.circle),
        child:  Icon(Icons.clear, color: MyColor.getSecondaryTextColor(), size: 15),
      ),
    );
  }
}
