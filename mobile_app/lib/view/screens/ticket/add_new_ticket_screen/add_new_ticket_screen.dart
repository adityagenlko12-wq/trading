import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/support/new_ticket_controller.dart';
import 'package:vinance/data/repo/support/support_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/app-bar/app_main_appbar.dart';
import 'package:vinance/view/components/buttons/circle_icon_button.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/image/custom_svg_picture.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/label_text.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddNewSupportTicketScreen extends StatefulWidget {
  const AddNewSupportTicketScreen({super.key});

  @override
  State<AddNewSupportTicketScreen> createState() => _AddNewSupportTicketScreenState();
}

class _AddNewSupportTicketScreenState extends State<AddNewSupportTicketScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    Get.put(NewTicketController(repo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewTicketController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          title: MyStrings.addNewTicket.tr,
          isTitleCenter: true,
          isProfileCompleted: true,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
        ),
        body: controller.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.textToTextSpace),
                      CustomTextField(
                        labelText: MyStrings.subject.tr,
                        hintText: MyStrings.enterYourSubject.tr,
                        controller: controller.subjectController,
                        isPassword: false,
                        isShowSuffixIcon: false,
                        needOutlineBorder: true,
                        nextFocus: controller.messageFocusNode,
                        onSuffixTap: () {},
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      LabelText(text: MyStrings.priority.tr),
                      const SizedBox(height: Dimensions.space5),
                      DropDownTextFieldContainer(
                        color: MyColor.getTextFieldFillColor(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: DropdownButton<String>(
                            dropdownColor: MyColor.getScreenBgSecondaryColor(),
                            value: controller.selectedPriority,
                            elevation: 8,
                            icon: SvgPicture.asset(
                              MyIcons.arrowDown,
                              colorFilter: const ColorFilter.mode(MyColor.primaryColor, BlendMode.srcIn),
                            ),
                            iconDisabledColor: Colors.grey,
                            iconEnabledColor: MyColor.primaryColor,
                            isExpanded: true,
                            underline: Container(
                              height: 0,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              controller.setPriority(newValue);
                            },
                            items: controller.priorityList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: regularDefault.copyWith(fontSize: Dimensions.fontDefault, color: MyColor.getLabelTextColor()),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      CustomTextField(
                        labelText: MyStrings.message.tr,
                        needOutlineBorder: true,
                        hintText: MyStrings.enterYourMessage.tr,
                        isPassword: false,
                        controller: controller.messageController,
                        maxLines: 5,
                        focusNode: controller.messageFocusNode,
                        isShowSuffixIcon: false,
                        onSuffixTap: () {},
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      LabelText(text: MyStrings.attachments.tr),
                      const SizedBox(height: Dimensions.textToTextSpace),
                      if (controller.attachmentList.length < 5) ...[
                        ZoomTapAnimation(
                          onTap: () {
                            controller.pickFile();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space30),
                            margin: const EdgeInsets.only(top: Dimensions.space5),
                            width: context.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                              color: MyColor.getScreenBgSecondaryColor(),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.attachment_rounded,
                                  color: MyColor.getPrimaryTextColor(),
                                ),
                                Text(
                                  MyStrings.chooseFile.tr,
                                  style: regularSmall.copyWith(color: MyColor.getTextFieldHintColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.space2),
                        Text(MyStrings.supportedFileHint, style: regularSmall.copyWith(color: MyColor.getSecondaryTextColor())),
                      ],
                      const SizedBox(height: Dimensions.space10),
                      controller.attachmentList.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(
                                  controller.attachmentList.length,
                                  (index) => Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(Dimensions.space5),
                                            decoration: const BoxDecoration(),
                                            child: controller.isImage(controller.attachmentList[index].path)
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                    child: Image.file(
                                                      controller.attachmentList[index],
                                                      width: context.width / 5,
                                                      height: context.width / 5,
                                                      fit: BoxFit.cover,
                                                    ))
                                                : controller.isXlsx(controller.attachmentList[index].path)
                                                    ? Container(
                                                        width: context.width / 5,
                                                        height: context.width / 5,
                                                        decoration: BoxDecoration(
                                                          color: MyColor.colorWhite,
                                                          borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                          border: Border.all(color: MyColor.borderColor, width: 1),
                                                        ),
                                                      )
                                                    : controller.isDoc(controller.attachmentList[index].path)
                                                        ? Container(
                                                            width: context.width / 5,
                                                            height: context.width / 5,
                                                            decoration: BoxDecoration(
                                                              color: MyColor.colorWhite,
                                                              borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                              border: Border.all(color: MyColor.borderColor, width: 1),
                                                            ),
                                                            child: const Center(
                                                              child: CustomSvgPicture(
                                                                image: MyIcons.doc,
                                                                height: 45,
                                                                width: 45,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            width: context.width / 5,
                                                            height: context.width / 5,
                                                            decoration: BoxDecoration(
                                                              color: MyColor.colorWhite,
                                                              borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                              border: Border.all(color: MyColor.borderColor, width: 1),
                                                            ),
                                                            child: const Center(
                                                              child: CustomSvgPicture(
                                                                image: MyIcons.xlsx,
                                                                height: 45,
                                                                width: 45,
                                                              ),
                                                            ),
                                                          ),
                                          ),
                                          CircleIconButton(
                                            onTap: () {
                                              controller.removeAttachmentFromList(index);
                                            },
                                            height: Dimensions.space20,
                                            width: Dimensions.space20,
                                            backgroundColor: MyColor.colorRed,
                                            child: const Icon(
                                              Icons.close,
                                              color: MyColor.colorWhite,
                                              size: Dimensions.space12,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 30),
                      Center(
                        child: RoundedButton(
                          isLoading: controller.submitLoading,
                          verticalPadding: Dimensions.space15,
                          cornerRadius: Dimensions.space8,
                          color: MyColor.getPrimaryColor(),
                          text: MyStrings.submit.tr,
                          press: () {
                            controller.submit();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class DropDownTextFieldContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  const DropDownTextFieldContainer({super.key, required this.child, this.color = MyColor.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
        border: Border.all(color: MyColor.getTextFieldFillColor(), width: .5),
      ),
      child: child,
    );
  }
}
