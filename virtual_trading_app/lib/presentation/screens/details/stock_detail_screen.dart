import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/stock_detail_controller.dart';
import '../../widgets/stock_chart.dart';
import '../../widgets/market_depth.dart';
import '../../widgets/order_sheet.dart';
import '../../../core/constants/colors.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen({super.key});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late String _symbol;

  @override
  void initState() {
    super.initState();
    // Symbol is passed either in arguments or default to RELIANCE
    final args = Get.arguments;
    if (args is Map) {
      _symbol = args['symbol']?.toString() ?? 'RELIANCE';
    } else {
      _symbol = args as String? ?? 'RELIANCE';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<StockDetailController>().initialize(_symbol);
    });
  }

  void _openOrderSheet(bool isBuy) {
    final controller = Get.find<StockDetailController>();
    controller.isBuy.value = isBuy;
    
    // Set default order pricing
    if (controller.stockQuote.value != null) {
      controller.priceController.text = controller.stockQuote.value!.price.toStringAsFixed(2);
    }

    Get.bottomSheet(
      OrderPlacementSheet(symbol: _symbol),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  bool _isIndex(String symbol) {
    final upper = symbol.toUpperCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
    if (upper == 'SENSEX' ||
        upper == 'BSESENSEX' ||
        upper == 'NIFTY' ||
        upper == 'NIFTY50' ||
        upper == 'BANKNIFTY' ||
        upper == 'NIFTYBANK' ||
        upper == 'FINNIFTY' ||
        upper == 'NIFTYFINSERVICE' ||
        upper == 'BSEBANKEX' ||
        upper == 'BANKEX' ||
        upper == 'MIDCPNIFTY' ||
        upper == 'NIFTYMIDSELECT' ||
        upper == 'BTC' ||
        upper == 'ETH' ||
        upper == 'BTCUSDT' ||
        upper == 'ETHUSDT') {
      return true;
    }
    // Commodities segment support
    if (upper.contains('CRUDEOIL') ||
        upper.contains('GOLD') ||
        upper.contains('SILVER') ||
        upper.contains('NATURALGAS') ||
        upper.contains('NATGAS') ||
        upper.contains('ZINC') ||
        upper.contains('ALUMINIUM') ||
        upper.contains('ALUMINI')) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isIndex(_symbol)) {
      return _IndexDetailView(symbol: _symbol);
    }
    final controller = Get.find<StockDetailController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final q = controller.stockQuote.value;
          return Text(
            q != null ? '${q.symbol} Ticker' : 'Stock details',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stockQuote.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final quote = controller.stockQuote.value;
        if (quote == null) {
          return Center(
            child: Text(
              'No quote data available for $_symbol',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          );
        }

        final isPositive = quote.change >= 0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Header Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote.symbol,
                              style: TextStyle(
                                fontSize: 27, // Increased by 1.15x
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${quote.exchange} • Equity',
                              style: TextStyle(
                                fontSize: 15, // Increased
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${quote.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 30, // Increased by 1.15x
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${isPositive ? '+' : ''}${quote.change.toStringAsFixed(2)} (${quote.changePercent.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 16.5, // Increased by 1.15x
                                fontWeight: FontWeight.bold,
                                color: isPositive ? AppColors.green : AppColors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stock chart container
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: StockChart(
                        prices: controller.chartData,
                        isPositive: isPositive,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Custom styled Timeframe buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['1m', '1d', '1y'].map((tf) {
                        return Obx(() {
                          final isSelected = controller.selectedTimeframe.value == tf;
                          return GestureDetector(
                            onTap: () => controller.changeTimeframe(tf),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.green : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.green
                                      : (isDark ? Colors.grey[800]! : Colors.black87),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    tf.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13, // Slightly increased
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? Colors.grey[300] : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Key stats details
                    Text(
                      'Performance Details',
                      style: TextStyle(
                        fontSize: 18.5, // Increased by 1.15x
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem('Open', '₹${quote.open.toStringAsFixed(2)}', isDark),
                              _buildStatItem('Prev. Close', '₹${quote.prevClose.toStringAsFixed(2)}', isDark),
                            ],
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem('Today\'s High', '₹${quote.high.toStringAsFixed(2)}', isDark),
                              _buildStatItem('Today\'s Low', '₹${quote.low.toStringAsFixed(2)}', isDark),
                            ],
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem('52W High', '₹${quote.yearHigh.toStringAsFixed(2)}', isDark),
                              _buildStatItem('52W Low', '₹${quote.yearLow.toStringAsFixed(2)}', isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Side-by-side Market Depth widget
                    MarketDepthView(
                      bids: controller.bids,
                      asks: controller.asks,
                      totalBidQty: controller.totalBidQty.value,
                      totalAskQty: controller.totalAskQty.value,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Buy & Sell Button Bars
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                        ),
                        onPressed: () => _openOrderSheet(false),
                        child: const Text(
                          'SELL',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                        ),
                        onPressed: () => _openOrderSheet(true),
                        child: const Text(
                          'BUY',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13, // Increased by 1.15x
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16, // Increased by 1.15x
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DHAN STYLE STATEFUL INDEX DETAIL VIEW
// ==========================================
class _IndexDetailView extends StatefulWidget {
  final String symbol;
  const _IndexDetailView({required this.symbol});

  @override
  State<_IndexDetailView> createState() => _IndexDetailViewState();
}

class _IndexDetailViewState extends State<_IndexDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _stockDetailController = Get.find<StockDetailController>();
  String _selectedExpiry = '04 Jun';
  String _activeFilter = 'All';

  final List<String> _expiries = ['04 Jun', '11 Jun', '18 Jun', '25 Jun', '02 Jul'];

  // For Flash tab options
  String _flashStrikeOption = 'ATM'; // ATM, Near OTM, Far OTM, Near ITM
  String _flashOptionType = 'CE'; // CE, PE

  @override
  void initState() {
    super.initState();
    int initialIdx = 0;
    final args = Get.arguments;
    if (args is Map && args['initialTab'] != null) {
      initialIdx = int.tryParse(args['initialTab'].toString()) ?? 0;
    } else if (args is String && (args.contains('CE') || args.contains('PE') || args.contains('CALL') || args.contains('PUT'))) {
      initialIdx = 3; // Pre-select Option Chain
    } else if (args is Map && args['symbol'] != null && (args['symbol'].toString().contains('CE') || args['symbol'].toString().contains('PE'))) {
      initialIdx = 3;
    }
    
    _tabController = TabController(length: 5, vsync: this, initialIndex: initialIdx);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sym = args is Map ? (args['symbol'] ?? widget.symbol) : widget.symbol;
      _stockDetailController.initialize(sym);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get parameters based on index
  Map<String, dynamic> _getIndexSpecs() {
    final sym = widget.symbol.toUpperCase().replaceAll(' ', '').replaceAll('_', '').replaceAll('-', '');
    if (sym == 'BTC' || sym == 'BTCUSDT') {
      return {
        'name': 'Bitcoin Perpetual',
        'exchange': 'DELTA',
        'lotSize': 0.001,
        'strikeInterval': 100,
        'defaultSpot': 65000.0,
      };
    } else if (sym == 'ETH' || sym == 'ETHUSDT') {
      return {
        'name': 'Ethereum Perpetual',
        'exchange': 'DELTA',
        'lotSize': 0.01,
        'strikeInterval': 10,
        'defaultSpot': 3500.0,
      };
    } else if (sym == 'SENSEX' || sym == 'BSESENSEX') {
      return {
        'name': 'Sensex',
        'exchange': 'BSE',
        'lotSize': 10,
        'strikeInterval': 100,
        'defaultSpot': 74360.01,
      };
    } else if (sym == 'BANKNIFTY' || sym == 'NIFTYBANK') {
      return {
        'name': 'Nifty Bank',
        'exchange': 'NSE',
        'lotSize': 30,
        'strikeInterval': 100,
        'defaultSpot': 52800.00,
      };
    } else if (sym == 'BSEBANKEX' || sym == 'BANKEX') {
      return {
        'name': 'BSE BANKEX',
        'exchange': 'BSE',
        'lotSize': 15,
        'strikeInterval': 100,
        'defaultSpot': 53215.40,
      };
    } else if (sym == 'FINNIFTY' || sym == 'NIFTYFINSERVICE') {
      return {
        'name': 'Finnifty',
        'exchange': 'NSE',
        'lotSize': 40,
        'strikeInterval': 50,
        'defaultSpot': 21380.20,
      };
    } else if (sym == 'MIDCPNIFTY' || sym == 'NIFTYMIDSELECT') {
      return {
        'name': 'MIDCP NIFTY',
        'exchange': 'NSE',
        'lotSize': 75,
        'strikeInterval': 50,
        'defaultSpot': 12150.80,
      };
    } else {
      // Check if it matches any commodity symbol prefix
      final String symUpper = widget.symbol.toUpperCase();
      if (symUpper.contains('GOLDM')) {
        return {
          'name': 'Gold Mini',
          'exchange': 'MCX',
          'lotSize': 10,
          'strikeInterval': 100,
          'defaultSpot': 72610.0,
        };
      } else if (symUpper.contains('GOLD')) {
        return {
          'name': 'Gold',
          'exchange': 'MCX',
          'lotSize': 100,
          'strikeInterval': 100,
          'defaultSpot': 72540.0,
        };
      } else if (symUpper.contains('SILVERM')) {
        return {
          'name': 'Silver Mini',
          'exchange': 'MCX',
          'lotSize': 5,
          'strikeInterval': 250,
          'defaultSpot': 89520.0,
        };
      } else if (symUpper.contains('SILVER')) {
        return {
          'name': 'Silver',
          'exchange': 'MCX',
          'lotSize': 30,
          'strikeInterval': 250,
          'defaultSpot': 89450.0,
        };
      } else if (symUpper.contains('CRUDEOILM')) {
        return {
          'name': 'Crude Oil Mini',
          'exchange': 'MCX',
          'lotSize': 10,
          'strikeInterval': 50,
          'defaultSpot': 6240.0,
        };
      } else if (symUpper.contains('CRUDEOIL')) {
        return {
          'name': 'Crude Oil',
          'exchange': 'MCX',
          'lotSize': 100,
          'strikeInterval': 50,
          'defaultSpot': 6240.0,
        };
      } else if (symUpper.contains('NATGASMINI') || symUpper.contains('NATURALGASM')) {
        return {
          'name': 'Natural Gas Mini',
          'exchange': 'MCX',
          'lotSize': 250,
          'strikeInterval': 5,
          'defaultSpot': 212.50,
        };
      } else if (symUpper.contains('NATURALGAS') || symUpper.contains('NATGAS')) {
        return {
          'name': 'Natural Gas',
          'exchange': 'MCX',
          'lotSize': 1250,
          'strikeInterval': 5,
          'defaultSpot': 212.50,
        };
      } else if (symUpper.contains('ZINCMINI')) {
        return {
          'name': 'Zinc Mini',
          'exchange': 'MCX',
          'lotSize': 1000,
          'strikeInterval': 2,
          'defaultSpot': 245.80,
        };
      } else if (symUpper.contains('ZINC')) {
        return {
          'name': 'Zinc',
          'exchange': 'MCX',
          'lotSize': 5000,
          'strikeInterval': 2,
          'defaultSpot': 245.80,
        };
      } else if (symUpper.contains('ALUMINI') && !symUpper.contains('ALUMINIUM')) {
        return {
          'name': 'Aluminium Mini',
          'exchange': 'MCX',
          'lotSize': 1000,
          'strikeInterval': 2,
          'defaultSpot': 228.30,
        };
      } else if (symUpper.contains('ALUMINIUM')) {
        return {
          'name': 'Aluminium',
          'exchange': 'MCX',
          'lotSize': 5000,
          'strikeInterval': 2,
          'defaultSpot': 228.30,
        };
      }
      
      // Default fallback
      final provider = Get.find<DashboardController>().rxProvider.value;
      if (provider == 'delta') {
        return {
          'name': 'Bitcoin Perpetual',
          'exchange': 'DELTA',
          'lotSize': 0.001,
          'strikeInterval': 100,
          'defaultSpot': 65000.0,
        };
      }
      return {
        'name': 'Nifty 50',
        'exchange': 'NSE',
        'lotSize': 75,
        'strikeInterval': 50,
        'defaultSpot': 23416.10,
      };
    }
  }

  // Helper to format numbers in lakhs/crores format (e.g. 1,20,460)
  String _formatIndianNumber(dynamic number) {
    if (number == null) return '';
    final String str = number.toInt().toString();
    if (str.length <= 3) return str;
    final String lastThree = str.substring(str.length - 3);
    final String other = str.substring(0, str.length - 3);
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < other.length; i++) {
      if (i > 0 && (other.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(other[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);
    return buffer.toString();
  }

  // Generates option strike details mathematically around the spot price
  List<Map<String, dynamic>> _generateOptionChain(double spotPrice, int interval) {
    final double atmStrike = (spotPrice / interval).roundToDouble() * interval;
    final List<Map<String, dynamic>> chain = [];

    for (int i = -6; i <= 6; i++) {
      final double strike = atmStrike + (i * interval);
      
      // Calculate realistic premium values based on strike vs spot relationship
      final double callDist = spotPrice - strike;
      double callLtp = callDist > 0 ? (callDist * 0.95 + 18.5) : (18.5 / ((strike - spotPrice) / interval + 1.2));
      if (callLtp < 0.05) callLtp = 0.05;

      final double putDist = strike - spotPrice;
      double putLtp = putDist > 0 ? (putDist * 0.95 + 18.5) : (18.5 / ((spotPrice - strike) / interval + 1.2));
      if (putLtp < 0.05) putLtp = 0.05;

      // Seed consistent mock values for changes
      final double callLtpChg = -100.0 * (1.2 + sin(strike / 200).abs() * 2.5);
      final double putLtpChg = -80.0 * (1.0 + cos(strike / 200).abs() * 2.2);

      final String callOi = '${(3.0 + sin(strike / 100).abs() * 6).toStringAsFixed(2)} L';
      final String putOi = '${(2.0 + cos(strike / 100).abs() * 8).toStringAsFixed(2)} L';
      
      final int callOiChg = (50000 + (sin(strike / 300) * 150000).abs()).toInt();
      final int putOiChg = (40000 + (cos(strike / 300) * 120000).abs()).toInt();

      final double pcr = 0.1 + (cos(strike / 500).abs() * 5.5);

      chain.add({
        'strike': strike.toInt(),
        'callLtp': callLtp,
        'callLtpChg': callLtpChg,
        'callOi': callOi,
        'callOiChg': callOiChg,
        'putLtp': putLtp,
        'putLtpChg': putLtpChg,
        'putOi': putOi,
        'putOiChg': putOiChg,
        'pcr': pcr,
      });
    }
    return chain;
  }

  void _triggerOptionTrade(String contractSymbol, int lotSize) {
    _stockDetailController.quantityController.text = lotSize.toString();
    _stockDetailController.initialize(contractSymbol);
    
    Get.bottomSheet(
      OrderPlacementSheet(symbol: contractSymbol),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((_) {
      _stockDetailController.initialize(widget.symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final specs = _getIndexSpecs();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      bottomNavigationBar: _buildBottomBar(isDark),
      body: Obx(() {
        final quote = _stockDetailController.stockQuote.value;
        if (quote == null && _stockDetailController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final double currentPrice = quote?.price ?? specs['defaultSpot'];
        final double change = quote?.change ?? 13.84;
        final double changePercent = quote?.changePercent ?? 0.02;
        final bool isPositive = change >= 0;

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Header
              _buildCustomHeader(isDark, currentPrice, change, changePercent, isPositive, specs),

              // Custom Pills Tab Bar Switcher
              _buildPillsTabBar(isDark),

              // Tabs Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMarketTab(isDark, currentPrice, isPositive, specs),
                    _buildAnalysisTab(isDark, currentPrice),
                    _buildFlashTab(isDark, currentPrice, specs),
                    _buildOptionChainTab(isDark, currentPrice, specs),
                    _buildFuturesTab(isDark, currentPrice, specs),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Custom App Bar Header
  Widget _buildCustomHeader(bool isDark, double currentPrice, double change, double changePercent, bool isPositive, Map<String, dynamic> specs) {
    final priceStr = currentPrice.toStringAsFixed(2);
    final parts = priceStr.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final arrow = isPositive ? '↗' : '↘';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                specs['name'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: intPart,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: '.$decPart',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${changePercent.toStringAsFixed(2)}%) $arrow',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.green : AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'POSTCLOSE from ${specs['exchange']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  specs['exchange'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Pills Tab Bar
  Widget _buildPillsTabBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: List.generate(5, (index) {
            final labels = ['Market', 'Analysis', 'Flash', 'Option Chain', 'F&O'];
            final isSelected = _tabController.index == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _tabController.animateTo(index);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF142D25) : const Color(0xFFE6F7F0))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.green
                        : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    width: 1,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.green
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ==================== TAB 1: MARKET VIEW ====================
  Widget _buildMarketTab(bool isDark, double currentPrice, bool isPositive, Map<String, dynamic> specs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index Mini Chart representation
          Container(
            height: 180,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: StockChart(
              prices: _stockDetailController.chartData,
              isPositive: isPositive,
              isIndex: true,
            ),
          ),
          const SizedBox(height: 12),

          // Timeframe Selectors Row
          _buildTimeframeRow(isDark),
          const SizedBox(height: 24),

          // Redesigned Quick Actions row
          _buildQuickActionsRow(isDark),
          const SizedBox(height: 24),

          // Underlying securities performance
          _buildUnderlyingPerformanceCard(isDark),
          const SizedBox(height: 16),

          // Markets Today
          _buildMarketsTodayCard(isDark, currentPrice, specs),
          const SizedBox(height: 16),

          // Historical Performance
          _buildHistoricalPerformanceCard(isDark, currentPrice, specs),
          
          // Footer
          _buildFooter(isDark),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTimeframeRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['1d', '5d', '1m', '6m', '1y', '5y', 'max'].map((tf) {
                final isSel = tf == '1m'; // 1m is active in the screenshot
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFFFF7E6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSel ? const Color(0xFFFFB300) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tf,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? const Color(0xFFFF9800) : Colors.grey[500],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.orange[400], size: 18),
              Icon(Icons.arrow_outward_rounded, color: Colors.orange[400], size: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionItem(
          Icon(Icons.notifications_active_outlined, color: Colors.orange[700], size: 22),
          'Set Alert',
          isDark,
          onTap: () {},
        ),
        _buildQuickActionItem(
          Icon(Icons.bookmark_rounded, color: Colors.orange[700], size: 22),
          'Watchlist',
          isDark,
          onTap: () {},
        ),
        _buildQuickActionItem(
          Icon(Icons.insert_chart_rounded, color: Colors.orange[700], size: 22),
          'Chart',
          isDark,
          onTap: () {},
        ),
        _buildQuickActionItem(
          Icon(Icons.bolt_rounded, color: Colors.orange[700], size: 22),
          'Flash',
          isDark,
          onTap: () => _tabController.animateTo(2),
        ),
        _buildQuickActionItem(
          Icon(Icons.north_east_rounded, color: Colors.blue[700], size: 22),
          'Scalper',
          isDark,
          onTap: () => _tabController.animateTo(2),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(Widget iconWidget, String label, bool isDark, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.grey[850]! : Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderlyingPerformanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Underlying Performance',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildPerformanceRow('Positive Stocks', 11, 30, const Color(0xFF00C897), isDark),
          const SizedBox(height: 16),
          _buildPerformanceRow('Negative Stocks', 18, 30, const Color(0xFFF07470), isDark),
          const SizedBox(height: 16),
          _buildPerformanceRow('Neutral Stocks', 1, 30, Colors.deepPurple[400]!, isDark),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, int value, int total, Color color, bool isDark) {
    final double percent = value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: isDark ? Colors.grey[850] : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketsTodayCard(bool isDark, double currentPrice, Map<String, dynamic> specs) {
    final double open = currentPrice * 0.9943;
    final double high = currentPrice * 1.0025;
    final double low = currentPrice * 0.9926;
    final double prevClose = currentPrice * 0.9998;
    
    final double downside = ((currentPrice - low) / currentPrice) * 100;
    final double upside = ((high - currentPrice) / currentPrice) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Markets Today',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTodayStat('Open', open, isDark),
              _buildTodayStat('High', high, isDark),
              _buildTodayStat('Low', low, isDark),
              _buildTodayStat('Prev. Close', prevClose, isDark),
            ],
          ),
          const SizedBox(height: 20),
          _buildRangeSliderBar(
            low: low,
            high: high,
            current: currentPrice,
            downSideLabel: '${downside.toStringAsFixed(2)}%',
            upSideLabel: '${upside.toStringAsFixed(2)}%',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStat(String label, double val, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          val.toStringAsFixed(2),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        ),
      ],
    );
  }

  Widget _buildHistoricalPerformanceCard(bool isDark, double currentPrice, Map<String, dynamic> specs) {
    final double yearHigh = currentPrice * 1.1587;
    final double yearLow = currentPrice * 0.9621;
    final double threeYearLow = currentPrice * 0.8412;
    final double fiveYearLow = currentPrice * 0.6939;

    final double downside52w = ((currentPrice - yearLow) / currentPrice) * 100;
    final double upside52w = ((yearHigh - currentPrice) / currentPrice) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historical Performance',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHistStat('1-Year High', yearHigh, isDark),
              _buildHistStat('1-Year Low', yearLow, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHistStat('3-Year High', yearHigh, isDark),
              _buildHistStat('3-Year Low', threeYearLow, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHistStat('5-Year High', yearHigh, isDark),
              _buildHistStat('5-Year Low', fiveYearLow, isDark),
            ],
          ),
          const SizedBox(height: 20),
          _buildRangeSliderBar(
            low: yearLow,
            high: yearHigh,
            current: currentPrice,
            downSideLabel: '${downside52w.toStringAsFixed(2)}%',
            upSideLabel: '${upside52w.toStringAsFixed(2)}%',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHistStat(String label, double val, bool isDark) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.5, color: Colors.grey[500]),
          ),
          Text(
            val.toStringAsFixed(2),
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSliderBar({
    required double low,
    required double high,
    required double current,
    required String downSideLabel,
    required String upSideLabel,
    required bool isDark,
  }) {
    final double totalRange = high - low;
    final double ratio = totalRange == 0 ? 0.5 : (current - low) / totalRange;
    final double clampedRatio = ratio.clamp(0.0, 1.0);
    
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double barWidth = constraints.maxWidth;
            final double tooltipWidth = 72;
            final double leftOffset = (clampedRatio * barWidth) - (tooltipWidth / 2);
            final double clampedOffset = leftOffset.clamp(0.0, barWidth - tooltipWidth);
            
            return Stack(
              children: [
                SizedBox(height: 28, width: barWidth),
                Positioned(
                  left: clampedOffset,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9100),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          current.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: const Size(8, 4),
                        painter: _TrianglePainter(color: const Color(0xFFFF9100)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              low.toStringAsFixed(2),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.black87),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 5,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            height: 5,
                            width: width * clampedRatio,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(2.5),
                                bottomLeft: Radius.circular(2.5),
                              ),
                              color: Color(0xFFF07470),
                            ),
                          ),
                          Container(
                            height: 5,
                            width: width * (1.0 - clampedRatio),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(2.5),
                                bottomRight: Radius.circular(2.5),
                              ),
                              color: Color(0xFF00C897),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: (clampedRatio * width) - 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF9100), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 2,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              high.toStringAsFixed(2),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[300] : Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '↘ $downSideLabel down side',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF07470)),
            ),
            Text(
              'up side $upSideLabel ↗',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF00C897)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            'always invest for long term',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[800] : const Color(0xFFC8D3E0),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'built with ',
                style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
              const Icon(Icons.favorite, color: Colors.red, size: 12),
              Text(
                ' in India',
                style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: ANALYSIS VIEW ====================
  Widget _buildAnalysisTab(bool isDark, double currentPrice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Put-Call Ratio (PCR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Bullish', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.green)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '1.08',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  'PCR values above 1.0 indicate overall bullish strength in option contract volumes.',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Classic Pivot Point Levels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Table(
              border: TableBorder.symmetric(inside: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 0.5)),
              children: [
                _buildPivotRow('Resistance 3 (R3)', currentPrice + 300, AppColors.red, isDark),
                _buildPivotRow('Resistance 2 (R2)', currentPrice + 200, AppColors.red, isDark),
                _buildPivotRow('Resistance 1 (R1)', currentPrice + 100, AppColors.red, isDark),
                _buildPivotRow('Pivot Point (PP)', currentPrice, Colors.blue, isDark),
                _buildPivotRow('Support 1 (S1)', currentPrice - 100, AppColors.green, isDark),
                _buildPivotRow('Support 2 (S2)', currentPrice - 200, AppColors.green, isDark),
                _buildPivotRow('Support 3 (S3)', currentPrice - 300, AppColors.green, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildPivotRow(String label, double val, Color color, bool isDark) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(label, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '₹${val.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  // ==================== TAB 3: FLASH SCALPER VIEW ====================
  Widget _buildFlashTab(bool isDark, double currentPrice, Map<String, dynamic> specs) {
    final int interval = specs['strikeInterval'];
    final double atmStrike = (currentPrice / interval).roundToDouble() * interval;

    double cePrice = 85.0;
    double pePrice = 92.5;
    if (_flashStrikeOption == 'Near OTM') {
      cePrice = 35.40;
      pePrice = 41.20;
    } else if (_flashStrikeOption == 'Far OTM') {
      cePrice = 12.10;
      pePrice = 15.30;
    } else if (_flashStrikeOption == 'Near ITM') {
      cePrice = 145.20;
      pePrice = 156.80;
    }

    final double activeStrike = _flashOptionType == 'CE'
        ? (_flashStrikeOption == 'ATM'
            ? atmStrike
            : (_flashStrikeOption == 'Near OTM' ? atmStrike + interval : (_flashStrikeOption == 'Far OTM' ? atmStrike + interval * 2 : atmStrike - interval)))
        : (_flashStrikeOption == 'ATM'
            ? atmStrike
            : (_flashStrikeOption == 'Near OTM' ? atmStrike - interval : (_flashStrikeOption == 'Far OTM' ? atmStrike - interval * 2 : atmStrike + interval)));

    final String contractSymbol = '${widget.symbol.toUpperCase()} ${_selectedExpiry.toUpperCase()} ${activeStrike.toInt()} ${_flashOptionType == 'CE' ? 'CALL' : 'PUT'}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Flash Option Scalper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.5)),
          const SizedBox(height: 4),
          Text('Rapidly trade index options with single-tap executions.', style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 20),

          const Text('Select Strike Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['ATM', 'Near OTM', 'Far OTM', 'Near ITM'].map((opt) {
              final isSel = _flashStrikeOption == opt;
              return GestureDetector(
                onTap: () => setState(() => _flashStrikeOption = opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSel ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!)),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSel ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _flashOptionType = 'CE');
                    _triggerOptionTrade(contractSymbol, specs['lotSize']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1B3D2F), const Color(0xFF14241D)]
                            : [const Color(0xFFE6F7F0), const Color(0xFFCEEFE2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.green, width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(4)),
                          child: const Text('BULLISH', style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Text('BUY CE', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.green[800])),
                        const SizedBox(height: 6),
                        Text(
                          '₹${cePrice.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@ Strike ${activeStrike.toInt()}',
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _flashOptionType = 'PE');
                    _triggerOptionTrade(contractSymbol, specs['lotSize']);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF4C1D24), const Color(0xFF2C1417)]
                            : [const Color(0xFFFDE8E8), const Color(0xFFFCD4D4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red, width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(4)),
                          child: const Text('BEARISH', style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Text('BUY PE', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.red)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${pePrice.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@ Strike ${activeStrike.toInt()}',
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Flash Contract', style: TextStyle(fontSize: 12.5, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(contractSymbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Text('Lot Size: ${specs['lotSize']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChainTab(bool isDark, double spotPrice, Map<String, dynamic> specs) {
    final controller = Get.find<StockDetailController>();
    return Obx(() {
      if (controller.isLoadingOptionChain.value && controller.optionChainData.value == null) {
        return const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
      }

      // Check if we have real option chain from backend
      final data = controller.optionChainData.value;
      final int interval = specs['strikeInterval'];
      final List<Map<String, dynamic>> chain = [];
      double activeSpot = spotPrice;
      List<String> activeExpiries = List<String>.from(_expiries);

      if (data != null) {
        activeSpot = double.tryParse(data['spot_price']?.toString() ?? '') ?? spotPrice;
        final List<dynamic> expList = data['expiries'] ?? [];
        if (expList.isNotEmpty) {
          activeExpiries = expList.map((e) => e.toString()).toList();
        }
        
        final List<dynamic> backendStrikes = data['strikes'] ?? [];
        for (var s in backendStrikes) {
          chain.add({
            'strike': s['strike_price'],
            'callLtp': double.tryParse(s['call_ltp']?.toString() ?? '') ?? 0.0,
            'callLtpChg': double.tryParse(s['call_net_change']?.toString() ?? '') ?? 0.0,
            'callOi': s['call_oi']?.toString() ?? '0',
            'callOiChg': int.tryParse(s['call_oi_chg']?.toString() ?? '') ?? 0,
            'putLtp': double.tryParse(s['put_ltp']?.toString() ?? '') ?? 0.0,
            'putLtpChg': double.tryParse(s['put_net_change']?.toString() ?? '') ?? 0.0,
            'putOi': s['put_oi']?.toString() ?? '0',
            'putOiChg': int.tryParse(s['put_oi_chg']?.toString() ?? '') ?? 0,
            'pcr': double.tryParse(s['pcr']?.toString() ?? '') ?? 1.0,
            'call_key': s['call_key'] ?? '',
            'put_key': s['put_key'] ?? '',
            'call_symbol': s['call_symbol'] ?? '',
            'put_symbol': s['put_symbol'] ?? '',
          });
        }
      } else {
        chain.addAll(_generateOptionChain(spotPrice, interval));
      }

      final List<Map<String, dynamic>> filteredChain = [];
      if (_activeFilter == 'Near ATM') {
        final double atm = (activeSpot / interval).roundToDouble() * interval;
        filteredChain.addAll(chain.where((x) => (x['strike'] - atm).abs() <= interval * 2));
      } else {
        filteredChain.addAll(chain);
      }

      // If activeExpiries doesn't contain current selection, select the first one
      if (activeExpiries.isNotEmpty && !activeExpiries.contains(_selectedExpiry)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedExpiry = activeExpiries[0];
            });
            controller.fetchOptionChain(widget.symbol, expiry: _selectedExpiry);
          }
        });
      }

      final Color callsItmColor = isDark ? const Color(0xFF2C2210) : const Color(0xFFFFFDF0);
      final Color putsItmColor = isDark ? const Color(0xFF201832) : const Color(0xFFF3E8FF);

      return Column(
        children: [
          // Expiry Date Selection Horizontal Chips Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Checked/un-checked square box at the start
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1),
                    ),
                  ),
                  ...activeExpiries.map((exp) {
                    final isSel = _selectedExpiry == exp;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedExpiry = exp);
                        controller.fetchOptionChain(widget.symbol, expiry: exp);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? (isDark ? const Color(0xFF2C2210) : const Color(0xFFFFFDF0)) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFFB300) : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          exp,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSel ? const Color(0xFFFF9800) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Option Chain Card
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        // Option Chain Header with left/right Calls/Puts arrow tags
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.play_arrow_rounded, color: Colors.orange[400], size: 16),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Calls',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFFF9800)),
                                  ),
                                ],
                              ),
                              const Text(
                                'Option Chain',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Puts',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF9F5FFE)),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.play_arrow_rounded, color: Colors.purple[400], size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[850] : Colors.grey[200]),

                        // Column Headers Row
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: isDark ? Colors.grey[900] : const Color(0xFFF9FAFB),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Column(children: [Text('OI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('change', style: TextStyle(fontSize: 9.5, color: Colors.grey))])),
                              Expanded(flex: 3, child: Column(children: [Text('LTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('change', style: TextStyle(fontSize: 9.5, color: Colors.grey))])),
                              Expanded(flex: 3, child: Column(children: [Text('Strike', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('PCR', style: TextStyle(fontSize: 9.5, color: Colors.grey))])),
                              Expanded(flex: 3, child: Column(children: [Text('LTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('change', style: TextStyle(fontSize: 9.5, color: Colors.grey))])),
                              Expanded(flex: 3, child: Column(children: [Text('OI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Text('change', style: TextStyle(fontSize: 9.5, color: Colors.grey))])),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[850] : Colors.grey[200]),

                        // Double-sided Option List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredChain.length,
                          itemBuilder: (context, i) {
                            final item = filteredChain[i];
                            final double strikePrice = item['strike'].toDouble();

                            final bool showSpotBefore = (i > 0 && activeSpot > filteredChain[i-1]['strike'] && activeSpot <= strikePrice);
                            final bool showSpotAtStart = (i == 0 && activeSpot <= strikePrice);

                            return Column(
                              children: [
                                if (showSpotAtStart || showSpotBefore) _buildAtmSpotDivider(isDark, activeSpot),
                                _buildOptionChainRow(item, activeSpot, callsItmColor, putsItmColor, specs['lotSize'], isDark),
                              ],
                            );
                          },
                        ),
                        if (filteredChain.isNotEmpty && activeSpot > filteredChain.last['strike'])
                          _buildAtmSpotDivider(isDark, activeSpot),
                      ],
                    ),
                  ),

                  // Show All button row
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 4, bottom: 12),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1),
                        ),
                        child: Text(
                          'Show All',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Filter Pills Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['O = H', 'O = L', 'High OI', 'High Vol', 'High IV'].map((flt) {
                          final isSel = _activeFilter == flt;
                          return GestureDetector(
                            onTap: () => setState(() => _activeFilter = flt),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                flt,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAtmSpotDivider(bool isDark, double spotPrice) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(color: Colors.blue[300]!),
              ),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 1),
                painter: _DashedLinePainter(color: Colors.blue[300]!),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF007A5E), // Dhan green
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            spotPrice.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionChainRow(Map<String, dynamic> item, double spotPrice, Color callsItmColor, Color putsItmColor, int lotSize, bool isDark) {
    final int strike = item['strike'];
    final double callLtp = item['callLtp'];
    final double callLtpChg = item['callLtpChg'];
    final String callOi = item['callOi'];
    final int callOiChg = item['callOiChg'];
    
    final double putLtp = item['putLtp'];
    final double putLtpChg = item['putLtpChg'];
    final String putOi = item['putOi'];
    final int putOiChg = item['putOiChg'];
    
    final double pcr = item['pcr'];

    final bool callItm = strike < spotPrice;
    final bool putItm = strike > spotPrice;

    final String ceSymbol = item['call_symbol'] != null && item['call_symbol'].toString().isNotEmpty
        ? item['call_symbol'].toString()
        : '${widget.symbol.toUpperCase()} ${_selectedExpiry.toUpperCase()} $strike CALL';
        
    final String peSymbol = item['put_symbol'] != null && item['put_symbol'].toString().isNotEmpty
        ? item['put_symbol'].toString()
        : '${widget.symbol.toUpperCase()} ${_selectedExpiry.toUpperCase()} $strike PUT';

    final Color callsBg = callItm ? (isDark ? const Color(0xFF2C2210) : const Color(0xFFFFFDF0)) : Colors.transparent;
    final Color putsBg = putItm ? (isDark ? const Color(0xFF201832) : const Color(0xFFF3E8FF)) : Colors.transparent;
    
    final Color callsBorderColor = const Color(0xFFFFB300);
    final Color putsBorderColor = const Color(0xFF9F5FFE);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.grey[900]! : Colors.grey[200]!, width: 0.5)),
      ),
      child: Row(
        children: [
          // 1. CALLS OI & OI Change
          Expanded(
            flex: 3,
            child: Container(
              color: callsBg,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    callOi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatIndianNumber(callOiChg),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C897),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CALLS LTP & LTP Change (with solid right border if ITM)
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => _triggerOptionTrade(ceSymbol, lotSize),
              child: Container(
                decoration: BoxDecoration(
                  color: callsBg,
                  border: Border(
                    right: BorderSide(
                      color: callItm ? callsBorderColor : Colors.transparent,
                      width: callItm ? 2.0 : 0.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      callLtp.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      callLtpChg.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: callLtpChg >= 0 ? const Color(0xFF00C897) : const Color(0xFFF07470),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. STRIKE & PCR (Center Column)
          Expanded(
            flex: 3,
            child: Container(
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFFF8FAFC),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatIndianNumber(strike),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pcr.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. PUTS LTP & LTP Change (with solid left border if ITM)
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => _triggerOptionTrade(peSymbol, lotSize),
              child: Container(
                decoration: BoxDecoration(
                  color: putsBg,
                  border: Border(
                    left: BorderSide(
                      color: putItm ? putsBorderColor : Colors.transparent,
                      width: putItm ? 2.0 : 0.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      putLtp.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      putLtpChg.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: putLtpChg >= 0 ? const Color(0xFF00C897) : const Color(0xFFF07470),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. PUTS OI & OI Change
          Expanded(
            flex: 3,
            child: Container(
              color: putsBg,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    putOi,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatIndianNumber(putOiChg),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00C897),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 5: FUTURES & OTHERS VIEW ====================
  Widget _buildFuturesTab(bool isDark, double currentPrice, Map<String, dynamic> specs) {
    final symbolUpper = widget.symbol.toUpperCase();
    final List<Map<String, dynamic>> futures = [
      {
        'symbol': '${symbolUpper} JUN FUT',
        'ltp': currentPrice + 45.30,
        'change': 24.50,
        'changePct': 0.11,
      },
      {
        'symbol': '${symbolUpper} JUL FUT',
        'ltp': currentPrice + 90.80,
        'change': 18.20,
        'changePct': 0.08,
      },
      {
        'symbol': '${symbolUpper} AUG FUT',
        'ltp': currentPrice + 135.50,
        'change': -5.40,
        'changePct': -0.02,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: futures.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final fut = futures[i];
        final bool isPos = fut['change'] >= 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fut['symbol'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lot Size: ${specs['lotSize']}',
                    style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${fut['ltp'].toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isPos ? '+' : ''}${fut['change'].toStringAsFixed(2)} (${fut['changePct'].toStringAsFixed(2)}%)',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isPos ? AppColors.green : AppColors.red),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => _triggerOptionTrade(fut['symbol'], specs['lotSize']),
                    child: const Text('TRADE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Persistent Bottom Navigation Bar
  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C26).withOpacity(0.95) : const Color(0xFFE2E8F0).withOpacity(0.95),
        border: Border(top: BorderSide(color: isDark ? Colors.grey[850]! : Colors.grey[300]!, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildBottomBarButton(
                icon: Icon(Icons.tune_rounded, color: Colors.orange[400], size: 18),
                label: 'Chain',
                isDark: isDark,
                onTap: () => _tabController.animateTo(3), // Option Chain tab
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBottomBarButton(
                icon: Icon(Icons.north_east_rounded, color: Colors.blue[600], size: 18),
                label: 'Scalper',
                isDark: isDark,
                onTap: () => _tabController.animateTo(2), // Flash tab
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBottomBarButton(
                icon: Icon(Icons.bolt_rounded, color: Colors.orange[400], size: 18),
                label: 'Flash',
                isDark: isDark,
                onTap: () => _tabController.animateTo(2), // Flash tab
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarButton({required Widget icon, required String label, required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232D3F) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Downward pointer triangle painter
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Dashed line painter
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    double max = size.width;
    double dashWidth = 5;
    double dashSpace = 3;
    double startX = 0;
    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
