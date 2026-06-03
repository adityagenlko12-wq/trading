import 'package:flutter/material.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/row_widget/status_widget.dart';

import '../../../core/utils/my_color.dart';
import '../divider/custom_divider.dart';

class CustomRow extends StatelessWidget {
  final String firstText, lastText;
  final bool isStatus, isAbout, showDivider;
  final Color? statusTextColor;
  final bool hasChild;
  final Widget? child;
  final bool lastTrCheck;
  final double spaceHeight;

  const CustomRow({
    super.key,
    this.child,
    this.hasChild = false,
    this.statusTextColor,
    required this.firstText,
    required this.lastText,
    this.isStatus = false,
    this.isAbout = false,
    this.showDivider = true,
    this.lastTrCheck = false,
    this.spaceHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return hasChild
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(
                    firstText.tr,
                    style: regularDefault.copyWith(color: MyColor.getPrimaryColor()),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
                  child ?? const SizedBox(),
                ],
              ),
              SizedBox(
                height: spaceHeight,
              ),
              showDivider
                  ? Divider(
                      color: MyColor.getBorderColor(),
                    )
                  : const SizedBox(),
              showDivider
                  ? SizedBox(
                      height: spaceHeight,
                    )
                  : const SizedBox(),
            ],
          )
        : isAbout
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(firstText.tr, style: regularDefault.copyWith(color: MyColor.primaryColorDark)),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    lastText.tr,
                    style: regularDefault.copyWith(color: isStatus ? statusTextColor : MyColor.primaryColorDark),
                  ),
                  SizedBox(
                    height: spaceHeight,
                  ),
                ],
              )
            : Column(
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
                              color: MyColor.greenP,
                            )
                          : Flexible(
                              child: Text(
                              lastTrCheck == false ? lastText : lastText.tr,
                              maxLines: 2,
                              style: regularDefault.copyWith(color: isStatus ? MyColor.greenSuccessColor : MyColor.primaryColorDark),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ))
                    ],
                  ),
                  SizedBox(height: spaceHeight),
                  showDivider
                      ? CustomDivider(
                          color: MyColor.getBorderColor(),
                        )
                      : const SizedBox(),
                  showDivider
                      ? SizedBox(
                          height: spaceHeight,
                        )
                      : const SizedBox(),
                ],
              );
  }
}
