import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/style.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../data/controller/transfer/transfer_controller.dart';
import '../../../components/divider/custom_spacer.dart';
import 'transfer_currency_search_app_bar.dart';

class TransferSearchCurrencyFromListWidget extends StatelessWidget {
  final ScrollController scrollController;
  final TransferController controller;
  const TransferSearchCurrencyFromListWidget({
    super.key,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: TransferSearchCurrencyBoxAppBar(
          controller: controller,
        ),
        body: Container(
          margin: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space15),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsetsDirectional.only(top: Dimensions.space20),
                    itemCount: controller.filteredWalletDataList.length,
                    itemBuilder: (context, index) {
                      var item = controller.filteredWalletDataList[index];
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
                              controller.changeSelectedWalletData(item);
                              Get.back();
                              Future.delayed(const Duration(seconds: 1));
                              controller.filterWalletDataList("");
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
                                          imageUrl: item.currency?.imageUrl ?? '',
                                          width: Dimensions.space50,
                                          height: Dimensions.space50,
                                        ),
                                        horizontalSpace(Dimensions.space15),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.currency?.symbol ?? '',
                                              style: semiBoldMediumLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                            ),
                                            verticalSpace(Dimensions.space8),
                                            Text(
                                              item.currency?.name ?? '',
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

