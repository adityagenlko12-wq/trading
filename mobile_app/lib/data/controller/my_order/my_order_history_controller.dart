// Import necessary dependencies or models

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/repo/market_trade/market_trade_repo.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/authorization/authorization_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/order/order_history_page_response_model.dart';

class MyOrderHistoryController extends GetxController with GetTickerProviderStateMixin {
  MarketTradeRepo marketTradeRepo;

  MyOrderHistoryController({
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
    historyTabController = TabController(initialIndex: currentIndex, length: 4, vsync: this);
  }

  changeTabIndex(int value) {
    currentIndex = value;
    update();
    if (currentIndex == 0) {
      initialOrderHistory(orderHistoryTypeParams: 'all');
    }
    if (currentIndex == 1) {
      initialOrderHistory(orderHistoryTypeParams: 'open');
    }
    if (currentIndex == 2) {
      initialOrderHistory(orderHistoryTypeParams: 'completed');
    }
    if (currentIndex == 3) {
      initialOrderHistory(orderHistoryTypeParams: 'canceled');
    }
  }

  //DATA

  bool isLoading = true;
  final formKey = GlobalKey<FormState>();

  List<OrderHistoryPageResponseModelData> orderHistoryDataList = [];

  String? nextPageUrl;
  String currency = '';
  String orderHistory = 'all';
  String orderType = 'all';
  String orderSide = 'all';

  int page = 0;
  int index = 0;

  TextEditingController searchCoinController = TextEditingController();

  void initialOrderHistory({String orderHistoryTypeParams = 'All', bool isBgLoad = false}) async {
    page = 0;
    orderHistory = orderHistoryTypeParams;
    searchCoinController.text = '';
    if (isBgLoad == false) {
      isLoading = true;
      orderHistoryDataList.clear();
      update();
    }
    await loadOrderHistoryData();
    isLoading = false;
    update();
  }

  Future<void> loadOrderHistoryData() async {
    try {
      page = page + 1;

      if (page == 1) {
        currency = marketTradeRepo.apiClient.getCurrencyOrUsername();
      }

      ResponseModel responseModel = await marketTradeRepo.getMyOrderHistory(
        page,
        searchText: searchCoinController.text,
        orderSide: orderSide,
        orderType: orderType,
        historyType: orderHistory,
      );

      if (responseModel.statusCode == 200) {
        final orderHistoryPageResponseModel = orderHistoryPageResponseModelFromJson(responseModel.responseJson);
        nextPageUrl = orderHistoryPageResponseModel.data?.orders?.nextPageUrl;

        if (orderHistoryPageResponseModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          List<OrderHistoryPageResponseModelData>? tempDataList = orderHistoryPageResponseModel.data?.orders?.data;

          if (tempDataList != null && tempDataList.isNotEmpty) {
            orderHistoryDataList.addAll(tempDataList);
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
    orderHistoryDataList.clear();

    await loadOrderHistoryData();

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
      initialOrderHistory(isBgLoad: true);
    }
  }

  //Edit //Update //close

  TextEditingController amountController = TextEditingController();
  String updateOrderRateOrAmountOrderID = '-1';
  String updateOrderRateOrderType = 'amount'; //amount or rate

  changeOrderUpdateID({String orderID = '', String orderUpdateType = 'amount', String amountValue = '0.0'}) {
    updateOrderRateOrAmountOrderID = orderID;
    updateOrderRateOrderType = orderUpdateType;
    amountController.text = amountValue;
    update();
  }

  String updateOrderRateAmountButtonLoadingID = '-1';
  Future updateOrderRate({
    String tradeCoinSymbol = '-1',
    String orderID = '-1',
  }) async {
    updateOrderRateAmountButtonLoadingID = orderID;
    update();
    try {
      ResponseModel responseData = await marketTradeRepo.updateOrderRate(
        orderID: orderID,
        updateFiledType: updateOrderRateOrderType,
        updateValue: amountController.text,
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
        updateOrderRateOrAmountOrderID = "-1";
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
      // loadOrderListDataList(hotRefresh: true, isBgLoad: true, symbolID: tradeCoinSymbol);
    } catch (e) {
      printx(e.toString());
    } finally {
      updateOrderRateAmountButtonLoadingID = "-1";
      update();
    }
  }

  String cancelOrderRateLoadingID = '-1';
  Future cancelOrderRate({
    String tradeCoinSymbol = '-1',
    String orderID = '-1',
  }) async {
    cancelOrderRateLoadingID = orderID;
    update();
    try {
      ResponseModel responseData = await marketTradeRepo.cancelOrderRate(
        orderID: orderID,
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
        orderHistoryDataList.removeWhere((element) => element.id == orderID);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      cancelOrderRateLoadingID = "-1";
      update();
    }
  }
}
