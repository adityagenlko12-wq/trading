import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vinance/data/model/notification/notification_model.dart';
import 'package:vinance/view/components/divider/custom_spacer.dart';

import '../../../../core/helper/date_converter.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../components/animated_widget/expanded_widget.dart';
import '../../../components/text/default_text.dart';

class NotificationListItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final VoidCallback press;
  final NotificationsData item;
  const NotificationListItem({
    super.key,
    required this.index,
    required this.press,
    required this.selectedIndex,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    // var notificationType = "sms";
    var notificationType = (item.notificationType ?? '').toLowerCase();
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
      ),
      padding: const EdgeInsets.all(Dimensions.space10),
      margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10, top: Dimensions.space10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(
              top: Dimensions.space5,
              end: Dimensions.space10,
            ),
            decoration: BoxDecoration(
                color: notificationType == 'email'
                    ? MyColor.highPriorityPurpleColor.withOpacity(0.3)
                    : notificationType == 'sms'
                        ? MyColor.pendingColor.withOpacity(0.3)
                        : notificationType == 'push'
                            ? MyColor.primaryColor.withOpacity(0.3)
                            : MyColor.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Dimensions.cardRadius1 * 30)),
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(Dimensions.space5),
            child: Center(
                child: FittedBox(
              child: Icon(
                notificationType == 'email'
                    ? Icons.mail_outline
                    : notificationType == 'sms'
                        ? Icons.sms_outlined
                        : notificationType == 'push'
                            ? Icons.notification_add_outlined
                            : Icons.notification_add_outlined,
                color: notificationType == 'email'
                    ? MyColor.highPriorityPurpleColor
                    : notificationType == 'sms'
                        ? MyColor.pendingColor
                        : notificationType == 'push'
                            ? MyColor.primaryColor
                            : MyColor.primaryColor,
              ),
            )),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: press,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: DefaultText(
                                text: item.subject ?? '',
                                textStyle: semiBoldDefault,
                                textColor: MyColor.getPrimaryTextColor(),
                              ),
                            ),
                            const SizedBox(
                              height: Dimensions.space5,
                            ),
                            Text(
                              DateConverter.isoToLocalDateAndTime(((item.createdAt ?? '').toString())),
                              style: regularDefault.copyWith(color: MyColor.getSecondaryTextColor()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(child: IconButton(onPressed: press, icon: Icon(index == selectedIndex ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: MyColor.getPrimaryColor(), size: 20)))
                  ],
                ),
                if (index == selectedIndex) ...[
                  verticalSpace(Dimensions.space10),
                  ExpandedSection(
                    expand: index == selectedIndex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.space10),
                        HtmlWidget(
                          item.message ?? '',
                        )
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
