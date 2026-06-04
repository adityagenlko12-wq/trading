import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/routes/routes.dart';

class CommoditySubTab extends StatefulWidget {
  const CommoditySubTab({super.key});

  @override
  State<CommoditySubTab> createState() => _CommoditySubTabState();
}

class _CommoditySubTabState extends State<CommoditySubTab> {
  final DashboardController _dashboardCtrl = Get.find<DashboardController>();
  bool _isLoading = true;
  String _errorMessage = '';
  
  List<dynamic> _liveMarkets = [];
  Map<String, dynamic> _optionsData = {};
  
  // Segment filters matching Dhan UI
  bool _isMcxSelected = true;
  String _selectedCategory = 'Energy'; // Default to Energy as per screenshot
  
  // Carousel controller for Expiry Trading PageView
  final PageController _pageController = PageController(initialPage: 0);
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCommodityData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCommodityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final data = await _dashboardCtrl.tradeRepository.getCommodityData();
      setState(() {
        _liveMarkets = data['live_markets'] ?? [];
        _optionsData = data['options'] ?? {};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load commodity data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.red[300] : Colors.red[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCommodityData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommodityData,
      color: AppColors.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 0. Dhan Search Bar for Commodities
          _buildSearchBar(isDark),
          const SizedBox(height: 10),

          // 1. Live Markets Section (Horizontal futures cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  color: const Color(0xFF00B050), // Green dot indicator
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Markets',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildLiveMarketsList(isDark),
          const SizedBox(height: 16),

          // 2. Expiry Trading Carousel Card
          _buildExpiryTradingSection(isDark),
          const SizedBox(height: 16),
          
          // 3. Commodity Futures Header with Segment selector (MCX/NSE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commodity Futures',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Custom Switch Toggle for MCX vs NSE
                Row(
                  children: [
                    Text(
                      'MCX',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _isMcxSelected 
                            ? AppColors.primary 
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Switch(
                          value: !_isMcxSelected,
                          onChanged: (value) {
                            setState(() {
                              _isMcxSelected = !value;
                            });
                          },
                          activeColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withOpacity(0.3),
                          inactiveThumbColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'NSE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: !_isMcxSelected 
                            ? AppColors.primary 
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          // 4. Category Selector tabs (Energy, Bullion, Metals)
          _buildCategorySelector(isDark),
          const SizedBox(height: 8),
          
          // 5. Commodity Futures Contract List
          _buildFuturesList(isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        readOnly: true,
        onTap: () {
          // Open details for first active asset
          if (_liveMarkets.isNotEmpty) {
            Get.toNamed(RouteHelper.stockDetail, arguments: _liveMarkets[0]['symbol']);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search for Commodities to trade',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.wb_sunny_outlined, color: Colors.orange), // Yellow sun logo prefix
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E222D) : const Color(0xFFF2F4F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveMarketsList(bool isDark) {
    // Collect Futures elements
    final List<dynamic> futs = _liveMarkets.where((x) {
      final String sym = (x['symbol'] ?? '').toString().toUpperCase();
      return sym.contains('FUT');
    }).toList();

    // Sort to keep Gold/Silver mini at front for top card matching ss
    futs.sort((a, b) {
      final symA = a['symbol'].toString();
      if (symA.contains('GOLDM')) return -1;
      if (symA.contains('GOLD')) return 0;
      return 1;
    });

    if (futs.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(child: Text('No live futures active.')),
      );
    }

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: futs.length,
        itemBuilder: (context, index) {
          final item = futs[index];
          final String symbol = item['symbol'] ?? '';
          final double price = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
          final double change = double.tryParse(item['change']?.toString() ?? '') ?? 0.0;
          final double pct = double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0;

          final isPositive = change >= 0;
          final trendColor = isPositive ? const Color(0xFF00B050) : const Color(0xFFE53935);
          final cardBg = isDark ? const Color(0xFF1E222D) : Colors.white;
          final borderColor = isDark ? Colors.grey[850]! : Colors.grey[200]!;

          return GestureDetector(
            onTap: () {
              Get.toNamed(RouteHelper.stockDetail, arguments: symbol);
            },
            child: Container(
              width: 190,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        color: trendColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          symbol,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${isPositive ? '+' : ''}${pct.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpiryTradingSection(bool isDark) {
    // Find active energy/bullion futures contracts to display in page carousel
    final List<dynamic> carouselFuts = _liveMarkets.where((x) {
      final String sym = (x['symbol'] ?? '').toString().toUpperCase();
      return sym.contains('CRUDEOIL') || sym.contains('GOLD') || sym.contains('NATURALGAS') || sym.contains('SILVER');
    }).toList();

    // Default mock list if backend response empty
    if (carouselFuts.isEmpty) {
      carouselFuts.add({
        'symbol': 'CRUDEOIL JUN FUT',
        'price': 8880.00,
        'change': -360.00,
        'change_percent': -3.90,
        'expiry': DateTime.now().add(const Duration(days: 14)).millisecondsSinceEpoch
      });
    }

    return Column(
      children: [
        // Expiry Trading Title header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Expiry Trading',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Carousel Container
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselFuts.length,
            onPageChanged: (idx) {
              setState(() {
                _carouselIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              final item = carouselFuts[index];
              final String symbol = item['symbol'] ?? '';
              final double price = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
              final double change = double.tryParse(item['change']?.toString() ?? '') ?? 0.0;
              final double pct = double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0;
              
              // Estimate expiry days remaining
              final int expiryMs = item['expiry'] ?? 0;
              final int nowMs = DateTime.now().millisecondsSinceEpoch;
              final int daysLeft = expiryMs > nowMs ? ((expiryMs - nowMs) / (1000 * 60 * 60 * 24)).ceil() : 14;

              final isPositive = change >= 0;
              final trendColor = isPositive ? const Color(0xFF00B050) : const Color(0xFFE53935);
              final cardBg = isDark ? const Color(0xFF1E222D) : const Color(0xFFFFFDF9);
              final borderColor = isDark ? Colors.grey[850]! : const Color(0xFFFEEEC8);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Logo + Symbol Name + Expiry Badge
                    Row(
                      children: [
                        // Barrel Logo representation
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.opacity, color: Colors.orange, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          symbol,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Expiry in $daysLeft days',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    
                    // Middle Row: Price & net change details
                    Row(
                      children: [
                        Text(
                          _formatPrice(price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: trendColor,
                          size: 13,
                        ),
                      ],
                    ),
                    
                    // Action Buttons Row
                    Row(
                      children: [
                        _buildActionChip(
                          label: 'Option Chain',
                          icon: Icons.grid_view_rounded,
                          color: isDark ? const Color(0xFF2C3240) : Colors.white,
                          borderColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          onTap: () {
                            // Deep link pre-selecting tab 3 (Option Chain)
                            Get.toNamed(RouteHelper.stockDetail, arguments: {
                              'symbol': symbol,
                              'initialTab': 3
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionChip(
                          label: 'Flash Trade',
                          icon: Icons.flash_on_rounded,
                          color: isDark ? const Color(0xFF2C3240) : Colors.white,
                          borderColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          onTap: () {
                            // Deep link pre-selecting tab 2 (Flash Trade)
                            Get.toNamed(RouteHelper.stockDetail, arguments: {
                              'symbol': symbol,
                              'initialTab': 2
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionChip(
                          label: 'Scalper',
                          icon: Icons.show_chart_rounded,
                          color: isDark ? const Color(0xFF2C3240) : Colors.white,
                          borderColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          onTap: () {
                            Get.toNamed(RouteHelper.stockDetail, arguments: {
                              'symbol': symbol,
                              'initialTab': 2
                            });
                          },
                        ),
                        const Spacer(),
                        // Round play button icon
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.amber, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Carousel dots indicators matching ss
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(carouselFuts.length, (dotIndex) {
            final isCurrent = dotIndex == _carouselIndex;
            return Container(
              width: isCurrent ? 8 : 6,
              height: isCurrent ? 8 : 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF00B050) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12.5, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final list = ['Energy', 'Bullion', 'Metals'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final cat = list[index];
          final isActive = _selectedCategory == cat;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive 
                    ? (isDark ? const Color(0xFF1B2E24) : const Color(0xFFE8F5E9))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive 
                      ? AppColors.primary 
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFuturesList(bool isDark) {
    // 1. Group active futures based on selected category (Energy vs Bullions vs Metals)
    final filteredFuts = _liveMarkets.where((x) {
      final String key = (x['key'] ?? '').toString().toUpperCase();
      final String sym = (x['symbol'] ?? '').toString().toUpperCase();
      final String asset = (x['asset'] ?? '').toString().toUpperCase();
      
      final isMcx = x['exchange'] == 'MCX' || key.contains('MCX');
      if (_isMcxSelected && !isMcx) return false;
      if (!_isMcxSelected && isMcx) return false;

      // Group futures matching category
      if (_selectedCategory == 'Energy') {
        return asset.contains('CRUDE') || asset.contains('NATURAL') || asset.contains('NATGAS');
      } else if (_selectedCategory == 'Bullion') {
        return asset.contains('GOLD') || asset.contains('SILVER');
      } else { // Metals
        return asset.contains('ZINC') || asset.contains('ALUMINIUM') || asset.contains('ALUMINI');
      }
    }).toList();

    if (filteredFuts.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          'No $_selectedCategory contracts found.',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return Column(
      children: filteredFuts.map((item) {
        final symbol = item['symbol'] ?? '';
        final exch = item['exchange'] ?? 'MCX';
        final price = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
        final change = double.tryParse(item['change']?.toString() ?? '') ?? 0.0;
        final pct = double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0;
        
        final isPositive = change >= 0;
        final trendColor = isPositive ? const Color(0xFF00B050) : const Color(0xFFE53935);
        final dividerColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;

        // Estimate expiry date display (e.g. "18 Jun")
        final int expiryMs = item['expiry'] ?? 0;
        final expiryText = expiryMs > 0 
            ? _formatExpiryDate(expiryMs)
            : '18 Jun';

        return GestureDetector(
          onTap: () {
            Get.toNamed(RouteHelper.stockDetail, arguments: symbol);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left Column: Symbol Details (Name & Exch + Expiry info)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            exch,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            expiryText,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Right Column: Live Price & Net Change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(price),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: trendColor,
                          size: 11,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper formatting functions
  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return price.toStringAsFixed(2);
  }

  String _formatExpiryDate(int ms) {
    try {
      final dt = DateTime.fromMillisecondsSinceEpoch(ms);
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return '18 Jun';
    }
  }
}
