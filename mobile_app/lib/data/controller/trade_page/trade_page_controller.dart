// Import necessary dependencies or models
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/authorization/authorization_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/market/market_data_list_model.dart' hide MarketData, Message, HtmlClasses;
import '../../model/market/market_order_book_model.dart';
import '../../model/market/market_pair_list_data_model.dart' hide MarketData, Message, Pairs, Market, Currency, Coin;
import '../../model/market/market_trade_deatils_model.dart' hide Message, HtmlClasses, Coin, Market, Currency;
import '../../model/market/trade_history_response_model.dart';
import '../../model/order/order_list_response_model.dart' hide Pair, Message;
import '../../repo/market_trade/market_trade_repo.dart';
import '../pusher_controller/pusher_service_controller.dart';

class TradePageController extends GetxController with GetTickerProviderStateMixin {
  MarketTradeRepo marketTradeRepo;

  TradePageController({required this.marketTradeRepo});
  int currentIndex = 0;
  int currentTradePageIndex = 0;
  int currentBuyOrSellTabIndex = 0;

  TabController? tabController;
  TabController? tabTradePageController;
  TabController? buyOrSellTabController;

  @override
  void onInit() {
    super.onInit();
    loadTradePageTabsData();
  }

  loadTradePageTabsData() {
    tabController = TabController(initialIndex: currentIndex, length: 2, vsync: this);
    tabTradePageController = TabController(initialIndex: currentTradePageIndex, length: 2, vsync: this);

    buyOrSellTabController = TabController(initialIndex: currentBuyOrSellTabIndex, length: 2, vsync: this);
  }

  changeBuyOrSellTabIndex(int value) {
    currentBuyOrSellTabIndex = value;
    buyOrSellTabController?.animateTo(value);

    if (selectedOrderType == 0) {
      marketPriceTextController.text = double.parse(tradeDetailsMarketData?.price ?? '0').toPrecision(2).toString();
      myMarketPriceTextController.text = double.parse(tradeDetailsMarketData?.price ?? '0').toPrecision(2).toString();
    }
    update();
  }

  changeTabTradeIndex(int value) {
    currentTradePageIndex = value;

    update();
  }

  changeMainTabIndex(int value) {
    currentIndex = value;

    update();
  }

  //Controller
  TextEditingController marketPriceTextController = TextEditingController();
  TextEditingController myMarketPriceTextController = TextEditingController();
  TextEditingController myBuyPriceAmountTextController = TextEditingController();
  TextEditingController mySellPriceAmountTextController = TextEditingController();
  TextEditingController myTotalPriceAmountTextController = TextEditingController();
  String totalFee = "";

  Future initialData({String symbolID = '', bool isBgLoad = false, bool orderListLoad = true}) async {
    openOrderHistoryLoading = orderListLoad;
    update();
    await loadTradePageDetailsData(symbolID: symbolID).whenComplete(() async {
      if (tradeSymbol != '') {
        printx(tradeSymbol);

        loadOthersData(symbolID: tradeSymbol, isBgLoad: false, orderListLoad: orderListLoad);
      } else {
        loadOthersData(symbolID: symbolID, isBgLoad: isBgLoad, orderListLoad: orderListLoad);
      }
    });
  }

  Future initialDataRefresh({bool isBgLoad = false}) async {
    await loadTradePageDetailsData(symbolID: tradeSymbol).whenComplete(() async {
      loadOthersData(symbolID: tradeSymbol, isBgLoad: isBgLoad);
    });
  }

  Future loadOthersData({String symbolID = '', bool isBgLoad = false, bool orderListLoad = true}) async {
    pusherServiceController.initPusher("market-data");
    pusherServiceController.initPusher("trade");
    pusherServiceController.initPusher("order-placed-to-$symbolID");
    await loadTradePageDetailsOrderBookData(symbolID: symbolID);
    await loadTradeHistoryListData(symbolID: symbolID);
    if (orderListLoad) {
      await loadOrderListDataList(symbolID: symbolID, hotRefresh: true, isBgLoad: isBgLoad);
    }
    await loadMarketPairDataList(marketID: '');
  }

