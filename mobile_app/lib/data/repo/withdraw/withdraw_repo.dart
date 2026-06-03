import 'dart:convert';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/method.dart' as request;
import 'package:http/http.dart' as http;
import 'package:vinance/data/model/kyc/kyc_form_model.dart';

import '../../../data/repo/kyc/kyc_repo.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/url_container.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/withdraw/withdraw_confirmation_response_model.dart';
import '../../services/api_service.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/withdraw/withdraw_history_response_model.dart';

class WithdrawRepo {
  ApiClient apiClient;
  WithdrawRepo({required this.apiClient});

  Future<dynamic> getAllWithdrawMethod() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.withdrawMethodUrl}';

    ResponseModel responseModel = await apiClient.request(url, request.Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<dynamic> getWithdrawConfirmScreenData(String trxId) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.withdrawConfirmScreenUrl}$trxId';

    ResponseModel responseModel = await apiClient.request(url, request.Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  Future<dynamic> addWithdrawRequest({
    required String methodCode,
    required String amount,
    String? authMode,
    required String currency,
    required String walletType,
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.addWithdrawRequestUrl}';
    Map<String, dynamic> params = {'method_code': methodCode.toString(), 'amount': amount.toString(), "currency": currency, "wallet_type": walletType};

    if (authMode != null && authMode.isNotEmpty && authMode.toLowerCase() != MyStrings.selectOne.toLowerCase()) {
      params['auth_mode'] = authMode.toLowerCase();
    }

    ResponseModel responseModel = await apiClient.request(url, request.Method.postMethod, params, passHeader: true);
    return responseModel;
  }

  List<Map<String, String>> fieldList = [];
  List<ModelDynamicValue> filesList = [];

  Future<WithdrawConfirmationResponseModel> confirmWithdrawRequest(String trx, List<KycFormModel> list, String twoFactorCode) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.withdrawRequestConfirm}';

    apiClient.initToken();
    await modelToMap(list);

    var request = http.MultipartRequest('POST', Uri.parse(url));
    Map<String, String> finalMap = {};

    finalMap['trx'] = trx;

    for (var element in fieldList) {
      finalMap.addAll(element);
    }

    request.headers.addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});

    for (var file in filesList) {
      request.files.add(http.MultipartFile(file.key ?? '', file.value.readAsBytes().asStream(), file.value.lengthSync(), filename: file.value.path.split('/').last));
    }

    if (twoFactorCode.isNotEmpty || twoFactorCode != '') {
      request.fields.addAll({'authenticator_code': twoFactorCode});
    }

    request.fields.addAll(finalMap);

    printx(finalMap);
    http.StreamedResponse response = await request.send();
    String jsonResponse = await response.stream.bytesToString();

    final withdrawConfirmationResponseModel = withdrawConfirmationResponseModelFromJson(jsonResponse);

    return withdrawConfirmationResponseModel;
  }

  Future<dynamic> getAllWithdrawHistory(int page, {String searchText = ""}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.withdrawHistoryUrl}?page=$page&search=$searchText";

    ResponseModel responseModel = await apiClient.request(url, request.Method.getMethod, null, passHeader: true);

    if (responseModel.statusCode == 200) {
      WithdrawHistoryResponseModel model = WithdrawHistoryResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      if (model.status == 'success') {
        return model;
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        return WithdrawHistoryResponseModel();
      }
    } else {
      return WithdrawHistoryResponseModel();
    }
  }

  Future<dynamic> modelToMap(List<KycFormModel> list) async {
    for (var e in list) {
      if (e.type == 'checkbox') {
        if (e.cbSelected != null && e.cbSelected!.isNotEmpty) {
          for (int i = 0; i < e.cbSelected!.length; i++) {
            fieldList.add({'${e.label}[$i]': e.cbSelected![i]});
          }
        }
      } else if (e.type == 'file') {
        if (e.imageFile != null) {
          filesList.add(ModelDynamicValue(e.label, e.imageFile!));
        }
      } else {
        if (e.selectedValue != null && e.selectedValue.toString().isNotEmpty) {
          fieldList.add({e.label ?? '': e.selectedValue ?? ''});
        }
      }
    }
  }
}
