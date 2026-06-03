import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

class CustomPrimaryTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final bool isShowSuffixIcon;
  final bool isIcon;
  final VoidCallback? onSuffixTap;
  final bool isSearch;
  final bool isCountryPicker;
  final TextInputAction inputAction;
  final bool needOutlineBorder;
  final bool readOnly;
  final bool needRequiredSign;
  final int maxLines;
  final bool animatedLabel;
  final Color fillColor;
  final bool isRequired;

  const CustomPrimaryTextField({
    super.key,
    this.labelText,
    this.readOnly = false,
    this.fillColor = MyColor.transparentColor,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.textInputType,
    this.isEnable = true,
    this.isPassword = false,
    this.isShowSuffixIcon = false,
    this.isIcon = false,
    this.onSuffixTap,
    this.isSearch = false,
    this.isCountryPicker = false,
    this.inputAction = TextInputAction.next,
    this.needOutlineBorder = false,
    this.needRequiredSign = false,
    this.maxLines = 1,
    this.animatedLabel = false,
    this.isRequired = false,
  });

  @override
  State<CustomPrimaryTextField> createState() => _CustomPrimaryTextFieldState();
}

class _CustomPrimaryTextFieldState extends State<CustomPrimaryTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      readOnly: widget.readOnly,
      style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
      //textAlign: TextAlign.left,
      
      cursorColor: MyColor.getPrimaryColor(),
      controller: widget.controller,
      autofocus: false,
      textInputAction: widget.inputAction,
      enabled: widget.isEnable,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.textInputType,
      obscureText: widget.isPassword ? obscureText : false,
    
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 15),
        labelText: widget.labelText?.tr,
        labelStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor().withOpacity(0.8)),
        
        fillColor: MyColor.transparentColor,
        filled: true,
        border: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: MyColor.getTextFieldDisableBorder())),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: MyColor.getPrimaryColor())),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: MyColor.getTextFieldDisableBorder())),
        suffixIcon: widget.isShowSuffixIcon
            ? widget.isPassword
                ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: MyColor.getTextFieldHintColor(), size: 20), onPressed: _toggle)
                : widget.isIcon
                    ? IconButton(
                        onPressed: widget.onSuffixTap,
                        icon: Icon(
                          widget.isSearch
                              ? Icons.search_outlined
                              : widget.isCountryPicker
                                  ? Icons.arrow_drop_down_outlined
                                  : Icons.camera_alt_outlined,
                          size: 25,
                          color: MyColor.getPrimaryColor(),
                        ),
                      )
                    : null
            : null,
      ),
      onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
      onChanged: (text) => widget.onChanged!(text),
    );
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}
