// Import necessary dependencies or models
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/wallet/single_wallet_details.dart';
import '../../repo/wallet/wallet_repository.dart';

class SingleCoinWalletDetailsController extends GetxController with GetTickerProviderStateMixin {
  WalletRepository walletRepository;

  SingleCoinWalletDetailsController({required this.walletRepository});

  bool showMoreWidget = false;
  bool showBalance = false;
  changeShowBalanceState() async {
    showBalance = !showBalance;
    await walletRepository.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.showBalanceKey, showBalance);
    update();
  }

  changeShowMoreWidgetState() async {
    showMoreWidget = !showMoreWidget;
    update();
  }

  TabController? walletTabController;
  int currentTabIndex = 0;

  loadWalletTabs() {
    walletTabController = TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
    showBalance = walletRepository.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.showBalanceKey) ?? false;
  }

  // Wallet List
  int page = 0;
  String? nextPageUrl;
  SingleWalletDetailsModel singleWalletDetailsModelData = SingleWalletDetailsModel();
  SingleWalletWidgetCounter? singleWalletWidgetCounter;
  bool isWalletDataLoading = false;
  List<TransactionSingleData> transactionData = [];

  loadSingleWalletDataByWalletType({String type = 'spot', String symbolCurrency = '', bool hotRefresh = false}) async {
    if (hotRefresh) {
      transactionData.clear();
      page = 0;
      update();
    }
    page = page + 1;
    if (page == 1) {
      transactionData.clear();
      isWalletDataLoading = true;
      update();
    }

    update();
    try {
      ResponseModel responseData = await walletRepository.getSingleWalletDetails(page, type: type, symbolCurrency: symbolCurrency);
      if (responseData.statusCode == 200) {
        final singleWalletDetailsModel = singleWalletDetailsModelFromJson(responseData.responseJson);

        singleWalletDetailsModelData = singleWalletDetailsModel;
        singleWalletWidgetCounter = singleWalletDetailsModel.data?.widget;

        if (singleWalletDetailsModel.status?.toLowerCase() == MyStrings.success) {
          nextPageUrl = singleWalletDetailsModel.data?.transactions?.nextPageUrl;

          List<TransactionSingleData> tempWalletList = singleWalletDetailsModel.data?.transactions?.data ?? [];

          if (tempWalletList.isNotEmpty) {
            transactionData.addAll(tempWalletList);
          }

          update();
        } else {
          CustomSnackBar.error(errorList: singleWalletDetailsModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isWalletDataLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  //get single wallet details
}
