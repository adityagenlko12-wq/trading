import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/url_container.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/withdraw/withdraw_history_response_model.dart';
import '../../repo/withdraw/withdraw_history_repo.dart';

class WithdrawHistoryController extends GetxController {
  WithdrawHistoryRepo withdrawHistoryRepo;
  WithdrawHistoryController({required this.withdrawHistoryRepo});

  int page = 0;
  bool isLoading = true;
  String currency = "";
  String curSymbol = "";
  String nextPageUrl = "";
  String imagePath = "";

  List<WithdrawListModel> withdrawList = [];

  Future<void> loadPaginationData() async {
    await loadWithdrawData();
    update();
  }

  Future<void> loadWithdrawData() async {
    currency = withdrawHistoryRepo.apiClient.getCurrencyOrUsername();
    curSymbol = withdrawHistoryRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    page = page + 1;

    if (page == 1) {
      withdrawList.clear();
    }

    String searchText = searchController.text;
    ResponseModel responseModel = await withdrawHistoryRepo.getWithdrawHistoryData(page, searchText: searchText);

    if (responseModel.statusCode == 200) {
      WithdrawHistoryResponseModel model = WithdrawHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      imagePath = model.data?.imagePath ?? "";
      nextPageUrl = model.data?.withdrawals?.nextPageUrl ?? "";

      if (model.status.toString().toLowerCase() == "success") {
        List<WithdrawListModel>? tempWithdrawList = model.data?.withdrawals?.data;
        if (tempWithdrawList != null && tempWithdrawList.isNotEmpty) {
          withdrawList.addAll(tempWithdrawList);
        }
      } else {
        // CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(
        errorList: [responseModel.message],
      );
    }
  }

  bool filterLoading = false;
  Future<void> filterData() async {
    page = 0;
    filterLoading = true;
    update();

    await loadWithdrawData();

    filterLoading = false;
    update();
  }

  bool hasNext() {
    return nextPageUrl.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  void initData() async {
    currency = withdrawHistoryRepo.apiClient.getCurrencyOrUsername();
    page = 0;
    searchController.text = '';
    withdrawList.clear();

    isLoading = true;
    update();

    await loadWithdrawData();

    isLoading = false;
    update();
  }

  bool isSearch = false;
  TextEditingController searchController = TextEditingController();
  void changeSearchStatus() async {
    isSearch = !isSearch;
    update();
    if (!isSearch) {
      initData();
    }
  }

  String getStatus(int index) {
    String status = withdrawList[index].status == "1"
        ? MyStrings.approved.tr
        : withdrawList[index].status == "2"
            ? MyStrings.pending.tr
            : withdrawList[index].status == "3"
                ? MyStrings.rejected.tr
                : MyStrings.initiated.tr;

    return status;
  }

  Color getColor(int index) {
    String status = withdrawList[index].status ?? '';

    return status == '1'
        ? MyColor.greenSuccessColor
        : status == '2'
            ? MyColor.pendingColor
            : status == '3'
                ? MyColor.redCancelTextColor
                : MyColor.colorGrey;
  }

  void downloadAttachment(String url, BuildContext context) {
    String mainUrl = '${UrlContainer.baseUrl}assets/verify/$url';

    if (url.isNotEmpty && url != 'null') {
      update();
    }
  }
}
