// Import necessary dependencies or models
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class WalletRepository {
  ApiClient apiClient;
  WalletRepository({required this.apiClient});

  Future<ResponseModel> getAllWalletTypeBasedOnWalletType(int page, {String type = "spot"}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.walletListEndPoint}/$type?page=$page&pagination=20";

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: true);
    return responseModel;
  }

  Future<ResponseModel> getSingleWalletDetails(int page, {String type = "spot", String symbolCurrency = ""}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.walletEndPoint}/$type/$symbolCurrency?page=$page&pagination=20";

    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: true);
    return responseModel;
  }

  Future<ResponseModel> getWalletTransactionList(int page, {String type = "", String remark = "", String searchText = "", String symbol = ''}) async {
    if (type.toLowerCase() == "all" || (type.toLowerCase() != 'plus' && type.toLowerCase() != 'minus')) {
      type = '';
    }

    if (remark.isEmpty || remark.toLowerCase() == "all") {
      remark = '';
    }
    if (symbol.isEmpty || symbol.toLowerCase() == "all") {
      symbol = '';
    }

    String url = '${UrlContainer.baseUrl}${UrlContainer.transactionEndpoint}?page=$page&type=$type&remark=$remark&symbol=$symbol&search=$searchText';
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: true);
    return responseModel;
  }

  Future<ResponseModel> getAllCryptoList() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.currencyListEndPoint}';
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
