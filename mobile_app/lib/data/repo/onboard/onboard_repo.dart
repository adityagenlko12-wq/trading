import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class OnboardRepo {
  ApiClient apiClient;
  OnboardRepo({required this.apiClient});

  Future<dynamic> loadOnboardData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.onBoardsApiEndPoint}';
    final response = await apiClient.request(url, Method.getMethod, null);
    return response;
  }
}
