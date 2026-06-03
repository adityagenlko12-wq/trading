import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

class CustomWidgetTextField extends StatefulWidget {
  const CustomWidgetTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.controller,
    this.chargeText = '',
    required this.onChanged,
    this.autoFocus = false,
    this.inputAction,
    this.readOnly = false,
    this.prefixWidget,
    this.suffixWidget,
    this.textInputType,
    this.inputFormatters,
    this.inputTextAlign,
  });

  final String chargeText;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final bool autoFocus;
  final bool readOnly;
  final String? labelText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final TextInputAction? inputAction;
  final TextAlign? inputTextAlign;

  @override
  State<CustomWidgetTextField> createState() => _CustomWidgetTextFieldState();
}

class _CustomWidgetTextFieldState extends State<CustomWidgetTextField> {
  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!.tr,
            style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
          ),
          const SizedBox(
            height: Dimensions.space10,
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: 8),
          decoration: BoxDecoration(color: MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefixWidget != null) ...[widget.prefixWidget!],
              Expanded(
                child: FocusScope(
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        isFocus = focus;
                      });
                    },
                    child: TextFormField(
                      scrollPadding: EdgeInsets.zero,
                      cursorColor: MyColor.getPrimaryTextColor(),
                      readOnly: widget.readOnly,
                      controller: widget.controller,
                      autofocus: widget.autoFocus,
                      style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                      textAlign: widget.inputTextAlign ?? TextAlign.center,
                      keyboardType: widget.textInputType,
                      textInputAction: widget.inputAction,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(Dimensions.space10),
                        hintText: widget.hintText,
                        hintStyle: regularLarge.copyWith(color: MyColor.getTextFieldHintColor()),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.suffixWidget != null) ...[widget.suffixWidget!],
            ],
          ),
        ),
      ],
    );
  }
}
