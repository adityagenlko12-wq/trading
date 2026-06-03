
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class BiometricRepo {
  ApiClient apiClient;
  BiometricRepo({required this.apiClient});

  Future<ResponseModel> pinValidate({
    required String password,
  }) async {
    Map<String, String> map = {'password': password};

    String url = '${UrlContainer.baseUrl}${UrlContainer.pinValidate}';
    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return model;
  }
}
