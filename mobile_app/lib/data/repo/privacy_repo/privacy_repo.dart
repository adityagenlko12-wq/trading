import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/services/api_service.dart';

class PrivacyRepo{

  ApiClient apiClient;
  PrivacyRepo({required this.apiClient});

  Future<dynamic>loadAboutData()async{

    String url='${UrlContainer.baseUrl}${UrlContainer.privacyPolicyEndPoint}';

    final response=await apiClient.request(url, Method.getMethod,null);
    return response;
  }

}