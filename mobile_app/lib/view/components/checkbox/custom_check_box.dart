import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/style.dart';

import '../../../core/utils/dimensions.dart';

class CustomCheckBox extends StatefulWidget {
  final List<String>? selectedValue;
  final List<String> list;
  final ValueChanged? onChanged;

  const CustomCheckBox({
    super.key,
    this.selectedValue,
    required this.list,
    this.onChanged,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    if (widget.list.isEmpty) {
      return Container();
    }
    return Column(
      children: [
        Column(
            children: List<CheckboxListTile>.generate(widget.list.length, (int index) {
          List<String>? s = widget.selectedValue;
          bool selected_ = s != null ? s.contains(widget.list[index]) : false;
          return CheckboxListTile(
            value: selected_,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
            activeColor: MyColor.primaryColor500,
            checkColor: MyColor.getPrimaryTextColor(),
            fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return MyColor.primaryColor500.withOpacity(.32);
              }
              return MyColor.primaryColor500.withOpacity(0.2);
            }),
            side: WidgetStateBorderSide.resolveWith(
              (states) => const BorderSide(
                width: 1.0,
                color: MyColor.primaryColor500,
              ),
            ),
            title: Text(
              widget.list[index].tr,
              style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
            ),
            onChanged: (bool? value) {
              setState(() {
                if (value != null) {
                  widget.onChanged!('${index}_$value');
                }
              });
            },
          );
        })),
      ],
    );
  }
}
