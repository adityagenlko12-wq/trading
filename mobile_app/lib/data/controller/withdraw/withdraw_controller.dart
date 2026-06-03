import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/withdraw/withdraw_method_response_model.dart';
import '../../model/withdraw/withdraw_request_response_model.dart';
import '../../repo/withdraw/withdraw_repo.dart';

class WithdrawController extends GetxController with GetTickerProviderStateMixin {
  WithdrawRepo withdrawRepo;
  WithdrawController({required this.withdrawRepo});

  bool isLoading = true;
  String currency = '';

  List<WithdrawMethod> withdrawMethodList = [];
  List<WithdrawMethod> filteredWithdrawMethodList = [];
  WithdrawMethod? selectedWithdrawMethod = WithdrawMethod(name: MyStrings.selectOne, id: -1);
  List<WithdrawCurrency> withdrawCurrencyList = [];
  List<WithdrawCurrency> filteredWithdrawCurrencyList = [];
  WithdrawCurrency? selectedWithdrawCurrency;

  //spot and funding wallet data
  List<WithdrawWallet> spotWithdrawWalletList = [];
  List<WithdrawWallet> fundingWithdrawWalletList = [];

  TextEditingController amountController = TextEditingController();

  String withdrawLimit = '';
  String charge = '';
  String payableText = '';
  String conversionRate = '';
  String inLocal = '';

  List<String> authorizationList = [];
  String? selectedAuthorizationMode;

  void changeAuthorizationMode(String? value) {
    if (value != null) {
      selectedAuthorizationMode = value;
      update();
    }
  }

  double rate = 1;
  double mainAmount = 0;
  setWithdrawMethod(WithdrawMethod? method) {
    selectedWithdrawMethod = method;
    withdrawLimit = '${MyStrings.depositLimit.tr}: ${StringConverter.formatNumber(method?.minLimit ?? '-1')} - ${StringConverter.formatNumber(method?.maxLimit?.toString() ?? '-1')} ${method?.currency}';
    charge = '${MyStrings.charge.tr}: ${StringConverter.formatNumber(method?.fixedCharge?.toString() ?? '0')} + ${StringConverter.formatNumber(method?.percentCharge?.toString() ?? '0')} %';
    currency = selectedWithdrawMethod?.currency ?? '';
    String amt = amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;

    withdrawLimit = '${StringConverter.formatNumber(method?.minLimit?.toString() ?? '-1')} - ${StringConverter.formatNumber(method?.maxLimit?.toString() ?? '-1')} $currency';
    changeInfoWidgetValue(mainAmount);
    update();
  }

  void changeInfoWidgetValue(double amount) {
    currency = selectedWithdrawMethod?.currency ?? '';
    mainAmount = amount;
    double percent = double.tryParse(selectedWithdrawMethod?.percentCharge ?? '0') ?? 0;
    double percentCharge = (amount * percent) / 100;
    double temCharge = double.tryParse(selectedWithdrawMethod?.fixedCharge ?? '0') ?? 0;
    double totalCharge = percentCharge + temCharge;
    double payable = amount - totalCharge;
    payableText = '$payable $currency';
    charge = '${StringConverter.formatNumber('$totalCharge')} $currency';

    rate = double.tryParse(selectedWithdrawMethod?.rate ?? '0') ?? 0;
    conversionRate = '1 $currency = $rate ${selectedWithdrawMethod?.currency ?? ''}';
    inLocal = StringConverter.formatNumber('${payable * rate}');

    update();

    return;
  }

  selectWithdrawCurrency(WithdrawCurrency? selectedCurrency) {
    selectedWithdrawCurrency = selectedCurrency;
    selectedWithdrawMethod = WithdrawMethod(name: MyStrings.selectOne, id: -1);
    amountController.clear();
    filterWithdrawMethodBasedOnSelectedCurrency(selectedCurrency);
    update();
  }

