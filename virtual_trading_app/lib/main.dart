import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/network/api_client.dart';
import 'core/routes/routes.dart';
import 'core/theme/theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/trade_repository.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/dashboard_controller.dart';
import 'presentation/controllers/portfolio_controller.dart';
import 'presentation/controllers/stock_detail_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection bindings globally
  final apiClient = ApiClient();
  
  final authRepository = AuthRepository(apiClient: apiClient);
  final tradeRepository = TradeRepository(apiClient: apiClient);
  
  Get.put(authRepository, permanent: true);
  Get.put(tradeRepository, permanent: true);

  Get.put(AuthController(authRepository: authRepository), permanent: true);
  Get.put(DashboardController(tradeRepository: tradeRepository), permanent: true);
  Get.put(PortfolioController(tradeRepository: tradeRepository), permanent: true);
  Get.put(StockDetailController(tradeRepository: tradeRepository), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vinance Virtual Trading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: RouteHelper.splash,
      getPages: RouteHelper.routes,
    );
  }
}
