// Import necessary dependencies or models

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/data/repo/transfer/transfer_repository.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/transfer/transfer_response_model.dart';
import '../../model/wallet/wallet_list_model.dart';
import '../../repo/wallet/wallet_repository.dart';

class TransferController extends GetxController with GetTickerProviderStateMixin {
  WalletRepository walletRepository;
  TransferRepository transferRepository;

  TransferController({required this.walletRepository, required this.transferRepository});

  int currentIndex = 0;

  TabController? transferTabController;
  @override
  void onInit() {
    super.onInit();
    loadTransferTabsData();
  }

  loadTransferTabsData() {
    transferTabController = TabController(initialIndex: currentIndex, length: 2, vsync: this);
  }

  changeTabIndex(int value) {
    currentIndex = value;
    update();
    printx(currentIndex);
  }

  //Transfer code

  TextEditingController usernameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  // Wallet List
  int page = 0;
  String? nextPageUrl;
  WalletListModel walletListModelData = WalletListModel();
  bool isWalletListLoading = true;
  List<WalletData> walletDataList = [];
  List<WalletData> filteredWalletDataList = [];
  WalletData? selectedWalletData;

  changeSelectedWalletData(WalletData walletData) {
    selectedWalletData = walletData;
    amountController.clear();
    update();
  }

  loadAllWalletListByWalletType({String type = 'spot', bool hotRefresh = false, String selectedCurrencyFromParamsID = ''}) async {
    if (hotRefresh) {
      walletDataList.clear();
      page = 0;
      update();
    }
    page = page + 1;
    if (page == 1) {
      walletDataList.clear();
      isWalletListLoading = true;
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
            //set first wallet to selected
            // selectedWalletData ??= tempWalletList.first;

            if (selectedWalletData == null) {
              if (selectedCurrencyFromParamsID == '') {
                changeSelectedWalletData(tempWalletList.first);
              } else {
                changeSelectedWalletData(tempWalletList.where((element) => element.currency?.id == selectedCurrencyFromParamsID).first);
              }
            }

            //add all data to list;
            walletDataList.addAll(tempWalletList);
            filteredWalletDataList = walletDataList;
          }

          update();
        } else {
          // CustomSnackBar.error(errorList: walletListModelData.message?.error  ?? [MyStrings.somethingWentWrong]);
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

  void filterWalletDataList(String searchText) {
    if (searchText.isEmpty) {
      filteredWalletDataList = walletDataList;
    } else {
      filteredWalletDataList = walletDataList.where((item) => item.currency?.symbol?.toLowerCase().contains(searchText.toLowerCase()) == true || item.currency?.name?.toLowerCase().contains(searchText.toLowerCase()) == true).toList();
    }

    update();
  }
  // transfer to user

  setAmountToMax() {
    amountController.text = selectedWalletData?.balance ?? '0.0';
    changeChargeAmount(amountController.text);
    update();
  }

  //transfer charge calculate
  String chargeAmount = '0.0';
  String amountWithCharge = '0.0';
  changeChargeAmount(String value) {
    double amount = double.tryParse(value.toString()) ?? 0;
    double percent = double.tryParse(walletRepository.apiClient.getChargePercent()) ?? 0;

    double chargeAmounts = (amount / 100) * percent;
    double totalAmount = amount + chargeAmounts;

    chargeAmount = chargeAmounts.toString();
    amountWithCharge = totalAmount.toString();

    update();
  }

  bool isSubmitLoading = false;
  Future transferUserToUserData() async {
    isSubmitLoading = true;
    if (selectedWalletData == null) {
      CustomSnackBar.error(errorList: [MyStrings.selectAWallet]);
      return;
    }

    String amount = amountController.text.toString();

    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount]);

      return;
    }

    update();

    try {
      ResponseModel responseModel = await transferRepository.transferBalanceUserToUser(amount: amount, username: usernameController.text, currency: selectedWalletData?.currencyId ?? "-1", walletType: 'spot');

      if (responseModel.statusCode == 200) {
        final transferResponseModel = transferResponseModelFromJson(responseModel.responseJson);

        if (transferResponseModel.status.toString().toLowerCase() == "success") {
          CustomSnackBar.success(successList: transferResponseModel.message?.success ?? [MyStrings.somethingWentWrong]);
          Get.offAndToNamed(RouteHelper.transferDetailsScreen, arguments: transferResponseModel);
        } else {
          CustomSnackBar.error(errorList: transferResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(
          errorList: [responseModel.message],
        );
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isSubmitLoading = false;

      update();
    }
  }

  // Transfer wallet to wallet

  List<Map> transferWalletType = [
    {
      'name': 'spot',
      'fullName': MyStrings.spotWallet.tr,
    },
    {
      'name': 'funding',
      'fullName': MyStrings.fundingWallet.tr,
    },
  ];
  void swapWalletType() {
    if (transferWalletType.length == 2) {
      Map<String, dynamic> temp = Map.from(transferWalletType[0]);
      transferWalletType[0] = Map.from(transferWalletType[1]);
      transferWalletType[1] = temp;
      printx('Wallets swapped. Current wallets: $transferWalletType');
    } else {
      printx('Invalid number of wallets.');
    }
    update();
  }

  // WalletTypes? walletType = transferRepository.apiClient.getWalletTypes();

  Future transferWalletToWalletData() async {
    isSubmitLoading = true;
    if (selectedWalletData == null) {
      CustomSnackBar.error(errorList: [MyStrings.selectAWallet]);
      return;
    }

    String amount = amountController.text.toString();

    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount]);

      return;
    }

    update();

    try {
      ResponseModel responseModel = await transferRepository.transferBalanceWalletToWallet(amount: amount, currency: selectedWalletData?.currencyId ?? "-1", fromWallet: transferWalletType[0]['name'], toWallet: transferWalletType[1]['name']);

      if (responseModel.statusCode == 200) {
        final transferResponseModel = transferResponseModelFromJson(responseModel.responseJson);
        if (transferResponseModel.status.toString().toLowerCase() == "success") {
          CustomSnackBar.success(successList: transferResponseModel.message?.success ?? [MyStrings.somethingWentWrong]);
          Get.offAndToNamed(RouteHelper.transferDetailsScreen, arguments: transferResponseModel);
        } else {
          CustomSnackBar.error(errorList: transferResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(
          errorList: [responseModel.message],
        );
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isSubmitLoading = false;

      update();
    }
  }
}
