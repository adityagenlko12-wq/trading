import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/date_converter.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/my_icons.dart';
import 'package:vinance/core/utils/my_images.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/controller/support/ticket_details_controller.dart';
import 'package:vinance/data/model/support/support_ticket_view_response_model.dart';
import 'package:vinance/data/repo/support/support_repo.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/view/components/app-bar/app_main_appbar.dart';
import 'package:vinance/view/components/buttons/circle_icon_button.dart';
import 'package:vinance/view/components/buttons/custom_circle_animated_button.dart';
import 'package:vinance/view/components/buttons/rounded_button.dart';
import 'package:vinance/view/components/custom_loader/custom_loader.dart';
import 'package:vinance/view/components/image/custom_svg_picture.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';
import 'package:vinance/view/components/text-form-field/custom_text_field.dart';
import 'package:vinance/view/components/text/label_text.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SupportTicketDetailsScreen extends StatefulWidget {
  const SupportTicketDetailsScreen({super.key});

  @override
  State<SupportTicketDetailsScreen> createState() => _SupportTicketDetailsScreenState();
}

class _SupportTicketDetailsScreenState extends State<SupportTicketDetailsScreen> {
  String title = "";
  @override
  void initState() {
    String ticketId = Get.arguments[0];
    title = Get.arguments[1];
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    var controller = Get.put(TicketDetailsController(repo: Get.find(), ticketId: ticketId));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppMainAppBar(
        title: MyStrings.replyTicket,
        isTitleCenter: true,
        isProfileCompleted: true,
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
      ),
      backgroundColor: MyColor.getScreenBgColor(),
      body: GetBuilder<TicketDetailsController>(builder: (controller) {
        return controller.isLoading
            ? const CustomLoader(isFullScreen: true)
            : SingleChildScrollView(
                padding: Dimensions.defaultPaddingHV,
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: MyColor.getScreenBgSecondaryColor(),
                            border: Border.all(
                              color: Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                                    decoration: BoxDecoration(
                                      color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0").withOpacity(0.2),
                                      border: Border.all(color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0"), width: 1),
                                      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                                    ),
                                    child: Text(
                                      controller.getStatusText(controller.model.data?.myTickets?.status ?? '0'),
                                      style: regularDefault.copyWith(
                                        color: controller.getStatusColor(controller.model.data?.myTickets?.status ?? "0"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                    height: 2,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "[${MyStrings.ticket.tr}#${controller.model.data?.myTickets?.ticket ?? ''}] ${controller.model.data?.myTickets?.subject ?? ''}",
                                      style: semiBoldDefault.copyWith(
                                        color: Theme.of(context).textTheme.titleLarge!.color!,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                            if (controller.model.data?.myTickets?.status != '3')
                              CustomCircleAnimatedButton(
                                onTap: () {
                                  controller.closeTicket(controller.model.data?.myTickets?.id.toString() ?? '-1');
                                },
                                height: 40,
                                width: 40,
                                backgroundColor: MyColor.redCancelTextColor,
                                child: controller.closeLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          color: MyColor.colorWhite,
                                        ),
                                      )
                                    : const Icon(Icons.close_rounded, color: MyColor.colorWhite, size: 20),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: Dimensions.space15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: MyColor.getScreenBgSecondaryColor().withOpacity(0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: controller.replyController,
                              hintText: MyStrings.yourReply.tr,
                              maxLines: 4,
                              onChanged: (value) {},
                              needOutlineBorder: true,
                              labelText: '',
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const SizedBox(height: 20),
                            LabelText(text: MyStrings.attachments.tr),
                            controller.attachmentList.isNotEmpty ? const SizedBox(height: 20) : const SizedBox.shrink(),
                            controller.attachmentList.isNotEmpty
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        //add new photo

                                        //aded photo
                                        Row(
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
                                                                width: context.width / 4,
                                                                height: context.width / 4,
                                                                fit: BoxFit.cover,
                                                              ))
                                                          : Container(
                                                              width: context.width / 4,
                                                              height: context.width / 4,
                                                              decoration: BoxDecoration(
                                                                color: MyColor.colorWhite,
                                                                borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                                border: Border.all(color: MyColor.borderColor, width: 1),
                                                              ),
                                                              child: const Center(
                                                                child: CustomSvgPicture(
                                                                  image: MyIcons.pdfFile,
                                                                  height: 30,
                                                                  width: 30,
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                    CircleIconButton(
                                                      onTap: () {
                                                        controller.removeAttachmentFromList(index);
                                                      },
                                                      height: Dimensions.space25,
                                                      width: Dimensions.space25,
                                                      backgroundColor: MyColor.colorRed,
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: MyColor.colorWhite,
                                                        size: Dimensions.space15,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        //
                                        if (controller.attachmentList.length < 5) ...[
                                          ZoomTapAnimation(
                                            onTap: () {
                                              controller.pickFile();
                                            },
                                            child: Container(
                                              width: context.width / 4,
                                              height: context.width / 4,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                                color: MyColor.getScreenBgSecondaryColor(),
                                              ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Column(
                                                  children: [
                                                    Icon(
                                                      Icons.attachment_rounded,
                                                      color: MyColor.getPrimaryTextColor(),
                                                    ),
                                                    Text(
                                                      MyStrings.addFile.tr,
                                                      style: regularSmall.copyWith(color: MyColor.getTextFieldHintColor()),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  )
                                : ZoomTapAnimation(
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
                            const SizedBox(height: Dimensions.space30),
                            RoundedButton(
                              isLoading: controller.submitLoading,
                              text: MyStrings.reply.tr,
                              press: () {
                                controller.uploadTicketViewReply();
                              },
                            ),
                            const SizedBox(height: Dimensions.space30),
                            controller.messageList.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space20, vertical: Dimensions.space20),
                                    decoration: BoxDecoration(
                                      color: MyColor.bodyTextColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(Dimensions.cardRadius2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          MyStrings.noMSgFound.tr,
                                          style: regularDefault.copyWith(color: MyColor.colorGrey),
                                        ),
                                      ],
                                    ))
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 30),
                                    child: ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: controller.messageList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) => TicketViewCommentReplyModel(
                                        index: index,
                                        messages: controller.messageList[index],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
      }),
    );
  }
}

class TicketViewCommentReplyModel extends StatelessWidget {
  const TicketViewCommentReplyModel({super.key, required this.index, required this.messages});

  final SupportMessage messages;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailsController>(
      builder: (controller) => Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: messages.adminId == "1" ? MyColor.pendingColor.withOpacity(0.1) : MyColor.getScreenBgSecondaryColor(),
          borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
          border: Border.all(
            color: messages.adminId == "1" ? MyColor.pendingColor : MyColor.getBorderColor(),
            strokeAlign: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: ClipOval(
                    child: Image.asset(
                      MyImages.noProfileImage,
                      height: 45,
                      width: 45,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (messages.admin == null)
                          Text(
                            '${messages.ticket?.name}',
                            style: boldDefault.copyWith(color: MyColor.getLabelTextColor()),
                          )
                        else
                          Text(
                            '${messages.admin?.name}',
                            style: boldDefault.copyWith(color: MyColor.getLabelTextColor()),
                          ),
                        Text(
                          messages.adminId == "1" ? MyStrings.admin.tr : MyStrings.you.tr,
                          style: regularDefault.copyWith(color: MyColor.bodyTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateConverter.getFormatedSubtractTime(messages.createdAt ?? ''),
                      style: regularDefault.copyWith(color: MyColor.bodyTextColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                    ),
                    child: Text(
                      messages.message ?? "",
                      style: regularDefault.copyWith(
                        color: MyColor.getSecondaryTextColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (messages.attachments?.isNotEmpty ?? false)
              Container(
                height: MediaQuery.of(context).size.width > 500 ? 100 : 100,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: messages.attachments != null
                        ? List.generate(
                            messages.attachments!.length,
                            (i) => controller.selectedIndex == i
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.space30, vertical: Dimensions.space10),
                                    decoration: BoxDecoration(
                                      color: MyColor.screenBgColor,
                                      borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                    ),
                                    child: SpinKitThreeBounce(
                                      size: 20.0,
                                      color: MyColor.getPrimaryColor(),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      String url = '${UrlContainer.supportImagePath}${messages.attachments?[i].attachment}';
                                      String ext = messages.attachments?[i].attachment!.split('.')[1] ?? 'pdf';
                                     
                                      if (controller.isImage(messages.attachments?[i].attachment.toString() ?? "")) {
                                        Get.toNamed(
                                          RouteHelper.previewImageScreen,
                                          arguments: "${UrlContainer.supportImagePath}${messages.attachments?[i].attachment}",
                                        );
                                      } else {
                                        controller.downloadAttachment(url, messages.attachments?[i].id ?? -1, ext);
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width > 500 ? 100 : 100,
                                      height: MediaQuery.of(context).size.width > 500 ? 100 : 100,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: MyColor.borderColor),
                                        borderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                                      ),
                                      child: controller.isImage(messages.attachments?[i].attachment.toString() ?? "")
                                          ? MyNetworkImageWidget(
                                              imageUrl: "${UrlContainer.supportImagePath}${messages.attachments?[i].attachment}",
                                              width: MediaQuery.of(context).size.width > 500 ? 100 : 100,
                                              height: MediaQuery.of(context).size.width > 500 ? 100 : 100,
                                            )
                                          : Center(
                                              child: Icon(
                                              Icons.file_present_rounded,
                                              size: MediaQuery.of(context).size.width > 500 ? 50 : 50,
                                            )),
                                    ),
                                  ),
                          )
                        : const [SizedBox.shrink()],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
//