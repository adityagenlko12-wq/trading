import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

class LabelText extends StatelessWidget {
  final bool isRequired;
  final String text;
  final TextAlign? textAlign;

  const LabelText({
    super.key,
    required this.text,
    this.textAlign,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return isRequired
        ? Row(
            children: [
              Text(text.tr, textAlign: textAlign, style: regularLarge.copyWith(color: MyColor.getLabelTextColor())),
              const SizedBox(
                width: 2,
              ),
              Text(
                '*',
                style: semiBoldDefault.copyWith(color: MyColor.colorRed),
              )
            ],
          )
        : Text(
            text.tr,
            textAlign: textAlign,
            style: regularLarge.copyWith(color: MyColor.getLabelTextColor()),
          );
  }
}
