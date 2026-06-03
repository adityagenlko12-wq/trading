import 'dart:async';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/repo/home/home_repo.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/url_container.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/blogs/blogs_model.dart';
import '../../model/dashboard/dashboard_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/market/market_data_list_model.dart';
import '../../model/market/market_over_view_model.dart' hide MarketData, Message, HtmlClasses, Coin, Pairs, Market, Currency;
import '../../model/user/user_model.dart';
import '../pusher_controller/pusher_service_controller.dart';

class HomeController extends GetxController {
  HomeRepo homeRepo;
  HomeController({required this.homeRepo});
  String isKycVerified = '1';

  bool isLoading = true;
  String email = "";
  String fullName = "";
  String username = "";
  String siteName = "";
  String profileImageUrl = '';
  String defaultCurrency = "";
  String defaultCurrencySymbol = "";
  String estimatedBalance = "0.0";
  GeneralSettingResponseModel generalSettingResponseModel = GeneralSettingResponseModel();

  Future<void> initialData({bool shouldLoad = true}) async {
    if (marketDataListPairData.isEmpty) {
      isLoading = shouldLoad ? true : false;
    } else {
      isLoading = false;
    }
    showBalance = homeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.showBalanceKey) ?? false;
    update();

    await loadGeneralSettingsData();
    await loadDashboardData();
    await loadMarketOverviewData();
    await loadLatestBlogNewsList();
    await loadMarketListPairData(hotRefresh: true);
    isLoading = false;
    update();
  }

  Future<void> loadGeneralSettingsData() async {
    defaultCurrency = homeRepo.apiClient.getCurrencyOrUsername();
    username = homeRepo.apiClient.getCurrencyOrUsername(isCurrency: false);
    email = homeRepo.apiClient.getUserEmail();
    defaultCurrencySymbol = homeRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    generalSettingResponseModel = homeRepo.apiClient.getGSData();
    siteName = generalSettingResponseModel.data?.generalSetting?.siteName ?? "";
  }

  bool showBalance = false;
  changeShowBalanceState() async {
    showBalance = !showBalance;
    await homeRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.showBalanceKey, showBalance);
    update();
  }

  //Dashboard data
  DashboardResponseModel dashboardResponseModel = DashboardResponseModel();
  User? user = User();
  loadDashboardData() async {
    try {
      ResponseModel responseModel = await homeRepo.getDashboardData();

      if (responseModel.statusCode == 200) {
        dashboardResponseModel = dashboardResponseModelFromJson(responseModel.responseJson);

        if (dashboardResponseModel.status?.toLowerCase() == MyStrings.success) {
          user = dashboardResponseModel.data?.user;
          isKycVerified = dashboardResponseModel.data?.user?.kv ?? '1';
          email = dashboardResponseModel.data?.user?.email ?? '';
          username = dashboardResponseModel.data?.user?.username ?? '';
          fullName = dashboardResponseModel.data?.user?.getFullName() ?? '';
          estimatedBalance = dashboardResponseModel.data?.estimatedBalance ?? '0.0';
          var imageUrl = dashboardResponseModel.data?.user?.image == null ? '' : '${dashboardResponseModel.data?.user?.image}';
          if (imageUrl.isNotEmpty && imageUrl != 'null') {
            profileImageUrl = '${UrlContainer.domainUrl}/assets/images/user/profile/$imageUrl';
          }
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, username);
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, email);
        } else {
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '');
          await homeRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, '');
          await homeRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
          await homeRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.fingerPrintLoginEnable, false);
        }
      }
    } catch (e) {
      printx(e.toString());
    }
  }

  int page = 0;
  String marketListType = 'all';
  String? nextPageUrl;
  bool isMarketPairListDataLoading = true;

  List<MarketPairSingleData> marketDataListPairData = [];

  String loadMarketPairDataType = 'all';

  loadMarketListPairData({String type = 'all', bool hotRefresh = false}) async {
    marketListType = type;
    loadMarketPairDataType = type;
    update();

    if (hotRefresh) {
      page = 1;
      isMarketPairListDataLoading = true;
      update();
    } else {
      page = page + 1;
      // page = 1;
      if (page == 1) {
        if (marketDataListPairData.isEmpty) {
          marketDataListPairData.clear();
          isMarketPairListDataLoading = true;
        }

        update();
      }
    }
    try {
      ResponseModel marketDataList = await homeRepo.getMarketDataListApi(page: page.toString(), type: type);
      if (marketDataList.statusCode == 200) {
        var marketDataListModel = marketDataListModelFromJson(marketDataList.responseJson);

        if (marketDataListModel.status?.toLowerCase() == MyStrings.success) {
          if (hotRefresh) {
            marketDataListPairData.clear();
          }
          nextPageUrl = marketDataListModel.data?.pairs?.nextPageUrl;

          List<MarketPairSingleData>? tempListData = marketDataListModel.data?.pairs?.data;

          if (tempListData != null && tempListData.isNotEmpty) {
            marketDataListPairData.addAll(tempListData);
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: marketDataListModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [marketDataList.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isMarketPairListDataLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  //Overview Data
  bool isMarketOverviewDataLoading = true;
  MarketOverviewDataModel marketOverviewDataModelData = MarketOverviewDataModel();
  List<TopExchangesCoin> marketTopExchangeData = [];
  List<OverViewCoinModel> marketHighLightedCoinsData = [];
  List<OverViewCoinModel> marketNewCoinsData = [];

  loadMarketOverviewData() async {
    if (marketOverviewDataModelData.data == null) {
      // if data is empty then we will use a loader.
      isMarketOverviewDataLoading = true;
      update();
    }
    try {
      ResponseModel marketOverviewData = await homeRepo.getMarketOverViewData();
      if (marketOverviewData.statusCode == 200) {
        marketOverviewDataModelData = marketOverviewDataModelFromJson(marketOverviewData.responseJson);

        if (marketOverviewDataModelData.status?.toLowerCase() == MyStrings.success) {
          List<TopExchangesCoin>? tempTopExchange = marketOverviewDataModelData.data?.topExchangesCoins;
          marketTopExchangeData.clear();

          if (tempTopExchange != null && tempTopExchange.isNotEmpty) {
            marketTopExchangeData.addAll(tempTopExchange);
          }

          List<OverViewCoinModel>? tempHighLightedCoins = marketOverviewDataModelData.data?.highLightedCoins;
          if (tempHighLightedCoins != null && tempHighLightedCoins.isNotEmpty) {
            marketHighLightedCoinsData.clear();
            marketHighLightedCoinsData.addAll(tempHighLightedCoins);
          }

          List<OverViewCoinModel>? tempNewCoins = marketOverviewDataModelData.data?.newCoins;
          if (tempNewCoins != null && tempNewCoins.isNotEmpty) {
            marketNewCoinsData.clear();
            marketNewCoinsData.addAll(tempNewCoins);
          }

          update();
        } else {
          // CustomSnackBar.error(errorList: marketOverviewDataModelData.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [marketOverviewData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isMarketOverviewDataLoading = false;
      update();
    }
  }

  //Blog Section
  bool isBlogListLoading = true;
  BlogScreenResponseModel blogScreenResponseModel = BlogScreenResponseModel();
  List<BlogData> blogListData = [];
  String blogImagePath = '';

  loadLatestBlogNewsList() async {
    if (blogScreenResponseModel.data == null) {
      isBlogListLoading = true;
      update();
    }
    try {
      ResponseModel blogListModel = await homeRepo.latestBlogNewsListApi();
      if (blogListModel.statusCode == 200) {
        blogScreenResponseModel = blogScreenResponseModelFromJson(blogListModel.responseJson);
        blogImagePath = blogScreenResponseModel.data?.path ?? '';
        if (blogScreenResponseModel.status?.toLowerCase() == MyStrings.success) {
          List<BlogData>? tempBlog = blogScreenResponseModel.data?.blogs?.data;
          blogListData.clear();
          if (tempBlog != null && tempBlog.isNotEmpty) {
            blogListData.addAll(tempBlog);
          }

          update();
        } else {
          // CustomSnackBar.error(errorList: blogScreenResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [blogListModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isBlogListLoading = false;
      update();
    }
  }

  PusherServiceController pusherServiceController = Get.find();
  //Update market Data Based On  pusher event
  void updateMarketDataBasedOnPusherEvent() {
    if (pusherServiceController.marketData.isNotEmpty) {
      for (int i = 0; i < pusherServiceController.marketData.length; i++) {
        String currentId = pusherServiceController.marketData[i].id ?? "-1";
        // String currentIdSymbol = pusherServiceController.marketData[i].symbol ?? "-1";
        MarketData latestMarketSingleCoinData = pusherServiceController.marketData[i];

        //Top Exchange value change
        TopExchangesCoin? matchingElementTopExchangeCoin = marketTopExchangeData.firstWhere((element) => element.coin?.marketData?.id == currentId, orElse: () => TopExchangesCoin());

        if (matchingElementTopExchangeCoin.id != null) {
          var item = matchingElementTopExchangeCoin.coin?.marketData;
          // Update the price if a matching element is found
          item?.price = latestMarketSingleCoinData.price;
          item?.marketCap = latestMarketSingleCoinData.marketCap;
          item?.percentChange1H = latestMarketSingleCoinData.percentChange1H;
          item?.htmlClasses?.percentChange1H = latestMarketSingleCoinData.htmlClasses?.percentChange1H;
        }
        //Highlight coin value change
        OverViewCoinModel? matchingElementHighLight = marketHighLightedCoinsData.firstWhere((element) => element.marketData?.id == currentId, orElse: () => OverViewCoinModel());
        if (matchingElementHighLight.id != null) {
          var item = matchingElementHighLight.marketData;
          // Update the price if a matching element is found
          item?.price = latestMarketSingleCoinData.price;
          item?.marketCap = latestMarketSingleCoinData.marketCap;
          item?.percentChange1H = latestMarketSingleCoinData.percentChange1H;
          item?.htmlClasses?.percentChange1H = latestMarketSingleCoinData.htmlClasses?.percentChange1H;
        }

        //new coin value change
        OverViewCoinModel? matchingElementNewCoin = marketNewCoinsData.firstWhere((element) => element.marketData?.id == currentId, orElse: () => OverViewCoinModel());
        if (matchingElementNewCoin.id != null) {
          var item = matchingElementNewCoin.marketData;
          // Update the price if a matching element is found
          item?.price = latestMarketSingleCoinData.price;
          item?.marketCap = latestMarketSingleCoinData.marketCap;
          item?.percentChange1H = latestMarketSingleCoinData.percentChange1H;
          item?.htmlClasses?.percentChange1H = latestMarketSingleCoinData.htmlClasses?.percentChange1H;
        }
        //marketOver View Data
        MarketPairSingleData? matchingElementMarketElementData = marketDataListPairData.firstWhere((element) => element.marketData?.id == currentId, orElse: () => MarketPairSingleData());
        if (matchingElementMarketElementData.id != null) {
          var item = matchingElementMarketElementData.marketData;
          // Update the price if a matching element is found
          item?.price = latestMarketSingleCoinData.price;
          item?.marketCap = latestMarketSingleCoinData.marketCap;
          item?.percentChange1H = latestMarketSingleCoinData.percentChange1H;
          item?.htmlClasses?.percentChange1H = latestMarketSingleCoinData.htmlClasses?.percentChange1H;
        }
      }

      // pusherServiceController.marketData.clear();

      update();
    }
  }

  bool checkUserIsLoggedInOrNot() {
    return homeRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
