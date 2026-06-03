import 'package:flutter/material.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';

class AppBodyWidgetCard extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;

  const AppBodyWidgetCard({super.key, this.onPressed, required this.child});

  @override
  State<AppBodyWidgetCard> createState() => _AppBodyWidgetCardState();
}

class _AppBodyWidgetCardState extends State<AppBodyWidgetCard> {
  @override
  Widget build(BuildContext context) {
    return widget.onPressed != null
        ? GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15 + 1, vertical: Dimensions.space25 - 1),
              decoration: BoxDecoration(
                color: MyColor.colorWhite,
                borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
              ),
              child: widget.child,
            ),
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15 + 1, vertical: Dimensions.space25 - 1),
            decoration: BoxDecoration(
              color:  MyColor.getScreenBgSecondaryColor(),
              borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
            ),
            child: widget.child,
          );
  }
}
