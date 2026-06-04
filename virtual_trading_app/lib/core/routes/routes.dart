import 'package:get/get.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/details/stock_detail_screen.dart';
import '../../presentation/screens/splash_screen.dart';

class RouteHelper {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String stockDetail = '/stock_detail';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: stockDetail,
      page: () => const StockDetailScreen(),
    ),
  ];
}