  // Details
  bool tradeDetailsLoading = true;
  MarketTradeDetailsModel marketTradeDetailsModelDATA = MarketTradeDetailsModel();
  Pair? tradeDetailsMarketPair;
  String tradeSymbol = '';
  MarketData? tradeDetailsMarketData;
  Wallet? coinWallet;
  Wallet? marketCurrencyWallet;
  Future loadTradePageDetailsData({String symbolID = ''}) async {
    if (marketTradeDetailsModelDATA.status == null) {
      tradeDetailsLoading = true;
    }
    update();
    try {
      ResponseModel responseData = await marketTradeRepo.getMarketTradeDataBasedOnSymbolID(
        marketSymbolID: symbolID == '' ? tradeSymbol : symbolID,
      );
      if (responseData.statusCode == 200) {
        final marketTradeDetailsModel = marketTradeDetailsModelFromJson(responseData.responseJson);

        if (marketTradeDetailsModel.status?.toLowerCase() == MyStrings.success) {
          marketTradeDetailsModelDATA = marketTradeDetailsModel;

          if (marketTradeDetailsModel.data?.pair?.marketData != null) {
            tradeDetailsMarketPair = marketTradeDetailsModel.data?.pair;
            tradeSymbol = marketTradeDetailsModel.data?.pair?.symbol ?? '';
            tradeDetailsMarketData = marketTradeDetailsModel.data?.pair?.marketData;
            coinWallet = marketTradeDetailsModel.data?.coinWallet;
            marketCurrencyWallet = marketTradeDetailsModel.data?.marketCurrencyWallet;
            if (marketCurrencyWallet != null) {
              marketPriceTextController.text = double.parse(tradeDetailsMarketData?.price ?? '0').toPrecision(2).toString();
              myMarketPriceTextController.text = double.parse(tradeDetailsMarketData?.price ?? '0').toPrecision(2).toString();
            }

            update();
          }
        } else {
          Get.back();
          CustomSnackBar.error(errorList: marketTradeDetailsModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      tradeDetailsLoading = false;
      update();
    }
  }

  PusherServiceController pusherServiceController = Get.find();
  //Update market Data Based On  pusher event
  void updateMarketDataBasedOnPusherEvent() async {
    if (pusherServiceController.marketData.isNotEmpty) {
      for (int i = 0; i < pusherServiceController.marketData.length; i++) {
        String currentId = pusherServiceController.marketData[i].id ?? "-1";
        var newMarketData = pusherServiceController.marketData[i];

        MarketSinglePairData? matchingElement = marketPairDataList.firstWhere((element) => element.marketData?.id == currentId, orElse: () => MarketSinglePairData());
        if (matchingElement.id != null) {
          // Update the price if a matching element is found
          matchingElement.marketData?.price = newMarketData.price;
          matchingElement.marketData?.marketCap = newMarketData.marketCap;
          matchingElement.marketData?.percentChange1H = newMarketData.percentChange1H;
          matchingElement.marketData?.htmlClasses?.percentChange1H = newMarketData.htmlClasses?.percentChange1H;
        }

        if (tradeDetailsMarketData?.id == currentId) {
          if (newMarketData.id != null) {
            tradeDetailsMarketData?.price = newMarketData.price;
            marketPriceTextController.text = newMarketData.price ?? '0';
            tradeDetailsMarketData?.marketCap = newMarketData.marketCap;
            tradeDetailsMarketData?.percentChange1H = newMarketData.percentChange1H;

            tradeDetailsMarketData?.htmlClasses?.percentChange1H = newMarketData.htmlClasses?.percentChange1H;
            tradeDetailsMarketData?.percentChange24H = newMarketData.percentChange24H;
            tradeDetailsMarketData?.htmlClasses?.percentChange24H = newMarketData.htmlClasses?.percentChange24H;
          }
        }
      }
      filteredMarketPairDataList = marketPairDataList;
      pusherServiceController.marketData.clear();
      update();
      printx("From Pusher data event");
      await loadTradePageDetailsOrderBookData(symbolID: tradeSymbol);
      await loadTradeHistoryListData(symbolID: tradeSymbol);
    }
    if (pusherServiceController.currentEventName == "order-placed-to-$tradeSymbol") {
      printx("Load OrderBook Data event");
      try {
        printx(pusherServiceController.sideOrderBook?.userId);
        if (pusherServiceController.sideOrderBook?.userId != marketTradeRepo.apiClient.getUserID()) {
          if (pusherServiceController.sideOrderBook?.id != null) {
            if (pusherServiceController.sideOrderBook?.orderSide.toString() == "1") {
              buySideOrderList.insert(0, pusherServiceController.sideOrderBook ?? SideOrderBook());

              List<SideOrderBook> newBuySideOrder = buySideOrderList..sort((a, b) => double.parse(b.rate ?? '0').compareTo(double.parse(a.rate ?? '0')));
              buySideOrderList = newBuySideOrder.toSet().toList();
              update();
            }
            if (pusherServiceController.sideOrderBook?.orderSide.toString() == "2") {
              sellSideOrder.insert(0, pusherServiceController.sideOrderBook ?? SideOrderBook());
              List<SideOrderBook> newSellSideOrder = sellSideOrder..sort((a, b) => double.parse(b.rate ?? '0').compareTo(double.parse(a.rate ?? '0')));
              sellSideOrder = newSellSideOrder.toSet().toList();
              update();
            }
          }
        } else {
          await loadTradePageDetailsOrderBookData(symbolID: tradeSymbol);
        }
      } catch (e) {
        printx(e.toString());
      }
    }
  }

  //ORDER BOOK
  bool tradeDetailsOrderBookLoading = false;
  MarketOrderBookModel marketOrderBookModelData = MarketOrderBookModel();
  List<SideOrderBook> buySideOrderList = [];
  List<SideOrderBook> sellSideOrder = [];

  loadTradePageDetailsOrderBookData({String symbolID = ''}) async {
    if (marketOrderBookModelData.status == null) {
      tradeDetailsOrderBookLoading = true;
    }
    // tradeDetailsOrderBookLoading = true;
    update();

    try {
      ResponseModel responseData = await marketTradeRepo.getMarketTradeOrderBookData(marketSymbolID: symbolID);
      if (responseData.statusCode == 200) {
        final marketTradeDetailsModel = marketOrderBookModelFromJson(responseData.responseJson);

        if (marketTradeDetailsModel.status?.toLowerCase() == MyStrings.success) {
          marketOrderBookModelData = marketTradeDetailsModel;

          List<SideOrderBook>? tempBuyData = marketTradeDetailsModel.data?.buySideOrders;
          buySideOrderList.clear();
          if (tempBuyData != null && tempBuyData.isNotEmpty) {
            buySideOrderList.addAll(tempBuyData);
          }

          List<SideOrderBook>? tempSellData = marketTradeDetailsModel.data?.sellSideOrders;
          sellSideOrder.clear();
          if (tempSellData != null && tempSellData.isNotEmpty) {
            sellSideOrder.addAll(tempSellData);
          }
        } else {
          // CustomSnackBar.error(errorList: marketTradeDetailsModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      tradeDetailsOrderBookLoading = false;
      update();
    }
  }

  //Trade History
  bool tradeHistoryLoading = false;
  TradeHistoryResponseModel tradeHistoryModelData = TradeHistoryResponseModel();
  List<TradeHistoryData> tradesHistoryList = [];

  loadTradeHistoryListData({String symbolID = ''}) async {
    if (tradeHistoryModelData.status == null) {
      tradeHistoryLoading = true;
    }
    update();

    try {
      ResponseModel responseData = await marketTradeRepo.getMarketTradeHistoryData(
        marketSymbolID: symbolID,
      );
      if (responseData.statusCode == 200) {
        final tradeHistoryResponseModel = tradeHistoryResponseModelFromJson(responseData.responseJson);
        if (tradeHistoryResponseModel.status?.toLowerCase() == MyStrings.success) {
          tradeHistoryModelData = tradeHistoryResponseModel;

          List<TradeHistoryData>? tempTradeHistoryData = tradeHistoryResponseModel.data?.trades;
          tradesHistoryList.clear();
          if (tempTradeHistoryData != null && tempTradeHistoryData.isNotEmpty) {
            tradesHistoryList.addAll(tempTradeHistoryData);
          }
        } else {
          // CustomSnackBar.error(errorList: tradeHistoryResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      tradeHistoryLoading = false;
      update();
    }
  }

  int page = 0;
  String? nextPageUrl;
  OrderListResponseModel orderListResponseModelData = OrderListResponseModel();
  bool openOrderHistoryLoading = true;
  List<OrderListSingleData> orderListData = [];

  loadOrderListDataList({bool hotRefresh = false, bool isBgLoad = false, String symbolID = ''}) async {
    if (hotRefresh) {
      if (isBgLoad == false) {
        orderListData.clear();
      }

      page = 0;
      update();
    }
    page = page + 1;
    if (page == 1) {
      if (isBgLoad == false) {
        orderListData.clear();
        openOrderHistoryLoading = true;
      }

      update();
    }

    update();
    try {
      ResponseModel responseData = await marketTradeRepo.getMarketTradeOrderOpenHistoryData(page: page, marketSymbolID: symbolID == '' ? tradeSymbol : symbolID);
      if (responseData.statusCode == 200) {
        final tradeHistoryResponseModel = orderListResponseModelFromJson(responseData.responseJson);

        orderListResponseModelData = tradeHistoryResponseModel;

        if (tradeHistoryResponseModel.status?.toLowerCase() == MyStrings.success) {
          nextPageUrl = tradeHistoryResponseModel.data?.orders?.nextPageUrl;

          List<OrderListSingleData> tempWalletList = tradeHistoryResponseModel.data?.orders?.data ?? [];
          if (isBgLoad == true) {
            orderListData.clear();
          }
          if (tempWalletList.isNotEmpty) {
            orderListData.addAll(tempWalletList);
          }

          update();
        } else {
          // CustomSnackBar.error(errorList: tradeHistoryResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      openOrderHistoryLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  //buy
  double chargeAmountDataBuy = 0.0;
  calculateBuyChargeAndTotalPriceFromAmount() {
    try {
      double buyPriceAmount = double.parse(myBuyPriceAmountTextController.text);

      // double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double marketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);

      double totalPrice = (buyPriceAmount * marketPrice).toPrecision(4);

      myTotalPriceAmountTextController.text = '$totalPrice';
      //Charge calculation
      calculateBuyChargeData();
      update();
      calculateTotalAmountPercentageBuy();
    } catch (e) {
      printx('Error during calculation: $e');

      myTotalPriceAmountTextController.text = '0';
      chargeAmountDataBuy = 0;
      update();
    }
  }

  calculateBuyChargeData() {
    try {
      double totalPrice = double.parse((myTotalPriceAmountTextController.text == '' ? '0' : myTotalPriceAmountTextController.text)).toPrecision(4);
      double chargePercent = double.parse(tradeDetailsMarketPair?.percentChargeForBuy ?? '0');
      double chargeAmount = totalPrice * (chargePercent / 100);
      chargeAmountDataBuy = chargeAmount;
      update();
    } catch (e) {
      printx("error is charge calculation $e");
    }
  }

  //sell
  double chargeAmountDataSell = 0.0;
  calculateSellChargeAndTotalPriceFromAmount() {
    try {
      double sellPriceAmount = double.parse(mySellPriceAmountTextController.text);

      // double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double marketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);

      double totalPrice = (sellPriceAmount * marketPrice).toPrecision(4);

      myTotalPriceAmountTextController.text = '$totalPrice';
      calculateSellChargeData();
      update();
      calculateTotalAmountPercentageSell();
    } catch (e) {
      printx('Error during calculation: $e');

      myTotalPriceAmountTextController.text = '0';
      chargeAmountDataSell = 0;
      update();
    }
  }

  calculateSellChargeData() {
    try {
      double totalPrice = double.parse((myTotalPriceAmountTextController.text == '' ? '0' : myTotalPriceAmountTextController.text)).toPrecision(4);
      double chargePercent = double.parse(tradeDetailsMarketPair?.percentChargeForSell ?? '0');
      double chargeAmount = totalPrice * (chargePercent / 100);
      chargeAmountDataSell = chargeAmount;
      update();
    } catch (e) {
      printx("error is charge calculation $e");
    }
  }

  calculateBuyChargePriceFromTotalPrice() {
    try {
      double chargePercent = double.parse(tradeDetailsMarketPair?.percentChargeForBuy ?? '0');

      double totalPriceAmount = double.parse(myTotalPriceAmountTextController.text == '' ? '0' : myTotalPriceAmountTextController.text).toPrecision(4);

      // double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double marketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);

      double totalPrice = totalPriceAmount / marketPrice;

      double chargeAmount = totalPrice * (chargePercent / 100);

      double totalPriceWithCharges = (totalPrice + chargeAmount).toPrecision(4);

      myBuyPriceAmountTextController.text = '$totalPriceWithCharges';
      //Charge calculation
      calculateBuyChargeData();
      calculateTotalAmountPercentageBuy();
      update();
    } catch (e) {
      printx('Error during calculation: $e');

      myBuyPriceAmountTextController.text = '0';
      chargeAmountDataBuy = 0;
      update();
    }
  }

  //sell
  calculateSellChargePriceFromTotalPrice() {
    try {
      double chargePercent = double.parse(tradeDetailsMarketPair?.percentChargeForBuy ?? '0');

      double totalPriceAmount = double.parse(myTotalPriceAmountTextController.text == '' ? '0' : myTotalPriceAmountTextController.text).toPrecision(4);

      // double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double marketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);

      double totalPrice = totalPriceAmount / marketPrice;

      double chargeAmount = totalPrice * (chargePercent / 100);

      double totalPriceWithCharges = (totalPrice + chargeAmount).toPrecision(4);

      mySellPriceAmountTextController.text = '$totalPriceWithCharges';
      //Calculate charge
      calculateSellChargeData();
      calculateTotalAmountPercentageSell();

      update();
    } catch (e) {
      printx('Error during calculation: $e');

      mySellPriceAmountTextController.text = '0';
      chargeAmountDataSell = 0;
      update();
    }
  }

  double enterAmountPercentageBuy = 0;

  calculateTotalAmountPercentageBuy() {
    try {
      double enteredAmount = double.parse(myTotalPriceAmountTextController.text ?? '0.0').toPrecision(4) ?? 0.0;

      double balance = double.parse(marketCurrencyWallet?.balance ?? '0.0');

      // Calculate the percentage
      double percentage = (enteredAmount / balance) * 100;

      // Update a text controller or print the result as needed
      printx('Entered amount is $percentage% of the balance.');
      enterAmountPercentageBuy = percentage.clamp(0, 100);
      update();
    } catch (e) {
      enterAmountPercentageBuy = 0;
      update();
    }
  }

  double enterAmountPercentageSell = 0;

  calculateTotalAmountPercentageSell() {
    try {
      // Parse the entered amount, default to 0.0 if parsing fails
      double totalAmount = double.parse(myTotalPriceAmountTextController.text ?? '0.0').toPrecision(4) ?? 0.0;

      // Parse the balance, default to 0.0 if parsing fails
      double sellWalletBalance = double.parse(coinWallet?.balance ?? '0.0');
      // double sellWalletCurrencyMarketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double sellWalletCurrencyMarketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);
      // Calculate the percentage
      double percentage = (totalAmount / (sellWalletBalance * sellWalletCurrencyMarketPrice)) * 100;

      // Update a text controller or print the result as needed
      printx('Entered amount is $percentage% of the balance.');
      enterAmountPercentageSell = percentage.clamp(0, 100);
      update();
    } catch (e) {
      enterAmountPercentageSell = 0;
      update();
    }
  }

  //change amount from slider
  calculateTotalPriceAmountFromPercentageBuy(double percentage) {
    try {
      // set percentage
      enterAmountPercentageBuy = percentage;

      double balance = double.parse(marketCurrencyWallet?.balance ?? '0.0');

      double buyPriceAmount = ((percentage / 100) * balance).toPrecision(4);

      // Update the buy price text controller
      myTotalPriceAmountTextController.text = '$buyPriceAmount';
      calculateBuyChargePriceFromTotalPrice();
      update();
    } catch (e) {
      printx('Error during calculation: $e');
      myTotalPriceAmountTextController.text = '0.0';

      update();
    }
  }

  calculateTotalPriceAmountFromPercentageSell(double percentage) {
    try {
      // set percentage
      enterAmountPercentageSell = percentage;
      double sellWalletBalance = double.parse(coinWallet?.balance ?? '0.0');
      // double sellWalletCurrencyMarketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      double sellWalletCurrencyMarketPrice = double.parse(myMarketPriceTextController.text == '' ? '0' : myMarketPriceTextController.text);

      double sellPriceAmountInCoin = (percentage / 100) * sellWalletBalance;

      double sellPriceAmount = (sellPriceAmountInCoin * sellWalletCurrencyMarketPrice).toPrecision(4);

      // Update the buy price text controller
      myTotalPriceAmountTextController.text = '$sellPriceAmount';
      calculateSellChargePriceFromTotalPrice();
      update();
    } catch (e) {
      printx('Error during calculation: $e');
      myTotalPriceAmountTextController.text = '0.0';

      update();
    }
  }

//Create order
  bool orderCreatingLoading = false;
  Future createNewOrder({
    String symbolID = '',
  }) async {
    try {
      orderCreatingLoading = true;
      update();

      double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      String myInputMarketPrice = myMarketPriceTextController.text;

      ResponseModel responseData = await marketTradeRepo.orderCreateBuyOrSell(
        symbolID: symbolID == '' ? tradeSymbol : symbolID,
        rate: selectedOrderType == 0
            ? myInputMarketPrice
            : selectedOrderType == 1
                ? "$marketPrice"
                : "-1",
        amount: myBuyPriceAmountTextController.text,
        orderSide: '1',
        orderType: selectedOrderType == 0
            ? "1"
            : selectedOrderType == 1
                ? "2"
                : "-1",
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        // await loadOrderListDataList(hotRefresh: true, isBgLoad: true, symbolID: symbolID);
        await initialData(
          symbolID: symbolID == '' ? tradeSymbol : symbolID,
          isBgLoad: true,
        );
        // Get.back();
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      orderCreatingLoading = false;
      update();
    }
  }

//Sell Coin
  bool orderSellingLoading = false;
  Future sellNewOrderCoin({
    String symbolID = '',
  }) async {
    try {
      orderSellingLoading = true;
      update();

      double marketPrice = double.parse(tradeDetailsMarketData?.price ?? '0');
      String myInputMarketPrice = myMarketPriceTextController.text;

      ResponseModel responseData = await marketTradeRepo.orderCreateBuyOrSell(
        symbolID: symbolID == '' ? tradeSymbol : symbolID,
        rate: selectedOrderType == 0
            ? myInputMarketPrice
            : selectedOrderType == 1
                ? "$marketPrice"
                : "-1",
        amount: mySellPriceAmountTextController.text,
        orderSide: '2',
        orderType: selectedOrderType == 0
            ? "1"
            : selectedOrderType == 1
                ? "2"
                : "-1",
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        await initialData(
          symbolID: symbolID == '' ? tradeSymbol : symbolID,
          isBgLoad: true,
        );
        // Get.back();
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      orderSellingLoading = false;
      update();
    }
  }

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
    String symbolID = '-1',
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
        if (updateOrderRateOrderType == 'amount') {
          orderListData.firstWhere((element) => element.id == orderID).amount = amountController.text;
        }
        if (updateOrderRateOrderType == 'rate') {
          orderListData.firstWhere((element) => element.id == orderID).rate = amountController.text;
        }

        update();
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
        updateOrderRateOrAmountOrderID = "-1";
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
      initialData(isBgLoad: true, symbolID: tradeSymbol, orderListLoad: false);
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
        //remove order
        orderListData.removeWhere((element) => element.id == orderID);

        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
      initialData(isBgLoad: true, symbolID: tradeSymbol, orderListLoad: false);
    } catch (e) {
      printx(e.toString());
    } finally {
      cancelOrderRateLoadingID = "-1";
      update();
    }
  }

  bool coinAddToFavLoading = false;
  Future addToFav({
    String symbolID = '-1',
  }) async {
    coinAddToFavLoading = true;
    update();
    try {
      ResponseModel responseData = await marketTradeRepo.addTtoFav(
        symbolID: symbolID == '' ? tradeSymbol : symbolID,
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
      initialData(isBgLoad: true, symbolID: tradeSymbol, orderListLoad: true);
    } catch (e) {
      printx(e.toString());
    } finally {
      coinAddToFavLoading = false;
      update();
    }
  }

  String coinAddToFavSymbol = "-1";

  Future addToFavFromSearch({
    String itemID = '-1',
    String symbolID = '-1',
  }) async {
    coinAddToFavSymbol = symbolID;
    update();
    try {
      ResponseModel responseData = await marketTradeRepo.addTtoFav(
        symbolID: symbolID,
      );

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseData.responseJson));

      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
        if (model.remark?.toLowerCase() == "pair_added") {
          marketPairListDataModelData.data?.favoritePairId?.add(itemID);
        } else if (model.remark?.toLowerCase() == "pair_removed") {
          marketPairListDataModelData.data?.favoritePairId?.remove(itemID);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      coinAddToFavSymbol = "-1";
      update();
    }
  }

  //Change Coin Part

  //Market pair list under currency tab
  bool isMarketPairTabDataListLoading = true;
  MarketPairListDataModel marketPairListDataModelData = MarketPairListDataModel();
  List<MarketSinglePairData> marketPairDataList = [];
  List<MarketSinglePairData> filteredMarketPairDataList = [];
  int marketPage = 0;
  String? nextPageUrlMarket;

  loadMarketPairDataList({String marketID = '', String search = '', bool hotRefresh = false}) async {
    if (hotRefresh) {
      marketPage = 1;
      isMarketPairTabDataListLoading = true;
      update();
    } else {
      marketPage = marketPage + 1;
      // page = 1;
      if (marketPage == 1) {
        if (marketPairDataList.isEmpty) {
          marketPairDataList.clear();
          isMarketPairTabDataListLoading = true;
        }

        update();
      }
    }
    update();

    try {
      ResponseModel responseData = await marketTradeRepo.getMarketPairDataBasedOnMarketID(
        marketID: marketID,
        search: search,
        page: marketPage,
      );
      if (responseData.statusCode == 200) {
        final marketPairListDataModel = marketPairListDataModelFromJson(responseData.responseJson);

        marketPairListDataModelData = marketPairListDataModel;

        if (marketPairListDataModel.status?.toLowerCase() == MyStrings.success) {
          List<MarketSinglePairData> tempMarketAPairDataList = marketPairListDataModel.data?.pairs?.data ?? [];
          if (hotRefresh) {
            marketPairDataList.clear();
            filteredMarketPairDataList.clear();
          }
          if (tempMarketAPairDataList.isNotEmpty) {
            marketPairDataList.addAll(tempMarketAPairDataList);
            filteredMarketPairDataList = marketPairDataList;
          }

          if (marketPairListDataModel.data?.pairs?.currentPage != marketPairListDataModel.data?.pairs?.lastPage) {
            if (marketPage < int.parse((marketPairListDataModel.data?.pairs?.lastPage ?? -1).toString())) {
              loadMarketPairDataList(marketID: marketID, search: search);
            }
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: marketPairListDataModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isMarketPairTabDataListLoading = false;
      update();
    }
  }

  bool hasNextMarket() {
    return nextPageUrlMarket != null && nextPageUrlMarket!.isNotEmpty && nextPageUrlMarket != 'null' ? true : false;
  }

  //Filtering
  TextEditingController searchTextController = TextEditingController();
  bool isSearchFilter = false;

  String filterType = '';
  bool isFavFilter = false;

  bool isPriceFilter = false;
  bool isPriceAsc = true;

  bool is1hFilter = false;
  bool is1hAsc = true;

  bool isVolFilter = false;
  bool isVolAsc = true;
  resetAllFilterValue() {
    isFavFilter = false;
    isPriceFilter = false;
    is1hFilter = false;
    isVolFilter = false;
    update();
  }

  void filterMarketPairData({String filterTypeParam = '', bool toggleOrder = false}) {
    //Favorite filter
    if (filterTypeParam == 'search') {
      if (searchTextController.text != '') {
        isSearchFilter = true;
        filteredMarketPairDataList = marketPairDataList.where((item) {
          return (item.coin?.symbol?.toLowerCase().contains(searchTextController.text.toLowerCase()) ?? false) || (item.market?.currency?.symbol?.toLowerCase().contains(searchTextController.text.toLowerCase()) ?? false);
        }).toList();
      } else {
        isSearchFilter = false;
        filteredMarketPairDataList = marketPairDataList.toList();
      }

      update();
    }
    if (filterTypeParam == 'fav') {
      if (isFavFilter == false) {
        isFavFilter = true;

        filteredMarketPairDataList = filteredMarketPairDataList.where((item) => marketPairListDataModelData.data?.favoritePairId?.contains(item.id?.toString()) ?? false).toList();
      } else {
        isFavFilter = false;
        filteredMarketPairDataList = marketPairDataList.toList();
      }

      update();
    }

    if (filterTypeParam == 'price') {
      if (isPriceFilter == false) {
        isPriceFilter = true;
        if (toggleOrder) {
          isPriceAsc = !isPriceAsc;
        }
        filteredMarketPairDataList = filteredMarketPairDataList.toList()
          ..sort((a, b) {
            double priceA = double.tryParse(a.marketData?.price ?? '0.0') ?? 0.0;
            double priceB = double.tryParse(b.marketData?.price ?? '0.0') ?? 0.0;

            // Compare prices based on order
            return !isPriceAsc ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
          });
      } else {
        isPriceFilter = false;
        filteredMarketPairDataList = marketPairDataList.toList();
      }
      update();
    }

    if (filterTypeParam == '1hFilter') {
      if (is1hFilter == false) {
        is1hFilter = true;
        if (toggleOrder) {
          is1hAsc = !is1hAsc;
        }
        filteredMarketPairDataList = filteredMarketPairDataList.toList()
          ..sort((a, b) {
            double priceA = double.tryParse(a.marketData?.percentChange1H ?? '0.0') ?? 0.0;
            double priceB = double.tryParse(b.marketData?.percentChange1H ?? '0.0') ?? 0.0;

            // Compare prices based on order
            return !is1hAsc ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
          });
      } else {
        is1hFilter = false;
        filteredMarketPairDataList = marketPairDataList.toList();
      }
      update();
    }

    if (filterTypeParam == 'volFilter') {
      if (isVolFilter == false) {
        isVolFilter = true;
        if (toggleOrder) {
          isVolAsc = !isVolAsc;
        }
        filteredMarketPairDataList = filteredMarketPairDataList.toList()
          ..sort((a, b) {
            double priceA = double.tryParse(a.marketData?.marketCap ?? '0.0') ?? 0.0;
            double priceB = double.tryParse(b.marketData?.marketCap ?? '0.0') ?? 0.0;

            // Compare prices based on order
            return !isVolAsc ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
          });
      } else {
        isVolFilter = false;
        filteredMarketPairDataList = marketPairDataList.toList();
      }
      update();
    }
  }

  bool checkItemIsFavorite({String itemID = '-1'}) {
    try {
      return marketPairListDataModelData.data?.favoritePairId?.contains(itemID.toString()) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Set Orderbook price to InputBox
  setOrderBookPriceToInputBox(String value) {
    myMarketPriceTextController.text = value;
    calculateBuyChargeAndTotalPriceFromAmount();
  }

  //Long Press Counter
  Timer? incOrDecTimer;
  increaseOrDecreaseMyMarketPriceCounter({bool isIncrease = false, bool isLongPress = false}) {
    try {
      if (isLongPress == true) {
        incOrDecTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (isIncrease) {
            myMarketPriceTextController.text = ((double.parse(myMarketPriceTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          } else {
            myMarketPriceTextController.text = ((double.parse(myMarketPriceTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          }
          calculateBuyChargeAndTotalPriceFromAmount();
        });
      } else {
        if (isIncrease) {
          myMarketPriceTextController.text = ((double.parse(myMarketPriceTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        } else {
          myMarketPriceTextController.text = ((double.parse(myMarketPriceTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        }
        calculateBuyChargeAndTotalPriceFromAmount();
      }
    } catch (e) {
      myMarketPriceTextController.text = '0';
    }

    update();
  }

  increaseOrDecreaseBuyAmountCounter({bool isIncrease = false, bool isLongPress = false}) {
    try {
      if (isLongPress == true) {
        incOrDecTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (isIncrease) {
            myBuyPriceAmountTextController.text = ((double.parse(myBuyPriceAmountTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          } else {
            myBuyPriceAmountTextController.text = ((double.parse(myBuyPriceAmountTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          }
          calculateBuyChargeAndTotalPriceFromAmount();
        });
      } else {
        if (isIncrease) {
          myBuyPriceAmountTextController.text = ((double.parse(myBuyPriceAmountTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        } else {
          myBuyPriceAmountTextController.text = ((double.parse(myBuyPriceAmountTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        }
        calculateBuyChargeAndTotalPriceFromAmount();
      }
    } catch (e) {
      myBuyPriceAmountTextController.text = '0.1';
    }

    update();
  }

  increaseOrDecreaseSellAmountCounter({bool isIncrease = false, bool isLongPress = false}) {
    try {
      if (isLongPress == true) {
        incOrDecTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (isIncrease) {
            mySellPriceAmountTextController.text = ((double.parse(mySellPriceAmountTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          } else {
            mySellPriceAmountTextController.text = ((double.parse(mySellPriceAmountTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
          }
          calculateSellChargeAndTotalPriceFromAmount();
        });
      } else {
        if (isIncrease) {
          mySellPriceAmountTextController.text = ((double.parse(mySellPriceAmountTextController.text) + 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        } else {
          mySellPriceAmountTextController.text = ((double.parse(mySellPriceAmountTextController.text) - 0.01).clamp(0.00, double.infinity).toPrecision(2)).toString();
        }
        calculateSellChargeAndTotalPriceFromAmount();
      }
    } catch (e) {
      mySellPriceAmountTextController.text = '0.1';
    }

    update();
  }

  closeTimer() {
    incOrDecTimer?.cancel();
  }

  //Long Press Counter End

  int selectedOrderType = 0;
  List<String> orderTypeList = ['Limit', 'Market'];
  changeSelectedOrderType(int value) {
    selectedOrderType = value;
    if (selectedOrderType == 0) {
      myMarketPriceTextController.text = StringConverter.formatNumber((tradeDetailsMarketData?.price ?? '0.0').toString(), precision: marketTradeRepo.apiClient.getDecimalAfterNumber());
    }
    update();
  }

  bool checkUserIsLoggedInOrNot() {
    return marketTradeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
