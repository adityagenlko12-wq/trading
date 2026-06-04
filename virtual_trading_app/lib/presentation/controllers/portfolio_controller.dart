import 'package:get/get.dart';
import '../../data/models/holdings_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/trade_repository.dart';

class PortfolioController extends GetxController {
  final TradeRepository tradeRepository;

  PortfolioController({required this.tradeRepository});

  var isLoading = false.obs;
  var holdings = <HoldingsModel>[].obs;
  var positions = <OrderModel>[].obs; // active orders
  var trades = <OrderModel>[].obs;    // completed order logs

  // Stats
  var totalInvested = 0.0.obs;
  var currentValue = 0.0.obs;
  var totalPL = 0.0.obs;
  var totalROI = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPortfolioDetails();
  }

  Future<void> loadPortfolioDetails() async {
    try {
      isLoading.value = true;
      final portfolio = await tradeRepository.getPortfolio();
      
      final stats = portfolio['stats'] ?? {};
      totalInvested.value = double.tryParse((stats['invested_amount'] ?? stats['total_invested'])?.toString() ?? '') ?? 0.0;
      totalPL.value = double.tryParse((stats['total_pnl'] ?? stats['total_pl'])?.toString() ?? '') ?? 0.0;
      currentValue.value = totalInvested.value + totalPL.value;
      totalROI.value = totalInvested.value > 0 ? (totalPL.value / totalInvested.value) * 100 : 0.0;

      holdings.value = portfolio['holdings'] ?? [];
      positions.value = portfolio['positions'] ?? [];
      trades.value = portfolio['trades'] ?? [];
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelPositionOrder(int orderId) async {
    try {
      final success = await tradeRepository.cancelOrder(orderId);
      if (success) {
        Get.snackbar('Success', 'Order cancelled successfully.', snackPosition: SnackPosition.BOTTOM);
        loadPortfolioDetails(); // reload
      } else {
        Get.snackbar('Error', 'Unable to cancel order.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
