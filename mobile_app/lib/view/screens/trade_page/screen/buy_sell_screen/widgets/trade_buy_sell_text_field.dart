import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

class TradeBuySellWidgetTextField extends StatefulWidget {
  const TradeBuySellWidgetTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.chargeText = '',
    required this.onChanged,
    this.autoFocus = false,
    this.inputAction,
    this.readOnly = false,
    this.disable = false,
    this.prefixWidget,
    this.suffixWidget,
    this.textInputType,
    this.onTap,
    this.inputFormatters,
    this.inputTextAlign,
  });

  final String chargeText;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final bool autoFocus;
  final bool readOnly;
  final bool disable;
  final String? labelText;
  final Function(String) onChanged;
  final Function()? onTap;
  final TextEditingController? controller;
  final TextInputAction? inputAction;
  final TextAlign? inputTextAlign;

  @override
  State<TradeBuySellWidgetTextField> createState() => _TradeBuySellWidgetTextFieldState();
}

class _TradeBuySellWidgetTextFieldState extends State<TradeBuySellWidgetTextField> {
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
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: 0),
          decoration: BoxDecoration(color: widget.disable ? MyColor.getScreenBgSecondaryColor().withOpacity(0.5) : MyColor.getScreenBgSecondaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius2)),
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
                      style: semiBoldDefault.copyWith(color: widget.disable ? MyColor.getSecondaryTextColor().withOpacity(0.3) : MyColor.getPrimaryTextColor()),
                      textAlign: widget.inputTextAlign ?? TextAlign.center,
                      keyboardType: widget.textInputType,
                      textInputAction: widget.inputAction,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      decoration: InputDecoration(
                        labelStyle: regularDefault.copyWith(
                          color: MyColor.getTextFieldHintColor(),
                        ),
                        label: widget.hintText != null
                            ? Center(
                                child: Text(
                                  widget.hintText ?? '',
                                  style: regularDefault.copyWith(color: MyColor.getTextFieldHintColor()),
                                ),
                              )
                            : null,
                        isDense: true,

                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        // labelText: widget.hintText,
                        // hintText: widget.hintText,
                        hintStyle: regularDefault.copyWith(
                          color: MyColor.getTextFieldHintColor(),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                      onTap: widget.onTap,
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
