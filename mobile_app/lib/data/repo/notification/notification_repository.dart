
import '../../../core/utils/method.dart';
import '../../../core/utils/url_container.dart';
import '../../services/api_service.dart';

class NotificationRepository {
  ApiClient apiClient;
  NotificationRepository({required this.apiClient});

  Future<dynamic> fetchAllNotification(String page) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.notificationListApi}?page=$page';

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true,needAuthCheck: true );
    return response;
  }
}
