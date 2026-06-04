import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/market_data_model.dart';
import '../../data/repositories/trade_repository.dart';

class StockDetailController extends GetxController {
  final TradeRepository tradeRepository;

  StockDetailController({required this.tradeRepository});

  var isLoading = false.obs;
  var stockQuote = Rxn<MarketDataModel>();
  var selectedTimeframe = '1m'.obs;
  var chartData = <double>[].obs;
  
  // Market Depth
  var bids = <Map<String, dynamic>>[].obs;
  var asks = <Map<String, dynamic>>[].obs;
  var totalBidQty = 0.0.obs;
  var totalAskQty = 0.0.obs;

  // Real-time Option Chain
  var isLoadingOptionChain = false.obs;
  var optionChainData = Rxn<Map<String, dynamic>>();
  var selectedExpiry = ''.obs;
  var expiries = <String>[].obs;

  // Order placing properties
  var isBuy = true.obs;
  var isLimit = false.obs;
  var quantityController = TextEditingController(text: '1');
  var priceController = TextEditingController();
  
  var orderPlacing = false.obs;
  Timer? _detailTimer;

  void initialize(String symbol) {
    stockQuote.value = null; // Reset to show loader immediately
    optionChainData.value = null; // Reset option chain
    _detailTimer?.cancel();
    
    fetchQuote(symbol);
    fetchOptionChain(symbol);
    generateChartData();
    fetchMarketDepth(symbol);

    // Start periodic background updates
    _detailTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (stockQuote.value != null) {
        refreshQuoteSilent(symbol);
        refreshOptionChainSilent(symbol);
      }
    });
  }

  @override
  void onClose() {
    _detailTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchOptionChain(String symbol, {String? expiry}) async {
    try {
      isLoadingOptionChain.value = true;
      final data = await tradeRepository.getOptionChain(symbol, expiry: expiry);
      optionChainData.value = data;
      
      final List<dynamic> expList = data['expiries'] ?? [];
      expiries.value = expList.map((e) => e.toString()).toList();
      
      if (data['expiry'] != null) {
        selectedExpiry.value = data['expiry'].toString();
      }
    } catch (_) {
      // Quietly fail or mock fallback
    } finally {
      isLoadingOptionChain.value = false;
    }
  }

  Future<void> refreshOptionChainSilent(String symbol) async {
    try {
      final data = await tradeRepository.getOptionChain(
        symbol,
        expiry: selectedExpiry.value.isNotEmpty ? selectedExpiry.value : null,
      );
      optionChainData.value = data;
      final List<dynamic> expList = data['expiries'] ?? [];
      expiries.value = expList.map((e) => e.toString()).toList();
    } catch (_) {}
  }

  Future<void> fetchQuote(String symbol) async {
    try {
      isLoading.value = true;
      final quote = await tradeRepository.getStockQuote(symbol);
      stockQuote.value = quote;
      priceController.text = quote.price.toStringAsFixed(2);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshQuoteSilent(String symbol) async {
    try {
      final quote = await tradeRepository.getStockQuote(symbol);
      stockQuote.value = quote;
      
      // Update price text field only if user is not actively editing
      if (priceController.text.isEmpty || double.tryParse(priceController.text) == null) {
        priceController.text = quote.price.toStringAsFixed(2);
      }
      
      fetchMarketDepth(symbol);
    } catch (_) {}
  }

  Future<void> fetchMarketDepth(String symbol) async {
    try {
      // Simulate/Load bids and asks
      final Random random = Random();
      final double midPrice = stockQuote.value?.price ?? 100.0;
      
      bids.value = List.generate(5, (index) => {
        'rate': (midPrice - (index + 1) * 0.15).toStringAsFixed(2),
        'amount': (random.nextInt(800) + 50).toDouble(),
      });

      asks.value = List.generate(5, (index) => {
        'rate': (midPrice + (index + 1) * 0.15).toStringAsFixed(2),
        'amount': (random.nextInt(800) + 50).toDouble(),
      });

      totalBidQty.value = bids.fold(0.0, (sum, item) => sum + item['amount']);
      totalAskQty.value = asks.fold(0.0, (sum, item) => sum + item['amount']);
    } catch (_) {}
  }

  void generateChartData() {
    final Random random = Random();
    double price = stockQuote.value?.price ?? 150.0;
    final List<double> data = [];
    
    int points = 30;
    if (selectedTimeframe.value == '1d') points = 24;
    if (selectedTimeframe.value == '1y') points = 50;

    for (int i = 0; i < points; i++) {
      price += (random.nextDouble() - 0.48) * (price * 0.02);
      data.add(price);
    }
    chartData.value = data;
  }

  void changeTimeframe(String timeframe) {
    selectedTimeframe.value = timeframe;
    generateChartData();
  }

  double get quantity => double.tryParse(quantityController.text) ?? 1.0;
  double get price => double.tryParse(priceController.text) ?? (stockQuote.value?.price ?? 0.0);
  
  double get totalAmount => quantity * price;
  double get brokerage => totalAmount * 0.0005; // 0.05% brokerage fee mock
  double get finalAmount => totalAmount + brokerage;

  Future<void> executeOrder() async {
    if (stockQuote.value == null) return;
    
    try {
      orderPlacing.value = true;
      final success = await tradeRepository.placeOrder(
        symbol: stockQuote.value!.symbol,
        price: price,
        quantity: quantity,
        isBuy: isBuy.value,
        isLimit: isLimit.value,
      );

      if (success) {
        Get.back(); // close bottom sheet
        Get.snackbar(
          'Order Placed',
          'Successfully submitted your order for ${quantity.toInt()} shares of ${stockQuote.value!.symbol}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Unable to execute simulated order.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      orderPlacing.value = false;
    }
  }
}
