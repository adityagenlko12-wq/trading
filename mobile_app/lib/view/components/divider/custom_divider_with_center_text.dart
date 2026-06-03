import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

class CustomDividerWithCenterText extends StatelessWidget {
  final double space;
  final Color? color;
  final double? height;
  final String? text;

  const CustomDividerWithCenterText({super.key, this.space = Dimensions.space20, this.color, this.height, this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: (height ?? 0.5) * 25,
        ),
        PositionedDirectional(
          top: 0,
          bottom: 0,
          start: 0,
          end: 0,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: space),
                Divider(color: color ?? MyColor.getBorderColor(), height: height ?? 0.5, thickness: height ?? 0.5),
                SizedBox(height: space),
              ],
            ),
          ),
        ),
        PositionedDirectional(
          top: 0,
          bottom: 0,
          start: 0,
          end: 0,
          child: Align(
            alignment: Alignment.center,
            child: Container(
                color: MyColor.getScreenBgColor(),
                padding: const EdgeInsets.all(Dimensions.space5),
                child: FittedBox(
                  child: Text(
                    text?.tr ?? '',
                    style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                  ),
                )),
          ),
        )
      ],
    );
  }
}
