import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/util.dart';
import 'package:vinance/data/controller/kyc_controller/kyc_controller.dart';
import 'package:vinance/data/model/kyc/kyc_form_model.dart';
import 'package:vinance/data/repo/kyc/kyc_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/checkbox/custom_check_box.dart';
import 'package:vinance/view/components/custom_loader/custom_loader.dart';
import 'package:vinance/view/components/custom_radio_button.dart';
import 'package:vinance/view/components/no_data.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/label_text_with_instructions.dart';
import 'package:vinance/view/screens/auth/kyc/widget/already_verifed.dart';

import '../../../../core/utils/style.dart';
import '../../../components/app-bar/app_main_appbar.dart';
import '../../../components/divider/custom_spacer.dart';
import '../../../components/text-form-field/custom_drop_down_text_field.dart';
import 'widget/widget/choose_file_list_item.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KycRepo(apiClient: Get.find()));
    Get.put(KycController(repo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KycController>().beforeInitLoadKycData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: controller.isAlreadyPending ? MyStrings.kycUnderReviewMsg.tr.toCapitalized() : MyStrings.kycVerify,
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: controller.isLoading
                  ? const Padding(padding: EdgeInsets.all(Dimensions.space15), child: CustomLoader())
                  : controller.isAlreadyVerified
                      ? const AlreadyVerifiedWidget()
                      : controller.isAlreadyPending
                          ? const AlreadyVerifiedWidget(
                              isPending: true,
                            )
                          : controller.isNoDataFound
                              ? const NoDataWidget()
                              : Center(
                                  child: SingleChildScrollView(
                                    padding: Dimensions.screenPaddingHV,
                                    child: Form(
                                      key: formKey,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: Dimensions.space15, horizontal: Dimensions.space15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.vertical,
                                                itemCount: controller.formList.length,
                                                itemBuilder: (ctx, index) {
                                                  KycFormModel? model = controller.formList[index];
                                                  return Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (MyUtils.getInputType(model.type ?? "text")) ...[
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            CustomTextField(
                                                              instructions: model.instruction,
                                                              hintText: '${((model.name ?? '').capitalizeFirst)?.tr}',
                                                              animatedLabel: false,
                                                              needOutlineBorder: true,
                                                              labelText: (model.name ?? '').tr,
                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                              textInputType: MyUtils.getInputTextFieldType(model.type ?? "text"),
                                                              onChanged: (value) {
                                                                controller.changeSelectedValue(value, index);
                                                              },
                                                            ),
                                                            const SizedBox(height: 10),
                                                          ],
                                                        )
                                                      ],
                                                      model.type == 'textarea'
                                                          ? Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                CustomTextField(
                                                                  animatedLabel: false,
                                                                  needOutlineBorder: true,
                                                                  labelText: (model.name ?? '').tr,
                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                  hintText: '${((model.name ?? '').capitalizeFirst)?.tr}',
                                                                  onChanged: (value) {
                                                                    controller.changeSelectedValue(value, index);
                                                                  },
                                                                ),
                                                                const SizedBox(height: 10),
                                                              ],
                                                            )
                                                          : model.type == 'select'
                                                              ? Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    LabelTextInstruction(
                                                                      text: model.name ?? '',
                                                                      isRequired: model.isRequired == 'optional' ? false : true,
                                                                      instructions: model.instruction,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    CustomDropDownTextField(
                                                                      dropDownColor: MyColor.getScreenBgSecondaryColor(),
                                                                      needLabel: false,
                                                                      fillColor: MyColor.getScreenBgSecondaryColor(),
                                                                      items: model.options?.map((String value) {
                                                                        return DropdownMenuItem<String>(
                                                                          value: value,
                                                                          child: Text(
                                                                            value.tr,
                                                                          ),
                                                                        );
                                                                      }).toList(),
                                                                      onChanged: (value) {
                                                                        controller.changeSelectedValue(value, index);
                                                                      },
                                                                      selectedValue: model.selectedValue,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                  ],
                                                                )
                                                              : model.type == 'radio'
                                                                  ? Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        LabelTextInstruction(
                                                                          text: model.name ?? '',
                                                                          isRequired: model.isRequired == 'optional' ? false : true,
                                                                          instructions: model.instruction,
                                                                        ),
                                                                        CustomRadioButton(
                                                                          title: model.name,
                                                                          selectedIndex: controller.formList[index].options?.indexOf(model.selectedValue ?? '') ?? 0,
                                                                          list: model.options ?? [],
                                                                          onChanged: (selectedIndex) {
                                                                            controller.changeSelectedRadioBtnValue(index, selectedIndex);
                                                                          },
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : model.type == 'checkbox'
                                                                      ? Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            const SizedBox(height: Dimensions.space25),
                                                                            LabelTextInstruction(
                                                                              text: model.name ?? '',
                                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                                              instructions: model.instruction,
                                                                            ),
                                                                            CustomCheckBox(
                                                                              selectedValue: controller.formList[index].cbSelected,
                                                                              list: model.options ?? [],
                                                                              onChanged: (value) {
                                                                                controller.changeSelectedCheckBoxValue(index, value);
                                                                              },
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : model.type == 'file'
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                LabelTextInstruction(
                                                                                  text: model.name ?? '',
                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                  instructions: model.instruction,
                                                                                ),
                                                                                Padding(
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                      vertical: 15,
                                                                                    ),
                                                                                    child: SizedBox(
                                                                                      child: InkWell(
                                                                                          onTap: () {
                                                                                            controller.pickFile(index);
                                                                                          },
                                                                                          child: ChooseFileItem(
                                                                                            fileName: model.selectedValue ?? MyStrings.chooseFile.tr,
                                                                                          )),
                                                                                    ))
                                                                              ],
                                                                            )
                                                                          : model.type == 'datetime'
                                                                              ? Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                      child: CustomTextField(
                                                                                          instructions: model.instruction,
                                                                                          isRequired: model.isRequired == 'optional' ? false : true,
                                                                                          hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                          needOutlineBorder: true,
                                                                                          labelText: model.name ?? '',
                                                                                          controller: controller.formList[index].textEditingController,
                                                                                          // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                          textInputType: TextInputType.datetime,
                                                                                          readOnly: true,
                                                                                          validator: (value) {
                                                                                            printx(model.isRequired);
                                                                                            if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                              return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                            } else {
                                                                                              return null;
                                                                                            }
                                                                                          },
                                                                                          onTap: () {
                                                                                            controller.changeSelectedDateTimeValue(index, context);
                                                                                          },
                                                                                          onChanged: (value) {
                                                                                            printx(value);
                                                                                            controller.changeSelectedValue(value, index);
                                                                                          }),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              : model.type == 'date'
                                                                                  ? Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                          child: CustomTextField(
                                                                                              instructions: model.instruction,
                                                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                                                              hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                              needOutlineBorder: true,
                                                                                              labelText: model.name ?? '',
                                                                                              controller: controller.formList[index].textEditingController,
                                                                                              // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                              textInputType: TextInputType.datetime,
                                                                                              readOnly: true,
                                                                                              validator: (value) {
                                                                                                printx(model.isRequired);
                                                                                                if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                  return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                } else {
                                                                                                  return null;
                                                                                                }
                                                                                              },
                                                                                              onTap: () {
                                                                                                controller.changeSelectedDateOnlyValue(index, context);
                                                                                              },
                                                                                              onChanged: (value) {
                                                                                                printx(value);
                                                                                                controller.changeSelectedValue(value, index);
                                                                                              }),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : model.type == 'time'
                                                                                      ? Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                              child: CustomTextField(
                                                                                                  instructions: model.instruction,
                                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                  hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                                  needOutlineBorder: true,
                                                                                                  labelText: model.name ?? '',
                                                                                                  controller: controller.formList[index].textEditingController,
                                                                                                  // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                  textInputType: TextInputType.datetime,
                                                                                                  readOnly: true,
                                                                                                  validator: (value) {
                                                                                                    printx(model.isRequired);
                                                                                                    if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                      return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                    } else {
                                                                                                      return null;
                                                                                                    }
                                                                                                  },
                                                                                                  onTap: () {
                                                                                                    controller.changeSelectedTimeOnlyValue(index, context);
                                                                                                  },
                                                                                                  onChanged: (value) {
                                                                                                    printx(value);
                                                                                                    controller.changeSelectedValue(value, index);
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : const SizedBox(),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  );
                                                }),
                                            const SizedBox(height: Dimensions.space25),
                                            Center(
                                              child: RoundedButton(
                                                isLoading: controller.submitLoading,
                                                press: () {
                                                  if (formKey.currentState!.validate()) {
                                                    controller.submitKycData();
                                                  }
                                                },
                                                text: MyStrings.submit,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
        ),
      ),
    );
  }
}