  Future<void> loadWithdrawMethod({String selectedCurrencyFromParamsID = ''}) async {
    withdrawMethodList.clear();
    withdrawMethodList.add(selectedWithdrawMethod!);
    currency = selectedWithdrawMethod?.currency ?? '';
    isLoading = true;
    update();
    try {
      ResponseModel responseModel = await withdrawRepo.getAllWithdrawMethod();

      if (responseModel.statusCode == 200) {
        WithdrawMethodResponseModel model = WithdrawMethodResponseModel.fromJson(jsonDecode(responseModel.responseJson));

        if (model.status == 'success') {
          List<WithdrawMethod>? tempMethodList = model.data?.withdrawMethod;
          if (tempMethodList != null && tempMethodList.isNotEmpty) {
            withdrawMethodList.addAll(tempMethodList);
          }

          List<WithdrawCurrency>? tempCurrencyList = model.data?.currencies;
          if (tempCurrencyList != null && tempCurrencyList.isNotEmpty) {
            if (selectedWithdrawCurrency == null) {
              if (selectedCurrencyFromParamsID == '') {
                selectWithdrawCurrency(tempCurrencyList.first);
              } else {
                selectWithdrawCurrency(tempCurrencyList.where((element) => element.id == selectedCurrencyFromParamsID).first);
              }
            }
            withdrawCurrencyList.addAll(tempCurrencyList);
            filteredWithdrawCurrencyList = withdrawCurrencyList;
          }

          List<WithdrawWallet>? tempSpotWalletList = model.data?.spotWallets;
          if (tempSpotWalletList != null && tempSpotWalletList.isNotEmpty) {
            spotWithdrawWalletList.addAll(tempSpotWalletList);
          }
          List<WithdrawWallet>? tempFundingWalletList = model.data?.fundingWallets;
          if (tempFundingWalletList != null && tempFundingWalletList.isNotEmpty) {
            fundingWithdrawWalletList.addAll(tempFundingWalletList);
          }
        } else {
          // CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  void filterWithdrawCurrencyDataList(String searchText) {
    if (searchText.isEmpty) {
      filteredWithdrawCurrencyList = withdrawCurrencyList;
    } else {
      filteredWithdrawCurrencyList = withdrawCurrencyList.where((item) => item.symbol?.toLowerCase().contains(searchText.toLowerCase()) == true || item.name?.toLowerCase().contains(searchText.toLowerCase()) == true).toList();
    }

    update();
  }

  void filterWithdrawMethodBasedOnSelectedCurrency(WithdrawCurrency? withdrawCurrency) {
    if (withdrawCurrency == null) {
      filteredWithdrawMethodList = [];
    } else {
      filteredWithdrawMethodList = withdrawMethodList.where((item) => item.currency?.toLowerCase() == withdrawCurrency.symbol.toString().toLowerCase()).toList();
    }

    update();
  }

  //Submit withdraw request
  bool submitLoading = false;
  Future<void> submitWithdrawRequest({String walletType = 'spot'}) async {
    String amount = amountController.text;
    String id = selectedWithdrawMethod?.id.toString() ?? '-1';

    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: ['${MyStrings.please} ${MyStrings.enterAmount.toLowerCase()}']);
      return;
    }

    if (id == '-1') {
      CustomSnackBar.error(errorList: ['${MyStrings.please} ${MyStrings.selectPaymentMethod.toLowerCase()}']);
      return;
    }

    if (authorizationList.length > 1 && selectedAuthorizationMode?.toLowerCase() == MyStrings.selectOne) {
      CustomSnackBar.error(errorList: [MyStrings.selectAuthModeMsg]);
      return;
    }

    double amount1 = 0;
    double maxAmount = 0;

    try {
      amount1 = double.parse(amount);
      maxAmount = double.parse(selectedWithdrawMethod?.maxLimit ?? '0');
    } catch (e) {
      return;
    }

    if (maxAmount == 0 || amount1 == 0) {
      List<String> errorList = [MyStrings.invalidAmount];
      CustomSnackBar.error(errorList: errorList);
      return;
    }

    submitLoading = true;
    update();

    try {
      ResponseModel response = await withdrawRepo.addWithdrawRequest(
        methodCode: "${selectedWithdrawMethod?.id ?? -1}",
        amount: "$amount1",
        currency: selectedWithdrawMethod?.currency ?? "",
        walletType: walletType,
        authMode: selectedAuthorizationMode,
      );

      if (response.statusCode == 200) {
        WithdrawRequestResponseModel model = WithdrawRequestResponseModel.fromJson(jsonDecode(response.responseJson));
        if (model.status == MyStrings.success) {
          amountController.text = '';
          Get.offAndToNamed(RouteHelper.withdrawConfirmScreenScreen, arguments: [model, selectedWithdrawMethod?.name, selectedWithdrawMethod?.description]);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
        }
      } else {
        CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      submitLoading = false;
      update();
    }

    submitLoading = false;
    update();
  }

  bool isShowRate() {
    if (rate > 1 && currency.toLowerCase() != selectedWithdrawMethod?.currency?.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  setAmountToMax({required String walletType}) {
    if (selectedWithdrawMethod?.id.toString() != '-1') {
      if (selectedWithdrawCurrency != null) {
        if (walletType == 'spot') {
          String balance = spotWithdrawWalletList.where((element) => element.currencyId == (selectedWithdrawCurrency?.id ?? -1).toString()).first.balance ?? '0';

          amountController.text = balance;
          double amount = double.tryParse(balance.toString()) ?? 0;
          changeInfoWidgetValue(amount);
        } else {
          String balance = fundingWithdrawWalletList.where((element) => element.currencyId == (selectedWithdrawCurrency?.id ?? -1).toString()).first.balance ?? '0';
          amountController.text = balance;
          double amount = double.tryParse(balance.toString()) ?? 0;
          changeInfoWidgetValue(amount);
        }
        update();
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.selectPaymentGateway]);
    }
  }

  String getCurrentWalletAmount({required String walletType}) {
    if (selectedWithdrawCurrency != null) {
      if (walletType == 'spot') {
        String balance = spotWithdrawWalletList.where((element) => element.currencyId == (selectedWithdrawCurrency?.id ?? -1).toString()).first.balance ?? '0';

        return balance;
      } else {
        String balance = fundingWithdrawWalletList.where((element) => element.currencyId == (selectedWithdrawCurrency?.id ?? -1).toString()).first.balance ?? '0';

        return balance;
      }
    }

    return "0.0";
  }

  void clearPreviousValue() {
    withdrawMethodList.clear();
    amountController.text = '';
    rate = 1;
    submitLoading = false;
    selectedWithdrawMethod = WithdrawMethod(name: MyStrings.selectOne, id: -1);
  }

  TabController? withdrawTabController;
  int currentTabIndex = 0;

  loadWithdrawTabsData() {
    withdrawTabController = TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
  }

  changeTabIndex(int value) {
    currentTabIndex = value;
    update();

    withdrawTabController?.animateTo(value);
  }

  int spotWalletStep = 1;
  int fundingWalletStep = 1;

  changeSpotWalletStep(int value) {
    spotWalletStep = value;
    update();
  }

  changeFundingWalletStep(int value) {
    fundingWalletStep = value;
    update();
  }

  bool checkUserIsLoggedInOrNot() {
    return withdrawRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
