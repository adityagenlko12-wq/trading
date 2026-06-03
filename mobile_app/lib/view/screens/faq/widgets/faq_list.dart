import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:vinance/data/model/faq/faq_model.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';
import '../../../components/animated_widget/expanded_widget.dart';
import '../../../components/text/default_text.dart';

class FaqListItem extends StatelessWidget {
  final FaqsDataModel item;
  final int index;
  final int selectedIndex;
  final VoidCallback press;

  const FaqListItem({super.key, required this.index, required this.press, required this.selectedIndex, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
        ),
        padding: const EdgeInsets.all(Dimensions.space10),
        margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10, ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsetsDirectional.only(
                top: Dimensions.space10,
                end: Dimensions.space10,
              ),
              decoration: BoxDecoration(color: MyColor.getPrimaryColor(), borderRadius: BorderRadius.circular(Dimensions.cardRadius1 * 30)),
              width: 25,
              height: 25,
              child: Center(
                  child: Text(
                "${index + 1}",
                style: regularLarge.copyWith(color: MyColor.colorWhite),
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
                        child: SizedBox(
                          child: DefaultText(
                            text: item.dataValues?.question ?? '',
                            textStyle: semiBoldDefault,
                            textColor: MyColor.getPrimaryTextColor(),
                          ),
                        ),
                      ),
                      SizedBox(child: IconButton(onPressed: press, icon: Icon(index == selectedIndex ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: MyColor.getPrimaryColor(), size: 20)))
                    ],
                  ),
                  ExpandedSection(
                    expand: index == selectedIndex,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: Dimensions.space10),
                        HtmlWidget(
                          item.dataValues?.answer ?? '',
                          textStyle: regularSmall.copyWith(color: MyColor.getSecondaryTextColor()),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
