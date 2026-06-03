import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../../../core/utils/dimensions.dart';
import '../../../../../../core/utils/my_color.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../components/text/default_text.dart';

class MenuRowWidget extends StatelessWidget {
  final String image;
  final double? imageSize;
  final String label;
  final String? counter;
  final bool counterEnabled;
  final VoidCallback onPressed;
  final Widget? endWidget;
  final Color? iconColor;

  const MenuRowWidget({
    super.key,
    required this.image,
    required this.label,
    required this.onPressed,
    this.counter,
    this.counterEnabled = false,
    this.imageSize = 22,
    this.endWidget,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsetsDirectional.symmetric(vertical: Dimensions.space5, horizontal: Dimensions.space12),
        color: MyColor.transparentColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                image.contains('svg') ? SvgPicture.asset(image, colorFilter: ColorFilter.mode(iconColor ?? MyColor.getPrimaryColor(), BlendMode.srcIn), height: imageSize, width: imageSize, fit: BoxFit.contain) : Image.asset(image, color: MyColor.getPrimaryColor(), height: imageSize, width: imageSize, fit: BoxFit.contain),
                const SizedBox(width: Dimensions.space15),
                DefaultText(
                  text: label.tr,
                  textStyle: regularLarge.copyWith(
                    color: MyColor.getPrimaryTextColor(),
                  ),
                ),
              ],
            ),
            if (counterEnabled == true && counter != '0')
              Container(
                decoration: BoxDecoration(color: MyColor.colorRed, borderRadius: BorderRadius.circular(Dimensions.space2)),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space5),
                child: Text("$counter",
                    style: regularDefault.copyWith(
                      color: MyColor.colorWhite,
                    )),
              )
            else
              endWidget ?? Icon(Icons.arrow_forward_ios_rounded, color: MyColor.getSecondaryTextColor(), size: Dimensions.space15)
          ],
        ),
      ),
    );
  }
}
