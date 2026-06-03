// Import necessary dependencies or models
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/general_setting/general_setting_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/wallet/wallet_list_model.dart';
import '../../repo/auth/general_setting_repo.dart';
import '../../repo/wallet/wallet_repository.dart';

class WalletController extends GetxController with GetTickerProviderStateMixin {
  WalletRepository walletRepository;
  GeneralSettingRepo generalSettingRepo;

  WalletController({required this.walletRepository, required this.generalSettingRepo});

  bool showBalance = false;

  changeShowBalanceState() async {
    showBalance = !showBalance;
    await walletRepository.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.showBalanceKey, showBalance);
    update();
  }

  TabController? walletTabController;
  int currentTabIndex = 0;

  loadWalletTabs() {
    walletTabController = TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
    showBalance = walletRepository.apiClient.sharedPreferences.getBool(
          SharedPreferenceHelper.showBalanceKey,
        ) ??
        false;
  }

  // Wallet List
  int page = 0;
  String? nextPageUrl;
  WalletListModel walletListModelData = WalletListModel();
  bool isWalletListLoading = true;
  List<WalletData> walletDataList = [];

  loadData() async {
    await updateGeneralSettingsData();
  }

  loadAllWalletListByWalletType({String type = 'spot', bool hotRefresh = false}) async {
    if (hotRefresh) {
      walletDataList.clear();
      page = 0;
      update();
    }
    page = page + 1;
    if (page == 1) {
      isWalletListLoading = true;
      walletDataList.clear();
      update();
    }

    update();
    try {
      ResponseModel responseData = await walletRepository.getAllWalletTypeBasedOnWalletType(page, type: type);
      if (responseData.statusCode == 200) {
        final walletListModel = walletListModelFromJson(responseData.responseJson);

        walletListModelData = walletListModel;

        if (walletListModel.status?.toLowerCase() == MyStrings.success) {
          nextPageUrl = walletListModel.data?.wallets?.nextPageUrl;
          List<WalletData> tempWalletList = walletListModel.data?.wallets?.data ?? [];
          // walletDataList.clear();
          if (tempWalletList.isNotEmpty) {
            walletDataList.addAll(tempWalletList);
          }

          update();
        } else {
          // CustomSnackBar.error(errorList: walletListModelData.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseData.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isWalletListLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  updateGeneralSettingsData() async {
    update();

    ResponseModel response = await generalSettingRepo.getGeneralSetting();

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        generalSettingRepo.apiClient.storeGeneralSetting(model);
        update();
      } else {
        List<String> message = [MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList: model.message?.error ?? message);
        return;
      }
    } else {
      return;
    }
  }

  bool checkUserIsLoggedInOrNot() {
    return walletRepository.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
