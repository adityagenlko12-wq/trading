import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vinance/core/utils/style.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';

class OTPFieldWidget extends StatelessWidget {
  const OTPFieldWidget({super.key, required this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boxSize = screenSize.width < 400
        ? const Size(42, 42)
        : screenSize.width < 600
            ? const Size(50, 50)
            : const Size(55, 55);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
      child: PinCodeTextField(
        appContext: context,
        pastedTextStyle: regularDefault.copyWith(color: MyColor.getPrimaryColor()),
        length: 6,
        textStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
        obscureText: false,
        obscuringCharacter: '*',
        blinkWhenObscuring: false,
        animationType: AnimationType.fade,
        cursorColor: MyColor.getPrimaryTextColor(),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderWidth: 1,
          fieldOuterPadding: const EdgeInsetsDirectional.all(0),
          borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
          fieldHeight: boxSize.width,
          fieldWidth: boxSize.height,
          
          inactiveColor: MyColor.getTextFieldFillColor(),
          inactiveFillColor: MyColor.getTextFieldFillColor(),
          activeFillColor: MyColor.getTextFieldFillColor(),
          activeColor: MyColor.getPrimaryColor().withOpacity(0.3),
          selectedFillColor: MyColor.getTextFieldFillColor(),
          selectedColor: MyColor.getPrimaryColor(),
        ),
        animationDuration: const Duration(milliseconds: 100),
        enableActiveFill: true,
        keyboardType: TextInputType.number,
        beforeTextPaste: (text) {
          return true;
        },
        onChanged: (value) => onChanged!(value),
      ),
    );
  }
}
