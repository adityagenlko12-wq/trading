// Import necessary dependencies or models

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/repo/market_trade/market_trade_repo.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/trade/trade_history_page_response_model.dart';

class TradeHistoryController extends GetxController with GetTickerProviderStateMixin {
  MarketTradeRepo marketTradeRepo;

  TradeHistoryController({
    required this.marketTradeRepo,
  });

  int currentIndex = 0;

  TabController? historyTabController;
  @override
  void onInit() {
    super.onInit();
    loadTradeHistoryTabsData();
  }

  loadTradeHistoryTabsData() {
    historyTabController = TabController(initialIndex: currentIndex, length: 3, vsync: this);
  }

  changeTabIndex(int value) {
    currentIndex = value;
    update();
    if (currentIndex == 0) {
      initialTransactionHistory(tradeTypeParams: 'all');
    }
    if (currentIndex == 1) {
      initialTransactionHistory(tradeTypeParams: 'buy');
    }
    if (currentIndex == 2) {
      initialTransactionHistory(tradeTypeParams: 'sell');
    }
  }

  //DATA

  bool isLoading = true;
  final formKey = GlobalKey<FormState>();

  List<TradeHistoryPageListData> tradeHistoryDataList = [];

  String? nextPageUrl;
  String currency = '';
  String tradeType = '';

  int page = 0;
  int index = 0;

  TextEditingController searchCoinController = TextEditingController();

  void initialTransactionHistory({String tradeTypeParams = 'All', bool isBgLoad = false}) async {
    page = 0;
    tradeType = tradeTypeParams;
    searchCoinController.text = '';
    if (isBgLoad == false) {
      isLoading = true;
      tradeHistoryDataList.clear();
      update();
    }
    await loadTradeHistoryData();
    isLoading = false;
    update();
  }

  Future<void> loadTradeHistoryData() async {
    try {
      page = page + 1;

      if (page == 1) {
        currency = marketTradeRepo.apiClient.getCurrencyOrUsername();
      }

      ResponseModel responseModel = await marketTradeRepo.getTradeHistoryData(
        page,
        searchText: searchCoinController.text,
        tradeSide: tradeType,
      );

      if (responseModel.statusCode == 200) {
        final tradeHistoryPageResponseModel = tradeHistoryPageResponseModelFromJson(responseModel.responseJson);

        nextPageUrl = tradeHistoryPageResponseModel.data?.trades?.nextPageUrl;

        if (tradeHistoryPageResponseModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          List<TradeHistoryPageListData>? tempDataList = tradeHistoryPageResponseModel.data?.trades?.data;

          if (tempDataList != null && tempDataList.isNotEmpty) {
            tradeHistoryDataList.addAll(tempDataList);
          }
        } else {
          CustomSnackBar.error(
            errorList: [responseModel.message],
          );
        }
        update();
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  bool filterLoading = false;

  Future<void> filterData() async {
    page = 0;
    filterLoading = true;
    update();
    tradeHistoryDataList.clear();

    await loadTradeHistoryData();

    filterLoading = false;
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  bool isSearch = false;
  void changeSearchIcon() {
    isSearch = !isSearch;
    update();
    if (!isSearch) {
      initialTransactionHistory(isBgLoad: true);
    }
  }
}
