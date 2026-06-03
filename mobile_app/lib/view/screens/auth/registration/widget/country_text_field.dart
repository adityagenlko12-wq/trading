import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';

import '../../../../components/text/label_text.dart';

class CountryTextField extends StatelessWidget {
  final String text;
  final VoidCallback press;

  const CountryTextField({super.key, required this.text, required this.press});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabelText(text: MyStrings.selectACountry, isRequired: false),
        const SizedBox(height: Dimensions.textToTextSpace),
        InkWell(
          onTap: press,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
            decoration: BoxDecoration(
              color: MyColor.getTextFieldFillColor(),
              borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
              border: Border.all(
                color: MyColor.getTextFieldFillColor(),
                width: .5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(text.tr, style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor())),
                Icon(
                  Icons.expand_more_rounded,
                  color: MyColor.getTextFieldHintColor(),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
