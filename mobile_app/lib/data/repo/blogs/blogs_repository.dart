// Import necessary dependencies or models
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class BlogsRepository {
  ApiClient apiClient;
  BlogsRepository({required this.apiClient});

  Future<dynamic> fetchAllBlogs(String page) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.blogsEndPoint}?page=$page';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true, needAuthCheck: true);
    return response;
  }
}
