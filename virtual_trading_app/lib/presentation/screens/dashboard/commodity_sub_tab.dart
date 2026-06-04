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
  String _selectedCategory = 'Bullions';
  String _selectedSubCategory = 'Gold';
  
  // Sub-categories map
  final Map<String, List<String>> _subCategories = {
    'Bullions': ['Gold', 'Silver', 'Gold Mini', 'Silver Mini'],
    'Energy': ['Crude Oil', 'Crude Oil Mini', 'Natural Gas', 'Natural Gas Mini'],
    'Metals': ['Zinc', 'Zinc Mini', 'Aluminium', 'Aluminium Mini']
  };

  @override
  void initState() {
    super.initState();
    _loadCommodityData();
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        children: [
          // 1. Live Markets Section (Horizontal futures cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Markets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildLiveMarketsList(isDark),
          
          const SizedBox(height: 24),
          
          // 2. Top Traded Options Header with MCX/NSE toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Traded Options',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Custom Switch Toggle
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
                      height: 30,
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
          const SizedBox(height: 12),
          
          // 3. Category Selector pills (Energy, Metals, Bullions)
          _buildCategorySelector(isDark),
          const SizedBox(height: 12),
          
          // 4. Sub-category Selector pills (e.g. Gold, Silver...)
          _buildSubCategorySelector(isDark),
          const SizedBox(height: 16),
          
          // 5. Options Contract List
          _buildOptionsList(isDark),
        ],
      ),
    );
  }

  Widget _buildLiveMarketsList(bool isDark) {
    if (_liveMarkets.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No futures contracts active.')),
      );
    }
    
    // Filter futures based on exchange selection (MCX vs NSE commodities - mock fallback)
    final filteredFuts = _liveMarkets.where((x) {
      final isMcx = x['exchange'] == 'MCX' || x['key'].toString().contains('MCX');
      return _isMcxSelected ? isMcx : !isMcx;
    }).toList();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: filteredFuts.isEmpty ? 2 : filteredFuts.length,
        itemBuilder: (context, index) {
          if (filteredFuts.isEmpty) {
            // Mock index loader when no matching exchange items are found
            final isGold = index == 0;
            return _buildFutureCard(
              symbol: isGold ? 'GOLD JUN FUT' : 'GOLDM JUN FUT',
              price: isGold ? 155685.00 : 156001.00,
              change: isGold ? 1350.0 : 1540.0,
              pct: isGold ? 0.88 : 1.00,
              isDark: isDark,
              keyStr: isGold ? 'GOLD' : 'GOLDM'
            );
          }
          final item = filteredFuts[index];
          return _buildFutureCard(
            symbol: item['symbol'] ?? '',
            price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
            change: double.tryParse(item['change']?.toString() ?? '') ?? 0.0,
            pct: double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0,
            isDark: isDark,
            keyStr: item['key'] ?? ''
          );
        },
      ),
    );
  }

  Widget _buildFutureCard({
    required String symbol,
    required double price,
    required double change,
    required double pct,
    required bool isDark,
    required String keyStr
  }) {
    final isPositive = change >= 0;
    final trendColor = isPositive ? const Color(0xFF00B050) : const Color(0xFFE53935);
    final cardBg = isDark ? const Color(0xFF1E222D) : Colors.white;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return GestureDetector(
      onTap: () {
        Get.toNamed(RouteHelper.stockDetail, arguments: symbol);
      },
      child: Container(
        width: 175,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey[100]!,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: trendColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    symbol,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              price.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: trendColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final list = ['Energy', 'Metals', 'Bullions'];
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
                _selectedSubCategory = _subCategories[cat]![0];
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive 
                    ? (isDark ? const Color(0xFF1B2E24) : const Color(0xFFE8F5E9))
                    : (isDark ? const Color(0xFF1E222D) : Colors.grey[100]),
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
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategorySelector(bool isDark) {
    final subCats = _subCategories[_selectedCategory] ?? [];
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: subCats.length,
        itemBuilder: (context, index) {
          final sub = subCats[index];
          final isActive = _selectedSubCategory == sub;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubCategory = sub;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive 
                    ? AppColors.primary 
                    : (isDark ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
              child: Text(
                sub,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isActive ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionsList(bool isDark) {
    final catData = _optionsData[_selectedCategory] ?? {};
    final List<dynamic> options = catData[_selectedSubCategory] ?? [];
    
    if (options.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear, size: 40, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              'No options available for $_selectedSubCategory currently.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: options.map((item) {
        final symbol = item['symbol'] ?? '';
        final exch = item['exchange'] ?? 'MCX';
        final price = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
        final change = double.tryParse(item['change']?.toString() ?? '') ?? 0.0;
        final pct = double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0;
        
        final isPositive = change >= 0;
        final trendColor = isPositive ? const Color(0xFF00B050) : const Color(0xFFE53935);
        final dividerColor = isDark ? Colors.grey[850]! : Colors.grey[100]!;

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
                // Symbol Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exch,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: trendColor,
                          size: 12,
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
}
