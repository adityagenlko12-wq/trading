import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/repo/withdraw/withdraw_history_repo.dart';

import '../../../../../../../../../data/controller/wallet/wallet_history_controller.dart';
import '../../../../../../../../../data/repo/deposit/deposit_repo.dart';
import '../../../../../../../../../data/repo/wallet/wallet_repository.dart';
import '../../../../../../../../../data/services/api_service.dart';
import '../../../../../../../core/helper/date_converter.dart';
import '../../../../../../../core/utils/dimensions.dart';
import '../../../../../../../core/utils/my_color.dart';
import '../../../../../../../core/utils/my_icons.dart';
import '../../../../../../../core/utils/my_strings.dart';
import '../../../../../../../core/utils/style.dart';
import '../../../../../../../data/model/wallet/single_wallet_details.dart';
import '../../../../../../components/app-bar/app_main_appbar.dart';
import '../../../../../../components/custom_loader/custom_loader.dart';
import '../../../../../../components/divider/custom_spacer.dart';
import '../../../../../../components/image/my_local_image_widget.dart';
import '../../../../../../components/no_data.dart';
import '../../../../../../components/text/label_text.dart';
import 'widgets/bottom_sheet.dart';
import 'widgets/filter_row_widget.dart';

class WalletHistoryScreen extends StatefulWidget {
  final String remarkType;
  const WalletHistoryScreen({super.key, this.remarkType = 'all'});

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  final ScrollController scrollController = ScrollController();

