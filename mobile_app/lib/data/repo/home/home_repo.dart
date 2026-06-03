import 'dart:convert';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/model/general_setting/general_setting_response_model.dart';
import 'package:vinance/data/model/global/response_model/response_model.dart';
import 'package:vinance/data/services/api_service.dart';

import '../../../environment.dart';

class HomeRepo {
  ApiClient apiClient;
  HomeRepo({required this.apiClient});

  Future<ResponseModel> getDashboardData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.dashBoardEndPoint}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true,);
    return responseModel;
  }

  Future<dynamic> refreshGeneralSetting() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.generalSettingEndPoint}';
    ResponseModel response = await apiClient.request(url, Method.getMethod, null, passHeader: false, headers: {
      "custom-string": Environment.appAuthKey,
    });

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        apiClient.storeGeneralSetting(model);
      }
    }
  }

  //Market overview data
  Future<ResponseModel> getMarketOverViewData() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.marketMarketOverviewApi}";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  //Market pair data list
  Future<ResponseModel> getMarketDataListApi({String type = 'all', String limit = "20", required String page}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.marketDataListApi}?type=$type&pagination=$limit&page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

  //Latest Blog news
  Future<ResponseModel> latestBlogNewsListApi({String limit = "10",}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.blogsEndPoint}?pagination=$limit";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }
}
