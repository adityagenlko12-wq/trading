import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class RoundedIconButton extends StatelessWidget {
  final bool isColorChange;
  final String text;
  final VoidCallback press;
  final Color color;
  final Color? textColor;
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double cornerRadius;
  final bool isOutlined;
  final Widget? child;
  final TextStyle? textStyle;
  final bool isLoading;
  final Color borderColor;
  final Color? loadingIndicatorColor;
  final bool isDisabled;
  final Widget icon;
  final bool iconRightSide;

  const RoundedIconButton({
    super.key,
    this.isColorChange = false,
    this.width = 1,
    this.child,
    this.cornerRadius = 8,
    required this.text,
    required this.press,
    this.isOutlined = false,
    this.horizontalPadding = 30,
    this.verticalPadding = 15,
    this.color = MyColor.primaryButtonColor,
    this.textColor = MyColor.colorWhite,
    this.textStyle,
    this.isLoading = false,
    this.borderColor = MyColor.primaryColorDark,
    this.loadingIndicatorColor,
    this.isDisabled = false,
    required this.icon,
    this.iconRightSide = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = Row(
      children: [
        if (iconRightSide == false) ...[
          icon,
        ],
        FittedBox(
          child: child ??
              Text(
                text.tr,
                style: textStyle ??
                    regularLarge.copyWith(
                      color: isColorChange ? textColor : MyColor.getPrimaryButtonTextColor(),
                      fontSize: 14,
                    ),
              ),
        ),
        if (iconRightSide == true) ...[
          icon,
        ],
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: isDisabled ? null : press,
        splashColor: MyColor.getScreenBgColor(),
        child: isOutlined
            ? OutlinedButton(
                onPressed: isDisabled ? null : press,
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  side: BorderSide(color: borderColor), // Border color for outlined button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : buttonChild,
              )
            : ElevatedButton(
                onPressed: isDisabled ? null : press,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(loadingIndicatorColor ?? MyColor.getPrimaryButtonTextColor()),
                        ),
                      )
                    : FittedBox(child: buttonChild),
              ),
      ),
    );
  }
}
