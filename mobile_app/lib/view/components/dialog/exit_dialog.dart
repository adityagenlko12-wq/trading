
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';

showExitDialog(BuildContext context) {
  AwesomeDialog(
    padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
    context: context,
    dialogType: DialogType.warning,
    dialogBackgroundColor: MyColor.getScreenBgSecondaryColor(),
    width: MediaQuery.of(context).size.width,
    buttonsBorderRadius: BorderRadius.circular(Dimensions.cardRadius2),
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: true,
    onDismissCallback: (type) {},
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: MyStrings.exitTitle.tr,
    titleTextStyle: regularLarge.copyWith(color: MyColor.getPrimaryTextColor(), fontWeight: FontWeight.w600),
    showCloseIcon: false,
    btnCancel: RoundedButton(
      text: MyStrings.no.tr,
      press: () {
        Navigator.pop(context);
      },
      horizontalPadding: 3,
      verticalPadding: 3,
      color: MyColor.getTextFieldHintColor(),
    ),
    btnOk: RoundedButton(
        text: MyStrings.yes.tr,
        press: () {
          SystemNavigator.pop();
        },
        horizontalPadding: 3,
        verticalPadding: 3,
        color: MyColor.colorRed,
        textColor: MyColor.colorWhite),
    btnCancelOnPress: () {},
    btnOkOnPress: () {
      SystemNavigator.pop();
    },
  ).show();
}
