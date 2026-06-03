import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/dialog/exit_dialog.dart';

import '../../core/helper/string_format_helper.dart';

class WillPopWidget extends StatelessWidget {
  final Widget child;
  final String nextRoute;

  const WillPopWidget({super.key, required this.child, this.nextRoute = ''});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, v) async {
          printx('didPop: $didPop');
          if (didPop) return;
          if (nextRoute.isEmpty) {
            showExitDialog(context);
          } else {
            Get.offAndToNamed(nextRoute);
          }
        },
        child: child);
  }
}
