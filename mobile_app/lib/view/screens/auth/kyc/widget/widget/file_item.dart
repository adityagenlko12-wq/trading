import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/data/controller/kyc_controller/kyc_controller.dart';
import 'package:vinance/data/model/kyc/kyc_form_model.dart';
import 'package:vinance/view/screens/auth/kyc/widget/widget/choose_file_list_item.dart';

class ConfirmWithdrawFileItem extends StatefulWidget {
  final int index;

  const ConfirmWithdrawFileItem({super.key, required this.index});

  @override
  State<ConfirmWithdrawFileItem> createState() => _ConfirmWithdrawFileItemState();
}

class _ConfirmWithdrawFileItemState extends State<ConfirmWithdrawFileItem> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(builder: (controller) {
      KycFormModel? model = controller.formList[widget.index];
      return InkWell(
          onTap: () {
            controller.pickFile(widget.index);
          },
          child: ChooseFileItem(fileName: model.selectedValue ?? MyStrings.chooseFile));
    });
  }
}