  fetchData() {
    Get.find<WalletHistoryController>().loadTransaction();
  }

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<WalletHistoryController>().hasNext()) {
        fetchData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(WalletRepository(apiClient: Get.find()));
    Get.put(WithdrawHistoryRepo(apiClient: Get.find()));
    Get.put(DepositRepo(apiClient: Get.find()));
    final controller = Get.put(WalletHistoryController(walletRepository: Get.find(), withdrawHistoryRepo: Get.find(), depositRepo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initialTransactionHistory(selectedRemarkType: widget.remarkType);
      if (widget.remarkType == 'deposit') {
        controller.historyTabController?.animateTo(1);
      }
      if (widget.remarkType == 'withdraw') {
        controller.historyTabController?.animateTo(2);
      }
      if (widget.remarkType == 'transfer') {
        controller.historyTabController?.animateTo(3);
      }
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletHistoryController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppMainAppBar(
          isTitleCenter: true,
          isProfileCompleted: true,
          title: MyStrings.walletActivity.tr,
          bgColor: MyColor.transparentColor,
          titleStyle: regularLarge.copyWith(fontSize: Dimensions.fontLarge, color: MyColor.getPrimaryTextColor()),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: Dimensions.space15),
              child: Ink(
                decoration: ShapeDecoration(
                  color: MyColor.getAppBarBackgroundColor(),
                  shape: const CircleBorder(),
                ),
                child: FittedBox(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      controller.changeSearchIcon();
                    },
                    icon: Icon(
                      controller.isSearch ? Icons.clear : Icons.filter_alt_sharp,
                      color: MyColor.getAppBarContentColor(),
                    ),
                  ),
                ),
              ),
            ),
            horizontalSpace(Dimensions.space10),
          ],
        ),
        body: Column(
          children: [
            verticalSpace(Dimensions.space5),
            Theme(
              data: ThemeData(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
                // padding: const EdgeInsets.all(Dimensions.space15),

                child: TabBar(
                  controller: controller.historyTabController,
                  splashBorderRadius: BorderRadius.circular(Dimensions.cardRadius1),
                  dividerColor: MyColor.getBorderColor(),
                  indicator: null,
                  indicatorColor: MyColor.getPrimaryColor(),

                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: MyColor.getPrimaryTextColor(),
                  labelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  //Unselected
                  unselectedLabelColor: MyColor.getSecondaryTextColor(),
                  unselectedLabelStyle: semiBoldDefault.copyWith(fontSize: Dimensions.fontLarge),
                  onTap: (value) => controller.changeTabIndex(value),
                  padding: EdgeInsets.zero,

                  tabs: [
                    Tab(
                      text: MyStrings.transactionHistory.tr,
                    ),
                    Tab(
                      text: MyStrings.deposit.tr,
                    ),
                    Tab(
                      text: MyStrings.withdraw.tr,
                    ),
                    Tab(
                      text: MyStrings.transfer.tr,
                    ),
                  ],
                ),
              ),
            ),
            controller.isLoading
                ? const SizedBox(height: Dimensions.space100, child: CustomLoader())
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: controller.isSearch,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 13),
                              margin: const EdgeInsets.only(bottom: Dimensions.cardMargin),
                              decoration: BoxDecoration(
                                color: MyColor.getScreenBgSecondaryColor(),
                                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const LabelText(text: MyStrings.type),
                                            const SizedBox(height: Dimensions.space10),
                                            SizedBox(
                                              height: 40,
                                              child: FilterRowWidget(
                                                  fromTrx: true,
                                                  bgColor: Colors.transparent,
                                                  text: controller.selectedTrxType.isEmpty ? MyStrings.trxType : controller.selectedTrxType,
                                                  press: () {
                                                    showTrxBottomSheet(controller.transactionTypeList.map((e) => e.toString()).toList(), 1, MyStrings.selectTrxType, context: context);
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if ((controller.historyTabController?.index ?? 0) < 1) ...[
                                        const SizedBox(width: Dimensions.space15),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const LabelText(text: MyStrings.remark),
                                              const SizedBox(height: Dimensions.space10),
                                              SizedBox(
                                                height: 40,
                                                child: FilterRowWidget(
                                                    fromTrx: true,
                                                    bgColor: Colors.transparent,
                                                    text: StringConverter.replaceUnderscoreWithSpace(controller.selectedRemark.isEmpty ? MyStrings.any.tr : controller.selectedRemark.tr),
                                                    press: () {
                                                      showTrxBottomSheet(controller.remarksList.map((e) => e.remark.toString()).toList(), 2, MyStrings.selectRemarks, context: context);
                                                    }),
                                              ),
                                            ],
                                          ),
                                        )
                                      ] else ...[
                                        const SizedBox(width: Dimensions.space15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const LabelText(text: MyStrings.currency),
                                              const SizedBox(height: Dimensions.space10),
                                              SizedBox(
                                                height: 40,
                                                child: FilterRowWidget(
                                                    fromTrx: true,
                                                    bgColor: Colors.transparent,
                                                    text: (controller.selectedCurrency.isEmpty ? MyStrings.any.tr : controller.selectedCurrency.tr.toUpperCase()),
                                                    press: () {
                                                      showTrxBottomSheet(controller.cryptoCurrencyData.map((e) => e.symbol.toString()).toList(), 3, MyStrings.selectCurrency, context: context);
                                                    }),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.space15),
                                  if ((controller.historyTabController?.index ?? 0) < 1) ...[
                                    const SizedBox(width: Dimensions.space15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const LabelText(text: MyStrings.currency),
                                        const SizedBox(height: Dimensions.space10),
                                        SizedBox(
                                          height: 40,
                                          child: FilterRowWidget(
                                              fromTrx: true,
                                              bgColor: Colors.transparent,
                                              text: (controller.selectedCurrency.isEmpty ? MyStrings.any.tr : controller.selectedCurrency.tr.toUpperCase()),
                                              press: () {
                                                showTrxBottomSheet(controller.cryptoCurrencyData.map((e) => e.symbol.toString()).toList(), 3, MyStrings.selectCurrency, context: context);
                                              }),
                                        ),
                                      ],
                                    )
                                  ],
                                  const SizedBox(height: Dimensions.space15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const LabelText(text: MyStrings.trxNo),
                                            const SizedBox(height: Dimensions.space10),
                                            SizedBox(
                                              height: 45,
                                              width: MediaQuery.of(context).size.width,
                                              child: TextFormField(
                                                cursorColor: MyColor.getPrimaryColor(),
                                                style: regularSmall.copyWith(color: MyColor.getPrimaryTextColor()),
                                                keyboardType: TextInputType.text,
                                                controller: controller.trxController,
                                                decoration: InputDecoration(
                                                    hintText: '',
                                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                    hintStyle: regularSmall.copyWith(color: MyColor.colorGreen),
                                                    filled: true,
                                                    fillColor: MyColor.transparentColor,
                                                    border: const OutlineInputBorder(borderSide: BorderSide(color: MyColor.colorGrey, width: 0.5)),
                                                    enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: MyColor.colorGrey, width: 0.5)),
                                                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: MyColor.primaryColor, width: 0.5))),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.space10),
                                      InkWell(
                                        onTap: () {
                                          controller.filterData();
                                        },
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MyColor.primaryColor),
                                          child: const Icon(Icons.search_outlined, color: MyColor.colorWhite, size: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: controller.transactionList.isEmpty && controller.filterLoading == false
                                ? Center(
                                    child: NoDataWidget(
                                      text: MyStrings.noTransactionHistoryFound.tr,
                                    ),
                                  )
                                : controller.filterLoading
                                    ? const CustomLoader()
                                    : RefreshIndicator(
                                        color: MyColor.getPrimaryColor(),
                                        onRefresh: () async {
                                          controller.initialTransactionHistory(selectedRemarkType: controller.selectedRemark);
                                        },
                                        child: SizedBox(
                                          child: ListView.separated(
                                            controller: scrollController,
                                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                            shrinkWrap: true,
                                            padding: const EdgeInsetsDirectional.only(top: Dimensions.space20),
                                            scrollDirection: Axis.vertical,
                                            itemCount: controller.transactionList.length + 1,
                                            separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                                            itemBuilder: (context, index) {
                                              if (controller.transactionList.length == index) {
                                                return controller.hasNext()
                                                    ? const CustomLoader(
                                                        isPagination: true,
                                                      )
                                                    : const SizedBox();
                                              }

                                              TransactionSingleData item = controller.transactionList[index];

                                              return Container(
                                                decoration: BoxDecoration(
                                                  border: Border(bottom: BorderSide(color: MyColor.getBorderColor())),
                                                ),
                                                padding: const EdgeInsets.all(Dimensions.space10),
                                                margin: const EdgeInsetsDirectional.only(bottom: Dimensions.space10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsetsDirectional.only(end: Dimensions.space15),
                                                      height: Dimensions.space40,
                                                      width: Dimensions.space40,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusMax), color: item.trxType == '+' ? MyColor.colorGreen.withOpacity(0.1) : MyColor.colorRed.withOpacity(0.1)),
                                                      child: Center(
                                                        child: MyLocalImageWidget(
                                                          imagePath: item.trxType == '+' ? MyIcons.depositAction : MyIcons.withdrawAction,
                                                          imageOverlayColor: item.trxType == '+' ? MyColor.colorGreen : MyColor.colorRed,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                "${item.wallet?.currency?.name}",
                                                                style: semiBoldLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                                              ),
                                                              Flexible(
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: DateConverter.isoToLocalDateAndTime(item.wallet?.currency?.createdAt ?? ''),
                                                                        style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          verticalSpace(Dimensions.space10),
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                MyStrings.trx.tr,
                                                                style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                                              ),
                                                              Flexible(
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: "${item.trx}",
                                                                        style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                MyStrings.amount.tr,
                                                                style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                                              ),
                                                              Flexible(
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: "${item.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(item.amount ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                                                        style: regularLarge.copyWith(color: item.trxType == '+' ? MyColor.colorGreen : MyColor.colorRed),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                MyStrings.postBalance.tr,
                                                                style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor()),
                                                              ),
                                                              Flexible(
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: "${item.wallet?.currency?.sign ?? ''}${StringConverter.formatNumber(item.postBalance ?? '0.0', precision: controller.walletRepository.apiClient.getDecimalAfterNumber())}",
                                                                        style: regularLarge.copyWith(color: MyColor.getPrimaryTextColor()),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          verticalSpace(Dimensions.space15),
                                                          Text(
                                                            "${item.details}",
                                                            style: regularLarge.copyWith(color: MyColor.getSecondaryTextColor().withOpacity(0.7)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                          )
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      );
    });
  }
}
