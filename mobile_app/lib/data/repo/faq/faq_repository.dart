// Import necessary dependencies or models
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class FaqRepository {
  ApiClient apiClient;
  FaqRepository({required this.apiClient});

  Future<dynamic> fetchAllFaq(String page) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.faqEndPoint}?page=$page';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }
}
