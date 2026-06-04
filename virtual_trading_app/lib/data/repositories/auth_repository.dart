import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/api/login',
        data: {
          'username': email,
          'password': password,
        },
      );

      final responseData = response.data;
      if (responseData['status'] == 'success') {
        final token = responseData['data']['access_token']?.toString() ?? '';
        final userJson = responseData['data']['user'];
        
        // Cache token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        
        return UserModel.fromJson(userJson);
      } else {
        throw responseData['message']?['error']?.first ?? 'Login failed.';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? referralCode,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/register',
        data: {
          'firstname': name,
          'email': email,
          'mobile': mobile,
          'password': password,
          'referral_code': referralCode ?? '',
          'agree': 'on', // Compatibility with backend registration requirements
        },
      );

      final responseData = response.data;
      return responseData['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserInfo() async {
    try {
      final response = await apiClient.get('/api/user-info');
      final responseData = response.data;
      if (responseData['status'] == 'success') {
        return UserModel.fromJson(responseData['data']['user']);
      } else {
        throw 'Failed to fetch user details.';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/api/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
