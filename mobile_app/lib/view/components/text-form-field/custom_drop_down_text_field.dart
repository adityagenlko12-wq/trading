import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/text/label_text.dart';

class CustomDropDownTextField extends StatefulWidget {
  final dynamic selectedValue;
  final String? labelText;
  final String? hintText;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final Color? fillColor;
  final Color? focusColor;
  final Color? dropDownColor;
  final Color? iconColor;
  final double radius;
  final bool needLabel;

  const CustomDropDownTextField({super.key, this.labelText, this.hintText, required this.selectedValue, required this.onChanged, required this.items, this.fillColor = MyColor.transparentColor, this.focusColor = MyColor.colorWhite, this.dropDownColor = MyColor.colorWhite, this.iconColor = MyColor.colorGrey, this.radius = 3, this.needLabel = true});

  @override
  State<CustomDropDownTextField> createState() => _CustomDropDownTextFieldState();
}

class _CustomDropDownTextFieldState extends State<CustomDropDownTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.needLabel ? LabelText(text: widget.labelText.toString()) : const SizedBox(),
        widget.needLabel ? const SizedBox(height: Dimensions.textToTextSpace) : const SizedBox(),
        SizedBox(
          height: 50,
          child: DropdownButtonFormField(
            value: widget.selectedValue,
            dropdownColor: widget.dropDownColor,
         
            focusColor: widget.focusColor,
           
            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
            alignment: Alignment.centerLeft,
            decoration: InputDecoration(
             
              filled: true,
           
              hintText: widget.hintText != null ? widget.hintText!.tr : '',
              hintStyle: regularLarge.copyWith(color: MyColor.getTextFieldHintColor()),
              fillColor: widget.fillColor ?? MyColor.getTextFieldFillColor(),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              border: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
              errorBorder: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldEnableBorder()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldFillColor()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                borderSide: const BorderSide(color: MyColor.textFieldDisableBorderColor, width: 1),
              ),
            ),
            isExpanded: false,
            onChanged: widget.onChanged,
            items: widget.items,
            icon: Icon(Icons.arrow_drop_down, color: widget.iconColor),
          ),
        )
      ],
    );
  }
}
