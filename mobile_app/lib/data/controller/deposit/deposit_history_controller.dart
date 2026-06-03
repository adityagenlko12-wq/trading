import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../model/deposit/deposit_history_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/deposit/deposit_repo.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';

class DepositHistoryController extends GetxController {
  DepositRepo depositRepo;
  DepositHistoryController({required this.depositRepo});

  int page = 0;
  bool isLoading = true;
  bool searchLoading = false;
  String currency = "";
  String curSymbol = "";
  String nextPageUrl = "";

  List<DepositHistoryListModel> depositList = [];

  bool isSearch = false;
  TextEditingController searchController = TextEditingController();

  void changeIsPress() {
    isSearch = !isSearch;
    update();
    if (!isSearch) {
      searchController.clear();
      beforeInitLoadData();
    }
  }

  bool hasNext() {
    return nextPageUrl.isNotEmpty && nextPageUrl != 'null';
  }

  Future<void> beforeInitLoadData() async {
    page = 0;
    depositList.clear();
    isLoading = true;
    update();
    await loadDepositData();
    isLoading = false;
    update();
  }

  Future<void> fetchNewList() async {
    await loadDepositData();
    update();
  }

  Future<void> searchDepositTrx() async {
    page = 0;
    depositList.clear();
    searchLoading = true;
    update();
    await loadDepositData();
    searchLoading = false;
    update();
  }

  Future<void> loadDepositData() async {
    currency = depositRepo.apiClient.getCurrencyOrUsername();
    curSymbol = depositRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    page = page + 1;

    String searchText = searchController.text;
    ResponseModel responseModel = await depositRepo.getDepositHistory(page: page, searchText: searchText);

    if (responseModel.statusCode == 200) {
      DepositHistoryResponseModel model = DepositHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      nextPageUrl = model.data?.deposits?.nextPageUrl ?? "";

      if (model.status.toString().toLowerCase() == "success") {
        List<DepositHistoryListModel>? tempDepositList = model.data?.deposits?.data;
        if (tempDepositList != null && tempDepositList.isNotEmpty) {
          depositList.addAll(tempDepositList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  String getStatus(int index) {
    String status = depositList[index].status == "1"
        ? MyStrings.succeed.tr
        : depositList[index].status == "2"
            ? MyStrings.pending.tr
            : depositList[index].status == "3"
                ? MyStrings.rejected.tr
                : MyStrings.initiated.tr;
    return status;
  }

  Color getStatusColor(int index) {
    String status = depositList[index].status ?? '';
    return status == '1'
        ? MyColor.greenSuccessColor
        : status == '2'
            ? MyColor.pendingColor
            : status == '3'
                ? MyColor.redCancelTextColor
                : MyColor.colorGrey;
  }
}
