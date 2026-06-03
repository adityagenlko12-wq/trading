import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/route/route.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/deposit/deposit_insert_response_model.dart';
import '../../model/deposit/deposit_method_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/deposit/deposit_repo.dart';

class DepositController extends GetxController with GetTickerProviderStateMixin {
  DepositRepo depositRepo;
  DepositController({required this.depositRepo});

  //Deposit tabs
  TabController? depositTabController;
  int currentTabIndex = 0;

  loadDepositTabsData() {
    depositTabController = TabController(initialIndex: currentTabIndex, length: 2, vsync: this);
  }

  changeTabIndex(int value) {
    currentTabIndex = value;
    update();
    // printx(currentTabIndex);
    depositTabController?.animateTo(value);
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

  //get deposit all methods

  bool isDepositMethodLoading = true;
  List<DepositMethod> depositMethodList = [];
  List<DepositMethod> filteredDepositMethodList = [];
  List<DepositCurrency> depositCurrencyList = [];
  List<DepositCurrency> filteredDepositCurrencyList = [];
  DepositMethod? selectedDepositPaymentMethod = DepositMethod(name: MyStrings.selectOne, id: -1);
  DepositCurrency? selectedCurrency;

  TextEditingController amountController = TextEditingController();

  double rate = 1;
  double mainAmount = 0;
  String selectedValue = "";
  String depositLimit = "";
  String charge = "";
  String payable = "";
  String amount = "";
  String fixedCharge = "";
  String currency = '';
  String payableText = '';
  String conversionRate = '';
  String inLocal = '';

  selectDepositPaymentMethod(DepositMethod? method) {
    String amt = amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;
    selectedDepositPaymentMethod = method;
    currency = selectedDepositPaymentMethod?.currency ?? '';
    depositLimit = '${StringConverter.formatNumber(method?.minAmount?.toString() ?? '-1')} - ${StringConverter.formatNumber(method?.maxAmount?.toString() ?? '-1')} $currency';
    changeDepositChargeInfoWidgetValue(mainAmount);
    update();
  }

  selectDepositCurrency(DepositCurrency? currency) {
    selectedCurrency = currency;
    selectedDepositPaymentMethod = DepositMethod(name: MyStrings.selectOne, id: -1);

    filterDepositMethodBasedOnSelectedCurrency(selectedCurrency);

    update();
  }

  Future<void> getDepositAllMethodAndCurrencyList({String selectedCurrencyFromParamsID = ''}) async {
    depositMethodList.clear();
    depositMethodList.add(selectedDepositPaymentMethod!);
    currency = selectedDepositPaymentMethod?.currency ?? '';
    try {
      ResponseModel responseModel = await depositRepo.getDepositMethods();

      if (responseModel.statusCode == 200) {
        DepositMethodResponseModel methodsModel = DepositMethodResponseModel.fromJson(jsonDecode(responseModel.responseJson));

        if (methodsModel.message != null && methodsModel.message!.success != null) {
          List<DepositMethod>? tempList = methodsModel.data?.methods;
          if (tempList != null && tempList.isNotEmpty) {
            depositMethodList.addAll(tempList);
          }
          List<DepositCurrency>? tempCurrencyList = methodsModel.data?.currencies;
          if (tempCurrencyList != null && tempCurrencyList.isNotEmpty) {
            //set first wallet to selected

            if (selectedCurrency == null) {
              if (selectedCurrencyFromParamsID == '') {
                selectDepositCurrency(tempCurrencyList.first);
              } else {
                selectDepositCurrency(tempCurrencyList.where((element) => element.id == selectedCurrencyFromParamsID).first);
              }
            }

            //add all data to list;
            depositCurrencyList.addAll(tempCurrencyList);
            filteredDepositCurrencyList = depositCurrencyList;
          }
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
        return;
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isDepositMethodLoading = false;
      update();
    }
  }

  void filterDepositCurrencyDataList(String searchText) {
    if (searchText.isEmpty) {
      filteredDepositCurrencyList = depositCurrencyList;
    } else {
      filteredDepositCurrencyList = depositCurrencyList.where((item) => item.symbol?.toLowerCase().contains(searchText.toLowerCase()) == true || item.name?.toLowerCase().contains(searchText.toLowerCase()) == true).toList();
    }

    update();
  }

  void filterDepositMethodBasedOnSelectedCurrency(DepositCurrency? depositCurrency) {
    if (depositCurrency == null) {
      filteredDepositMethodList = [];
    } else {
      filteredDepositMethodList = depositMethodList.where((item) => item.currency?.toLowerCase() == depositCurrency.symbol.toString().toLowerCase()).toList();
    }

    update();
  }

  // deposit charge calculations

  void changeDepositChargeInfoWidgetValue(double amount) {
    if (selectedDepositPaymentMethod?.id.toString() == '-1') {
      return;
    }
    currency = selectedDepositPaymentMethod?.currency ?? '';
    mainAmount = amount;

    double percent = double.tryParse(selectedDepositPaymentMethod?.percentCharge ?? '0') ?? 0;

    double percentCharge = (amount * percent) / 100;

    double temCharge = double.tryParse(selectedDepositPaymentMethod?.fixedCharge ?? '0') ?? 0;

    double totalCharge = percentCharge + temCharge;

    charge = '${StringConverter.formatNumber('$totalCharge')} $currency';

    double payable = totalCharge + amount;

    payableText = '${StringConverter.formatNumber(payable.toString())} $currency';

    rate = double.tryParse(selectedDepositPaymentMethod?.rate ?? '0') ?? 0;

    conversionRate = '1 $currency = $rate ${selectedDepositPaymentMethod?.currency ?? ''}';

    inLocal = StringConverter.formatNumber('${payable * rate}');

    update();

    return;
  }

  void clearData() {
    depositLimit = '';

    charge = '';

    amountController.text = '';

    isDepositMethodLoading = false;

    depositMethodList.clear();
  }

  bool isShowRate() {
    if (rate > 1 && currency.toLowerCase() != selectedDepositPaymentMethod?.currency?.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  //Submit deposit

  bool submitLoading = false;
  Future<void> submitNewDeposit({String walletType = 'spot'}) async {
    if (selectedDepositPaymentMethod?.id.toString() == '-1') {
      CustomSnackBar.error(errorList: [MyStrings.selectPaymentGateway]);
      return;
    }

    String amount = amountController.text.toString();
    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
      return;
    }

    submitLoading = true;
    update();

    ResponseModel responseModel = await depositRepo.insertDeposit(amount: amount, methodCode: selectedDepositPaymentMethod?.methodCode ?? "", currency: selectedDepositPaymentMethod?.currency ?? "", walletType: walletType);

    if (responseModel.statusCode == 200) {
      DepositInsertResponseModel insertResponseModel = DepositInsertResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      if (insertResponseModel.status.toString().toLowerCase() == "success") {
        showWebView(insertResponseModel.data?.redirectUrl ?? "");
      } else {
        CustomSnackBar.error(errorList: insertResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(
        errorList: [responseModel.message],
      );
    }

    submitLoading = false;
    update();
  }

  void showWebView(String redirectUrl) {
    Get.offAndToNamed(RouteHelper.depositWebViewScreen, arguments: redirectUrl);
  }

  bool checkUserIsLoggedInOrNot() {
    return depositRepo.apiClient.sharedPreferences.getBool(SharedPreferenceHelper.rememberMeKey) ?? false;
  }
}
