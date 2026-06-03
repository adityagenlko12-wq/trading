import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';
import 'package:vinance/view/components/row_widget/status_widget.dart';

import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../snack_bar/show_custom_snackbar.dart';

class CustomRowWithoutOrder extends StatelessWidget {
  final String firstText, lastText;
  final bool isStatus, isAbout;
  final Color? statusTextColor;
  final bool hasChild;
  final Widget? child;
  final bool lastTrCheck;
  final bool isCopyable;

  const CustomRowWithoutOrder({
    super.key,
    this.child,
    this.hasChild = false,
    this.statusTextColor,
    required this.firstText,
    required this.lastText,
    this.isStatus = false,
    this.isAbout = false,
    this.lastTrCheck = false,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(
              firstText.tr,
              style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )),
            isStatus
                ? StatusWidget(
                    status: lastText,
                    color: MyColor.pendingColor,
                  )
                : Flexible(
                    child: isCopyable
                        ? GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                text: lastText,
                              )).then((_) {
                                CustomSnackBar.success(successList: [MyStrings.copiedToClipBoard.tr], duration: 2);
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  lastTrCheck == false ? lastText : lastText.tr,
                                  maxLines: 2,
                                  style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                                horizontalSpace(Dimensions.space5),
                                Icon(
                                  Icons.copy,
                                  size: Dimensions.space12,
                                  color: MyColor.getPrimaryTextColor(),
                                )
                              ],
                            ),
                          )
                        : Text(
                            lastTrCheck == false ? lastText : lastText.tr,
                            maxLines: 2,
                            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ))
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
