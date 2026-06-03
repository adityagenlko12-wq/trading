// Import necessary dependencies or models
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class ReferralRepository {
  ApiClient apiClient;
  ReferralRepository({required this.apiClient});

  Future<dynamic> fetchAllRepository() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.referralsEndPoint}';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }
}
