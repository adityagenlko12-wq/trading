import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../data/controller/deposit/deposit_history_controller.dart';
import '../../../components/text/label_text.dart';

class DepositHistoryTop extends StatefulWidget {
  const DepositHistoryTop({super.key});

  @override
  State<DepositHistoryTop> createState() => _DepositHistoryTopState();
}

class _DepositHistoryTopState extends State<DepositHistoryTop> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositHistoryController>(
      builder: (controller) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          color: MyColor.getScreenBgSecondaryColor(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LabelText(text: MyStrings.trxNo),
            const SizedBox(height: Dimensions.space10),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            cursorColor: MyColor.getPrimaryColor(),
                            style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                            keyboardType: TextInputType.text,
                            controller: controller.searchController,
                            decoration: InputDecoration(
                                hintText: MyStrings.enterTransactionNo.tr,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                hintStyle: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                                filled: true,
                                fillColor: MyColor.transparentColor,
                                border: OutlineInputBorder(borderSide: BorderSide(color: MyColor.getTextFieldDisableBorder(), width: 0.5)),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColor.getTextFieldDisableBorder(), width: 0.5)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColor.getTextFieldEnableBorder(), width: 0.5))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      controller.searchDepositTrx();
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: MyColor.primaryColor,
                      ),
                      child: const Icon(Icons.search_outlined, color: MyColor.colorWhite, size: 18),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
