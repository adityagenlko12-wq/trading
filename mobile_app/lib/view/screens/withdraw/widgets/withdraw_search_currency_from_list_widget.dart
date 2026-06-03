import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/data/controller/withdraw/withdraw_controller.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';
import 'package:vinance/view/components/no_data.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../components/divider/custom_spacer.dart';
import 'withdraw_search_box_widget.dart';

class WithdrawSearchCurrencyFromListWidget extends StatelessWidget {
  final WithdrawController controller;
  const WithdrawSearchCurrencyFromListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WithdrawController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: WithDrawSearchBoxAppBar(
          controller: controller,
        ),
        body: Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15),
          child: Column(
            children: [
              if (controller.filteredWithdrawCurrencyList.isEmpty) ...[
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
                    itemCount: controller.filteredWithdrawCurrencyList.length,
                    itemBuilder: (context, index) {
                      var item = controller.filteredWithdrawCurrencyList[index];
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
                              controller.selectWithdrawCurrency(item);
                              Get.back();
                              Future.delayed(const Duration(seconds: 1));
                              controller.filterWithdrawCurrencyDataList("");
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
