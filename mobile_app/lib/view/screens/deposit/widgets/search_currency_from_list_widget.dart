import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';
import 'package:vinance/view/components/no_data.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../data/controller/deposit/deposit_controller.dart';
import '../../../components/divider/custom_spacer.dart';
import 'deposit_search_box_appbar_dart.dart';

class DepositSearchCurrencyFromListWidget extends StatelessWidget {
  final DepositController controller;
  const DepositSearchCurrencyFromListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: DepositMethodSearchBoxAppBar(
          controller: controller,
        ),
        body: Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15),
          child: Column(
            children: [
              if (controller.filteredDepositCurrencyList.isEmpty) ...[
                Center(
                  child: NoDataWidget(
                    text: MyStrings.noCurrencyFound.tr,
                  ),
                )
              ],
              Expanded(
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsetsDirectional.only(top: Dimensions.space20),
                    itemCount: controller.filteredDepositCurrencyList.length,
                    itemBuilder: (context, index) {
                      var item = controller.filteredDepositCurrencyList[index];
                      return Container(
                        margin: const EdgeInsetsDirectional.only(top: Dimensions.space10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(Dimensions.space10),
                          type: MaterialType.transparency,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Dimensions.space10),
                            onTap: () {
                              controller.selectDepositCurrency(item);
                              Get.back();
                              Future.delayed(const Duration(seconds: 1));
                              controller.filterDepositCurrencyDataList("");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(Dimensions.space10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //Worth
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        MyNetworkImageWidget(
                                          imageUrl: item.imageUrl ?? '',
                                          width: Dimensions.space50,
                                          height: Dimensions.space50,
                                        ),
                                        horizontalSpace(Dimensions.space15),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.symbol ?? '',
                                              style: semiBoldMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                            ),
                                            verticalSpace(Dimensions.space8),
                                            Text(
                                              item.name ?? '',
                                              style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
