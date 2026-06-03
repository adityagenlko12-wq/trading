import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/repo/market_trade/market_trade_repo.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/authorization/authorization_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/market/market_data_list_model.dart';
import '../../model/market/market_page_currency_list_model.dart';
import '../../model/market/market_pair_list_data_model.dart' hide MarketData, Message, Pairs, Market, Currency, Coin;
import '../pusher_controller/pusher_service_controller.dart';

class MarketController extends GetxController with GetTickerProviderStateMixin {
  MarketTradeRepo marketTradeRepo;

  MarketController({required this.marketTradeRepo});

  int currentIndex = 0;

  TabController? tabController;

  loadActionTabsData({required int length}) {
    tabController = TabController(initialIndex: currentIndex, length: length, vsync: this);
  }

  changeTabIndex(int value) {
    currentIndex = value;
    resetAllFilterValue();
    update();
  }

  //API PART

  bool isMarketDataLoading = true;

  initialMarketData() async {
    if (marketCurrencyDataList.data == null) {
      isMarketDataLoading = true;
      update();
    }
    // isMarketDataLoading = true;
    await loadMarketOverviewData();
    tabController?.animateTo(0);
    isMarketDataLoading = false;
    update();
  }

  MarketCurrencyDataList marketCurrencyDataList = MarketCurrencyDataList();
  List<CurrencyMarket> currencyMarketData = [];

  loadMarketOverviewData() async {
    try {
      ResponseModel responseData = await marketTradeRepo.getMarketCurrencyListData();
      if (responseData.statusCode == 200) {
        final marketCurrencyDataListModel = marketCurrencyDataListFromJson(responseData.responseJson);
        marketCurrencyDataList = marketCurrencyDataListModel;

        if (marketCurrencyDataListModel.status?.toLowerCase() == MyStrings.success) {
          List<CurrencyMarket> tempCurrencyMarketData = marketCurrencyDataListModel.data?.markets ?? [];
          currencyMarketData.clear();

          if (tempCurrencyMarketData.isNotEmpty) {
            currencyMarketData.insert(
                0,
                CurrencyMarket(
                  name: "All",
                  id: -1,
                ));
            currencyMarketData.addAll(tempCurrencyMarketData);
            loadActionTabsData(length: currencyMarketData.length);
            if (currencyMarketData.first.id == -1) {
              await loadMarketPairDataList(marketID: '', hotRefresh: true, shouldShowLoad: false);
            }
          }

          update();
        } else {
          CustomSnackBar.error(errorList: marketCurrencyDataListModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isMarketDataLoading = false;
      update();
    }
  }

  //Market pair list under currency tab
  bool isMarketPairTabDataListLoading = false;
  MarketPairListDataModel marketPairListDataModelData = MarketPairListDataModel();
  List<MarketSinglePairData> marketPairDataList = [];
  List<MarketSinglePairData> filteredMarketPairDataList = [];
  int marketPage = 0;
  String? nextPageUrlMarket;
  String marketID = '';
  String searchText = '';
  loadMarketPairDataList({String marketID = '', String search = '', bool hotRefresh = false, bool shouldShowLoad = true}) async {
    searchTextController.text = '';
    this.marketID = marketID;
    searchText = searchTextController.text;
    if (hotRefresh) {
      marketPage = 1;
      isMarketPairTabDataListLoading = shouldShowLoad;
    } else {
      marketPage = marketPage + 1;
      if (marketPage == 1) {
        if (marketPairDataList.isEmpty) {
          marketPairDataList.clear();
          isMarketPairTabDataListLoading = true;
        }
      }
    }

    update();

    try {
      ResponseModel responseData = await marketTradeRepo.getMarketPairDataBasedOnMarketID(
        marketID: marketID,
        search: searchText,
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
          nextPageUrlMarket = marketPairListDataModel.data?.pairs?.nextPageUrl;

          if (tempMarketAPairDataList.isNotEmpty) {
            marketPairDataList.addAll(tempMarketAPairDataList);
            filteredMarketPairDataList = marketPairDataList;
          }

          if (marketPairListDataModel.data?.pairs?.currentPage != marketPairListDataModel.data?.pairs?.lastPage) {
            if (marketPage < int.parse((marketPairListDataModel.data?.pairs?.lastPage ?? -1).toString())) {
              loadMarketPairDataList(marketID: marketID, search: searchText);
            }
          }
          update();
        } else {
          CustomSnackBar.error(errorList: marketPairListDataModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        // CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isMarketPairTabDataListLoading = false;
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

  bool hasNextMarket() {
    return nextPageUrlMarket != null && nextPageUrlMarket!.isNotEmpty && nextPageUrlMarket != 'null' ? true : false;
  }

  String favouriteCoinLoadingId = "-1";

  Future addToFav({
    String itemID = '-1',
    String symbolID = '-1',
  }) async {
    favouriteCoinLoadingId = symbolID;
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
      favouriteCoinLoadingId = "-1";
      update();
    }
  }

  PusherServiceController pusherServiceController = Get.find();
  //Update market Data Based On  pusher event
  void updateMarketDataBasedOnPusherEvent() {
    if (pusherServiceController.marketData.isNotEmpty) {
      for (int i = 0; i < pusherServiceController.marketData.length; i++) {
        String currentId = pusherServiceController.marketData[i].id ?? "-1";
        MarketData newMarketData = pusherServiceController.marketData[i];

        MarketSinglePairData? matchingElement = marketPairDataList.firstWhere((element) => element.marketData?.id == currentId, orElse: () => MarketSinglePairData());
        if (matchingElement.id != null) {
          // Update the price if a matching element is found
          matchingElement.marketData?.price = newMarketData.price;
          matchingElement.marketData?.marketCap = newMarketData.marketCap;
          matchingElement.marketData?.percentChange1H = newMarketData.percentChange1H;
          matchingElement.marketData?.htmlClasses?.percentChange1H = newMarketData.htmlClasses?.percentChange1H;
        }
      }
      filteredMarketPairDataList = marketPairDataList;
      // pusherServiceController.marketData.clear();

      update();
    }
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

  bool checkUserIsLoggedInOrNot() {
    return marketTradeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
