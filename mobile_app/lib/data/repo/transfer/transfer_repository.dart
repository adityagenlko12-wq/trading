// Import necessary dependencies or models
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class TransferRepository {
  ApiClient apiClient;
  TransferRepository({required this.apiClient});

  Future<ResponseModel> transferBalanceUserToUser({String amount = '-1', String username = '-1', String currency = '-1', String walletType = 'spot'}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.walletTransferToUserEndPoint}";

    Map<String, dynamic> bodyData = {
      "transfer_amount": amount.toString(),
      "username": username.toString(),
      "currency": currency.toString(),
      "wallet_type": walletType.toString(),
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, bodyData, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> transferBalanceWalletToWallet({String amount = '-1', String currency = '-1', String fromWallet = '', String toWallet = ''}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.walletTransferToWalletEndPoint}";

    Map<String, dynamic> bodyData = {
      "transfer_amount": amount.toString(),
      "currency": currency.toString(),
      "from_wallet": fromWallet.toString(),
      "to_wallet": toWallet.toString(),
    };

    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, bodyData, passHeader: true);
    return responseModel;
  }
}
