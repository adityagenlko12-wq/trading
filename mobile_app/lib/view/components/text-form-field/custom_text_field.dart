import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/text/label_text_with_instructions.dart';

class CustomTextField extends StatefulWidget {
  final String? instructions;
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
  final Color? fillColor;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.instructions,
    this.labelText,
    this.readOnly = false,
    this.fillColor,
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
    this.inputFormatters,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return widget.needOutlineBorder
        ? widget.animatedLabel
            ? TextFormField(
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                //textAlign: TextAlign.left,
                cursorColor: MyColor.getPrimaryTextColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                decoration: InputDecoration(
                  errorStyle: regularLarge.copyWith(color: MyColor.colorRed),
                  contentPadding: const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
                  labelText: widget.labelText?.tr ?? '',
                  labelStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
                  fillColor: widget.fillColor ?? MyColor.getTextFieldFillColor(),
                  filled: true,
                  border: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                  errorBorder: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldEnableBorder()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldFillColor()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: MyColor.getTextFieldHintColor(), size: 20), onPressed: _toggle)
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
                inputFormatters: widget.inputFormatters,
                onFieldSubmitted: (text) => widget.nextFocus != null ? FocusScope.of(context).requestFocus(widget.nextFocus) : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.labelText != null) ...[
                    LabelTextInstruction(
                      text: widget.labelText.toString().tr,
                      isRequired: widget.isRequired,
                      instructions: widget.instructions,
                    ),
                    const SizedBox(height: Dimensions.textToTextSpace),
                  ],
                  TextFormField(
                    maxLines: widget.maxLines,
                    readOnly: widget.readOnly,
                    style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),

                    //textAlign: TextAlign.left,
                    cursorColor: MyColor.getPrimaryTextColor(),
                    controller: widget.controller,
                    autofocus: false,
                    textInputAction: widget.inputAction,
                    enabled: widget.isEnable,
                    focusNode: widget.focusNode,
                    validator: widget.validator,
                    keyboardType: widget.textInputType,
                    obscureText: widget.isPassword ? obscureText : false,
                    inputFormatters: widget.inputFormatters,
                    decoration: InputDecoration(
                      errorStyle: regularLarge.copyWith(color: MyColor.colorRed),
                      contentPadding: EdgeInsets.only(top: widget.maxLines > 1 ? 15 : 5, left: 15, right: 15, bottom: 5),
                      hintText: widget.hintText != null ? widget.hintText!.tr : '',
                      hintStyle: regularLarge.copyWith(color: MyColor.getTextFieldHintColor()),
                      fillColor: widget.fillColor ?? MyColor.getTextFieldFillColor(),
                      filled: true,
                      border: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                      errorBorder: OutlineInputBorder(borderSide: const BorderSide(width: 0.8, color: MyColor.colorRed), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldEnableBorder()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldFillColor()), borderRadius: BorderRadius.circular(Dimensions.cardRadius1)),
                      suffixIcon: widget.isShowSuffixIcon
                          ? widget.isPassword
                              ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: MyColor.getPrimaryTextColor().withOpacity(0.8), size: 20), onPressed: _toggle)
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
                    onTap: widget.onTap,
                  )
                ],
              )
        : TextFormField(
            maxLines: widget.maxLines,
            readOnly: widget.readOnly,
            style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
            //textAlign: TextAlign.left,
            cursorColor: MyColor.getTextFieldHintColor(),
            controller: widget.controller,
            autofocus: false,
            textInputAction: widget.inputAction,
            enabled: widget.isEnable,
            focusNode: widget.focusNode,
            validator: widget.validator,
            keyboardType: widget.textInputType,
            obscureText: widget.isPassword ? obscureText : false,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 5, left: 0, right: 0, bottom: 5),
              labelText: widget.labelText?.tr,
              labelStyle: regularDefault.copyWith(color: MyColor.getLabelTextColor()),
              fillColor: MyColor.transparentColor,
              filled: true,
              border: UnderlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldDisableBorder())),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldEnableBorder())),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0.8, color: MyColor.getTextFieldDisableBorder())),
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
            onTap: widget.onTap,
          );
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}
