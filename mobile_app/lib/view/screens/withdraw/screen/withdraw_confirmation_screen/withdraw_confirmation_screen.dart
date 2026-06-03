import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/util.dart';
import 'package:vinance/data/model/kyc/kyc_form_model.dart';
import 'package:vinance/view/components/text/label_text_with_instructions.dart';
import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../data/controller/withdraw/withdraw_confirm_controller.dart';
import '../../../../../data/model/withdraw/withdraw_request_response_model.dart';
import '../../../../../data/repo/account/profile_repo.dart';
import '../../../../../data/services/api_service.dart';
import '../../../../components/app-bar/app_main_appbar.dart';
import '../../../../components/buttons/rounded_button.dart';
import '../../../../components/checkbox/custom_check_box.dart';
import '../../../../components/custom_loader/custom_loader.dart';
import '../../../../components/custom_radio_button.dart';
import '../../../../components/divider/custom_spacer.dart';
import '../../../../components/text-form-field/custom_drop_down_text_field.dart';
import '../../../../components/text-form-field/custom_text_field.dart';
import 'widget/choose_file_list_item.dart';

class WithdrawConfirmationScreen extends StatefulWidget {
  const WithdrawConfirmationScreen({super.key});

  @override
  State<WithdrawConfirmationScreen> createState() => _WithdrawConfirmationScreenState();
}

class _WithdrawConfirmationScreenState extends State<WithdrawConfirmationScreen> {
  String gatewayName = '';
  String withdrawDescription = '';

  @override
  void initState() {
    gatewayName = Get.arguments[1];
    withdrawDescription = Get.arguments[2];
    WithdrawRequestResponseModel model = Get.arguments[0];
    //String trxId = Get.arguments;
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    final controller = Get.put(WithdrawConfirmController(repo: Get.find(), profileRepo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initData(model);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawConfirmController>(
      builder: (controller) => Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: AppMainAppBar(
            isTitleCenter: true,
            isProfileCompleted: true,
            title: '${MyStrings.withdrawVia} $gatewayName',
            bgColor: MyColor.transparentColor,
            titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
            actions: [
              horizontalSpace(Dimensions.space10),
            ],
          ),
          body: controller.isLoading
              ? const CustomLoader()
              : SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HtmlWidget(
                        withdrawDescription,
                        textStyle: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                        onLoadingBuilder: (context, element, loadingProgress) => const Center(
                          child: CustomLoader(),
                        ),
                      ),
                      verticalSpace(Dimensions.space25),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: controller.formList.length,
                          itemBuilder: (ctx, index) {
                            KycFormModel model = controller.formList[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (MyUtils.getInputType(model.type ?? "text")) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextField(
                                        hintText: '${((model.name ?? '').capitalizeFirst)?.tr}',
                                        animatedLabel: false,
                                        needOutlineBorder: true,
                                        instructions: model.instruction,
                                        labelText: (model.name ?? '').tr,
                                        isRequired: model.isRequired == 'optional' ? false : true,
                                        onChanged: (value) {
                                          controller.changeSelectedValue(value, index);
                                        },
                                        textInputType: MyUtils.getInputTextFieldType(model.type ?? "text"),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
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
                                            instructions: model.instruction,
                                            onChanged: (value) {
                                              controller.changeSelectedValue(value, index);
                                            },
                                            textInputType: MyUtils.getInputTextFieldType(model.type ?? "text"),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
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
                      if (controller.isTwoFactorRequired) ...[
                        CustomTextField(
                          animatedLabel: false,
                          needOutlineBorder: true,
                          isRequired: true,
                          controller: controller.googleAuthenticatorCodeController,
                          labelText: MyStrings.googleAuthenticatorCode.tr,
                          hintText: MyStrings.googleAuthenticatorCodeHint.tr,
                          onChanged: (value) {},
                          textInputType: TextInputType.text,
                          inputAction: TextInputAction.done,
                          fillColor: MyColor.getScreenBgColor(),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return MyStrings.fieldErrorMsg.tr;
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                      verticalSpace(Dimensions.space15),
                      RoundedButton(
                        isLoading: controller.submitLoading,
                        horizontalPadding: Dimensions.space10,
                        verticalPadding: Dimensions.space15,
                        text: MyStrings.submit.tr,
                        press: () {
                          controller.submitConfirmWithdrawRequest();
                        },
                        cornerRadius: 8,
                        isOutlined: false,
                        color: MyColor.getPrimaryButtonColor(),
                      ),
                    ],
                  ),
                )),
    );
  }
}
