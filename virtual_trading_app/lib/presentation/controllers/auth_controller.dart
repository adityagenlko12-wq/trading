import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/routes/routes.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  var isLoading = false.obs;
  var user = Rxn<UserModel>();

  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null && token.isNotEmpty) {
      try {
        isLoading.value = true;
        final userInfo = await authRepository.getUserInfo();
        user.value = userInfo;
        Get.offAllNamed(RouteHelper.dashboard);
      } catch (_) {
        await logoutSilent();
        Get.offAllNamed(RouteHelper.login);
      } finally {
        isLoading.value = false;
      }
    } else {
      // Delay slightly to show splash
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(RouteHelper.login);
      });
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final loggedInUser = await authRepository.login(email, password);
      user.value = loggedInUser;
      Get.offAllNamed(RouteHelper.dashboard);
      Get.snackbar('Success', 'Welcome back, ${loggedInUser.name}!', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String mobile,
    required String password,
    String? referralCode,
  }) async {
    try {
      isLoading.value = true;
      final success = await authRepository.signup(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
        referralCode: referralCode,
      );
      if (success) {
        Get.offAllNamed(RouteHelper.login);
        Get.snackbar('Success', 'Account created successfully! Please login.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Registration failed. Try again.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutSilent() async {
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authRepository.logout();
    } catch (_) {}
    await logoutSilent();
    Get.offAllNamed(RouteHelper.login);
  }
}
