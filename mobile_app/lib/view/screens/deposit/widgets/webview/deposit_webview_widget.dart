import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/divider/custom_spacer.dart';
import 'webview_widget.dart';

class DepositWebviewWidget extends StatefulWidget {
  const DepositWebviewWidget({super.key, required this.redirectUrl});
  final String redirectUrl;

  @override
  State<DepositWebviewWidget> createState() => _DepositWebviewWidgetState();
}

class _DepositWebviewWidgetState extends State<DepositWebviewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: MyStrings.deposit.tr,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        actions: [
          horizontalSpace(Dimensions.space10),
        ],
      ),
      body: DepositAppWebViewWidget(url: widget.redirectUrl),
    );
  }

  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.microphone,
      Permission.mediaLibrary,
      Permission.camera,
      Permission.storage,
    ].request();

    return statuses;
  }
}
