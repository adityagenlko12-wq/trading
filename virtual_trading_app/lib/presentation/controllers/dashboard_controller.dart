import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/market_data_model.dart';
import '../../data/repositories/trade_repository.dart';

class DashboardController extends GetxController {
  final TradeRepository tradeRepository;

  DashboardController({required this.tradeRepository});

  var isLoading = false.obs;
  var indices = <MarketDataModel>[].obs;
  
  // Portfolio card stats
  var balance = 0.0.obs;
  var totalInvestment = 0.0.obs;
  var totalProfitLoss = 0.0.obs;
  var todayProfitLoss = 0.0.obs;

  // Watchlists
  var watchlistStocks = <MarketDataModel>[].obs;
  var trendingStocks = <MarketDataModel>[].obs;
  var topGainers = <MarketDataModel>[].obs;
  var topLosers = <MarketDataModel>[].obs;

  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    // Refresh indices and watchlists every 5 seconds to simulate real-time updates
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) => refreshPricesSilent());
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        fetchIndices(),
        fetchPortfolioStats(),
        fetchWatchlists(),
      ]);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPricesSilent() async {
    try {
      await Future.wait([
        fetchIndices(),
        fetchPortfolioStats(),
      ]);
    } catch (_) {}
  }

  Future<void> fetchIndices() async {
    try {
      final data = await tradeRepository.getIndices();
      indices.value = data;
    } catch (_) {}
  }

  Future<void> fetchPortfolioStats() async {
    try {
      final portfolio = await tradeRepository.getPortfolio();
      final stats = portfolio['stats'] ?? {};
      balance.value = double.tryParse((stats['available_balance'] ?? stats['balance'])?.toString() ?? '') ?? 0.0;
      totalInvestment.value = double.tryParse((stats['invested_amount'] ?? stats['total_invested'])?.toString() ?? '') ?? 0.0;
      totalProfitLoss.value = double.tryParse((stats['total_pnl'] ?? stats['total_pl'])?.toString() ?? '') ?? 0.0;
      todayProfitLoss.value = double.tryParse((stats['todays_pnl'] ?? stats['today_pl'])?.toString() ?? '') ?? 0.0;
    } catch (_) {}
  }

  Future<void> fetchWatchlists() async {
    // Populate trending stocks with realistic sample data for paper trading
    trendingStocks.value = [
      MarketDataModel(symbol: 'HINDZINC', companyName: 'Hindustan Zinc', price: 612.90, change: -12.20, changePercent: -1.95),
      MarketDataModel(symbol: 'IDEA', companyName: 'Vodafone Idea', price: 14.91, change: 0.75, changePercent: 5.30),
      MarketDataModel(symbol: 'TATACONSUM', companyName: 'Tata Consumer Products', price: 1149.70, change: -5.00, changePercent: -0.43),
      MarketDataModel(symbol: 'ASTERDM', companyName: 'Aster DM Healthcare', price: 731.35, change: 4.40, changePercent: 0.61),
      MarketDataModel(symbol: 'AXISBANK', companyName: 'Axis Bank', price: 1259.40, change: 8.30, changePercent: 0.66),
    ];
    topGainers.value = [
      MarketDataModel(symbol: 'TATASTEEL', companyName: 'Tata Steel Ltd', price: 124.80, change: 6.20, changePercent: 5.23),
      MarketDataModel(symbol: 'HDFCBANK', companyName: 'HDFC Bank Ltd', price: 1530.40, change: 35.15, changePercent: 2.35),
    ];
    topLosers.value = [
      MarketDataModel(symbol: 'WIPRO', companyName: 'Wipro Ltd', price: 385.20, change: -12.40, changePercent: -3.12),
      MarketDataModel(symbol: 'SBIN', companyName: 'State Bank of India', price: 575.40, change: -14.20, changePercent: -2.41),
    ];
    // Default watchlist includes Nifty top symbols
    watchlistStocks.value = List.from(trendingStocks);
  }
}
