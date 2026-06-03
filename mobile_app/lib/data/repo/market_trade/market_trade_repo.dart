import 'package:vinance/data/model/global/response_model/response_model.dart';

import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class MarketTradeRepo {
  ApiClient apiClient;
  MarketTradeRepo({required this.apiClient});

  Future<ResponseModel> getMarketCurrencyListData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.marketTradeCurrencyApi}';
    final response = await apiClient.request(url, Method.getMethod, null);
    return response;
  }

  Future<ResponseModel> getMarketPairDataBasedOnMarketID({String marketID = '', String search = '', required int page, String limit = '200'}) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.marketTradePairEndPoint}?search=$search&market_id=$marketID&pagination=$limit&page=$page&order_by=asc';
    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getMarketTradeDataBasedOnSymbolID({
    String marketSymbolID = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.marketTradeApi}/$marketSymbolID';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getMarketTradeOrderBookData({
    String marketSymbolID = '',
    String orderType = 'all',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.tradeOrderBookApi}/$marketSymbolID?order_type=$orderType';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getMarketTradeHistoryData({
    String marketSymbolID = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.marketTradeHistoryEndPoint}/$marketSymbolID';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getMarketTradeOrderOpenHistoryData({
    String marketSymbolID = '',
    int page = 0,
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.tradeOrderList}/$marketSymbolID?status=open&pagination=20&page=$page';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> orderCreateBuyOrSell({
    String symbolID = '',
    String rate = '',
    String amount = '',
    String orderSide = '',
    String orderType = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.saveOrder}/$symbolID';
    var params = {"rate": rate, "amount": amount, 'order_side': orderSide, 'order_type': orderType};
    final response = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return response;
  }

  Future<ResponseModel> updateOrderRate({
    String orderID = '',
    String updateFiledType = '',
    String updateValue = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.updateOrder}/$orderID';
    Map<String, String> params = {"update_filed": updateFiledType};

    params.putIfAbsent(updateFiledType, () => updateValue);
    final response = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return response;
  }

  Future<ResponseModel> cancelOrderRate({
    String orderID = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.cancelOrder}/$orderID';

    final response = await apiClient.request(url, Method.postMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> addTtoFav({
    String symbolID = '',
  }) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.addToFavCoinEndPoint}/$symbolID';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  //History
  /* Trade History */
  Future<ResponseModel> getTradeHistoryData(
    int page, {
    String tradeSide = "",
    String searchText = "",
  }) async {
    if (tradeSide == "all") {
      tradeSide = '';
    } else if (tradeSide == "buy") {
      tradeSide = '1';
    } else if (tradeSide == "sell") {
      tradeSide = '2';
    } else {
      tradeSide = '';
    }

    String url = '${UrlContainer.baseUrl}${UrlContainer.tradeAllHistoryApi}?trade_side=$tradeSide&search=$searchText';
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  /* Order History */
  Future<ResponseModel> getMyOrderHistory(
    int page, {
    String historyType = "",
    String orderSide = "",
    String orderType = "",
    String searchText = "",
  }) async {
    if (historyType == "all") {
      historyType = 'history';
    } else {
      historyType = historyType;
    }

    if (orderSide == "all") {
      orderSide = '';
    } else if (orderSide == "buy") {
      orderSide = '1';
    } else if (orderSide == "sell") {
      orderSide = '2';
    } else {
      orderSide = '';
    }
    if (orderType == "all") {
      orderType = '';
    } else if (orderType == "limit") {
      orderType = '1';
    } else if (orderType == "market") {
      orderType = '2';
    } else {
      orderType = '';
    }

    String url = '${UrlContainer.baseUrl}${UrlContainer.orderHistoryApi}/$historyType?order_type=$orderType&order_side=$orderSide&search=$searchText&page=$page';
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
