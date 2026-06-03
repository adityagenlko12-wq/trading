import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';

import 'package:vinance/view/components/image/my_local_image_widget.dart';

import '../../../../../core/utils/style.dart';

class SocialAuthButtonWidget extends StatelessWidget {
  final String assetImage;
  final String text;
  final bool isLoading;
  final bool showText;
  final Function()? onPressed;
  const SocialAuthButtonWidget({super.key, required this.assetImage, required this.text, this.onPressed, this.isLoading = false, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.screenBackgroundColorLight,
          elevation: 0.2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          animationDuration: const Duration(milliseconds: 1000),
          foregroundColor: MyColor.screenBackgroundColorLight,
          shadowColor: MyColor.getPrimaryColor().withOpacity(0.3),
        ),
        onPressed: () {
          if (onPressed != null) {
            if (!isLoading) {
              onPressed!();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.space15),
          child: isLoading
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    color: MyColor.primaryColor,
                    strokeWidth: 1,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        child: MyLocalImageWidget(
                          imagePath: assetImage,
                          width: 20.0,
                          height: 20.0,
                        ),
                      ),
                    ),
                    if (showText) ...[
                      const SizedBox(width: 10.0),
                      Flexible(
                        child: Text(
                          text.tr ,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: regularLarge.copyWith(fontWeight: FontWeight.w500, color: MyColor.secondaryColor900),
                        ),
                      ),
                    ]
                  ],
                ),
        ),
      ),
    );
  }
}
