// Import necessary dependencies or models
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/data/model/market/crypto_currency_list_response_model.dart';

import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/transctions/transaction_response_model.dart';
import '../../model/wallet/single_wallet_details.dart';
import '../../repo/deposit/deposit_repo.dart';
import '../../repo/wallet/wallet_repository.dart';
import '../../repo/withdraw/withdraw_history_repo.dart';

class WalletHistoryController extends GetxController with GetTickerProviderStateMixin {
  WalletRepository walletRepository;
  WithdrawHistoryRepo withdrawHistoryRepo;
  DepositRepo depositRepo;
  WalletHistoryController({
    required this.walletRepository,
    required this.withdrawHistoryRepo,
    required this.depositRepo,
  });

  int currentIndex = 0;

  TabController? historyTabController;
  @override
  void onInit() {
    super.onInit();
    loadHistoryTabsData();
    getAllCryptoListData();
  }

  loadHistoryTabsData() {
    historyTabController = TabController(initialIndex: currentIndex, length: 4, vsync: this);
  }

  changeTabIndex(int value) {
    currentIndex = value;
    update();
    if (currentIndex == 0) {
      initialTransactionHistory(selectedRemarkType: 'all');
    }
    if (currentIndex == 1) {
      initialTransactionHistory(selectedRemarkType: 'deposit');
    }
    if (currentIndex == 2) {
      initialTransactionHistory(selectedRemarkType: 'withdraw');
    }
    if (currentIndex == 3) {
      initialTransactionHistory(selectedRemarkType: 'transfer');
    }
  }

  //DATA

  bool isLoading = true;
  final formKey = GlobalKey<FormState>();

  List<String> transactionTypeList = ["All", "Plus", "Minus"];
  List<Remarks> remarksList = [
    (Remarks(remark: "All")),
  ];

  List<TransactionSingleData> transactionList = [];

  String? nextPageUrl;
  String trxSearchText = '';
  String currency = '';

  int page = 0;
  int index = 0;

  TextEditingController trxController = TextEditingController();

  String selectedRemark = "All";
  String selectedCurrency = "All";
  String selectedTrxType = "All";
  void initialTransactionHistory({String selectedRemarkType = 'All', String selectedTrxTypeParam = 'All', bool isBgLoad = false}) async {
    page = 0;
    selectedRemark = selectedRemarkType;
    selectedCurrency = selectedTrxTypeParam;
    selectedTrxType = "All";
    trxController.text = '';
    trxSearchText = '';

    if (isBgLoad == false) {
      isLoading = true;
      transactionList.clear();
      update();
    }
    await loadTransaction();
    isLoading = false;
    update();
  }

  Future<void> loadTransaction() async {
    try {
      page = page + 1;

      if (page == 1) {
        currency = walletRepository.apiClient.getCurrencyOrUsername();
        remarksList.clear();
        remarksList.insert(0, Remarks(remark: "All"));
      }

      ResponseModel responseModel = await walletRepository.getWalletTransactionList(
        page,
        type: selectedTrxType.toLowerCase(),
        remark: selectedRemark.toLowerCase(),
        searchText: trxSearchText,
        symbol: selectedCurrency,
      );

      if (responseModel.statusCode == 200) {
        TransactionResponseModel model = TransactionResponseModel.fromJson(jsonDecode(responseModel.responseJson));

        nextPageUrl = model.data?.transactions?.nextPageUrl;

        if (model.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
          List<TransactionSingleData>? tempDataList = model.data?.transactions?.data;
          if (page == 1) {
            List<Remarks>? tempRemarksList = model.data?.remarks;

            if (tempRemarksList != null && tempRemarksList.isNotEmpty) {
              for (var element in tempRemarksList) {
                if (element.remark != null && element.remark?.toLowerCase() != 'null' && element.remark!.isNotEmpty) {
                  remarksList.add(element);
                }
              }
            }
          }

          if (tempDataList != null && tempDataList.isNotEmpty) {
            transactionList.addAll(tempDataList);
          }
        } else {
          CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong],
          );
        }
      } else {
        CustomSnackBar.error(
          errorList: [responseModel.message],
        );
      }
      update();
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void changeSelectedRemark(String remarks) {
    selectedRemark = remarks;
    update();
  }

  void changeSelectedCurrency(String coin) {
    selectedCurrency = coin;
    update();
  }

  void changeSelectedTrxType(String trxType) {
    selectedTrxType = trxType;
    update();
  }

  bool filterLoading = false;

  Future<void> filterData() async {
    trxSearchText = trxController.text;
    page = 0;
    filterLoading = true;
    update();
    transactionList.clear();

    await loadTransaction();

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

  //get all crypto list data
  bool isLoadingCrypto = false;
  List<CryptoCurrencyData> cryptoCurrencyData = [];
  getAllCryptoListData() async {
    isLoadingCrypto = true;
    update();
    try {
      ResponseModel responseModel = await walletRepository.getAllCryptoList();
      if (responseModel.statusCode == 200) {
        final cryptoCurrencyListResponseModel = cryptoCurrencyListResponseModelFromJson(responseModel.responseJson);

        if (cryptoCurrencyListResponseModel.status?.toLowerCase() == MyStrings.success) {
          cryptoCurrencyData.clear();
          cryptoCurrencyData.insert(0, CryptoCurrencyData(symbol: "All"));
          List<CryptoCurrencyData>? tempListData = cryptoCurrencyListResponseModel.data?.currencies;

          if (tempListData != null && tempListData.isNotEmpty) {
            cryptoCurrencyData.addAll(tempListData);
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: cryptoCurrencyListResponseModel.message?.error  ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoadingCrypto = false;
      update();
    }
  }
}
