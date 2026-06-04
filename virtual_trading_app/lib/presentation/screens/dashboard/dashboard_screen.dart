import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/portfolio_controller.dart';
import '../../controllers/stock_detail_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/routes/routes.dart';
import '../../../data/models/market_data_model.dart';
import 'commodity_sub_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  void _onBottomTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Refresh controllers when navigating to keep data fresh and dynamic
    if (index == 0) {
      Get.find<DashboardController>().loadDashboardData();
    } else if (index == 2) {
      Get.find<PortfolioController>().loadPortfolioDetails();
    } else if (index == 3) {
      Get.find<PortfolioController>().loadPortfolioDetails();
    }
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return GestureDetector(
      onTap: () => _onBottomTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Bottom navigation content mapping
    final List<Widget> tabs = [
      _HomeMainView(
        subTabController: _subTabController,
        onSearchTap: () => _onBottomTabChanged(1),
      ),
      const _WatchlistView(),
      const _PortfolioView(),
      _OrdersView(
        onSearchTap: () => _onBottomTabChanged(1),
      ),
      const _MoneyView(),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),
      bottomNavigationBar: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home_filled, 'Home', isDark),
              _buildBottomNavItem(1, Icons.bookmark_border_rounded, 'Watchlist', isDark),
              
              // Custom Dhan "ध" Icon for Portfolio tab in the center
              GestureDetector(
                onTap: () => _onBottomTabChanged(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (_currentIndex == 2)
                          Positioned(
                            top: -12,
                            child: CustomPaint(
                              size: const Size(40, 10),
                              painter: _CurvedTopIndicatorPainter(),
                            ),
                          ),
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _currentIndex == 2
                                ? AppColors.primary
                                : (isDark ? Colors.grey[850] : const Color(0xFFF3F4F6)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentIndex == 2
                                  ? AppColors.primary
                                  : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'ध',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _currentIndex == 2 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Portfolio',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: _currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
                        color: _currentIndex == 2
                            ? AppColors.primary
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              
              _buildBottomNavItem(3, Icons.assignment_outlined, 'Orders', isDark),
              _buildBottomNavItem(4, Icons.account_balance_wallet_outlined, 'Money', isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurvedTopIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper Widget: Top Greeting Header Block matching Dhan Styling
class _DhanHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  const _DhanHeader({this.onSearchTap});

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'TR';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return (first + second).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = authCtrl.user.value?.name ?? 'Trader';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Initials Avatar (Green background, white text)
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.green,
                child: Text(
                  _getInitials(name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Hello ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Container(
                          height: 2.0,
                          color: AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.wifi, color: isDark ? Colors.white70 : Colors.black54, size: 20),
              const SizedBox(width: 16),
              Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white70 : Colors.black54, size: 22),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onSearchTap,
                child: Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================== TABS 1: HOME & STOCKS ========================
class _HomeMainView extends StatelessWidget {
  final TabController subTabController;
  final VoidCallback? onSearchTap;

  const _HomeMainView({required this.subTabController, this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _DhanHeader(onSearchTap: onSearchTap),
        // Inner Top Sub-tabs row matching Dhan screenshot
        Container(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: subTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            labelColor: isDark ? Colors.white : Colors.black87,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            tabs: const [
              Tab(text: 'Home'),
              Tab(text: 'Stocks'),
              Tab(text: 'Options'),
              Tab(text: 'Mutual Funds'),
              Tab(text: 'Commodity'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: subTabController,
            children: [
              _HomeSubTab(subTabController: subTabController),
              const _StocksSubTab(),
              const _OptionsSubTab(),
              _buildPlaceholderView('Mutual Funds Investment Basket Mode Under Construction', isDark),
              const CommoditySubTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderView(String text, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// SUB-TAB: HOME
class _HomeSubTab extends StatelessWidget {
  final TabController subTabController;
  const _HomeSubTab({required this.subTabController});

  void _showAllIndicesSheet(BuildContext context, bool isDark) {
    final controller = Get.find<DashboardController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Market Indices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final list = controller.indices;
              if (list.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppColors.primary)));
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final idxItem = list[idx];
                  final isPos = idxItem.change >= 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(idxItem.companyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(idxItem.symbol, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idxItem.price.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${isPos ? '+' : ''}${idxItem.change.toStringAsFixed(2)} (${idxItem.changePercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPos ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.back();
                      Get.find<StockDetailController>().initialize(idxItem.symbol);
                      Get.toNamed(RouteHelper.stockDetail, arguments: idxItem.symbol);
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final portCtrl = Get.find<PortfolioController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => controller.loadDashboardData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Card containing Clickable Nifty 50 ticker card and 4 ListTiles exactly like Dhan screenshot
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: Column(
                children: [
                  // Nifty 50 Row (Clickable)
                  GestureDetector(
                    onTap: () {
                      Get.find<StockDetailController>().initialize('NIFTY');
                      Get.toNamed(RouteHelper.stockDetail, arguments: 'NIFTY');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Obx(() {
                        final nifty = controller.indices.firstWhereOrNull((item) => item.symbol == 'NIFTY');
                        final double niftyLtp = nifty?.price ?? 23400.65;
                        final double niftyChange = nifty?.change ?? -82.90;
                        final double niftyPct = nifty?.changePercent ?? -0.35;
                        final isPos = niftyChange >= 0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Nifty 50  ',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  niftyLtp.toStringAsFixed(2),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${niftyChange.toStringAsFixed(2)} (${niftyPct.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    color: isPos ? AppColors.green : AppColors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isPos ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                  color: isPos ? AppColors.green : AppColors.red,
                                  size: 13,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  size: 14,
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  // Category List items (Interactive!)
                  _buildQuickLinkItem(Icons.pie_chart_outline_rounded, 'ETFs', 'Exchange Traded Funds', isDark, onTap: () {
                    subTabController.animateTo(1);
                  }),
                  _buildQuickLinkItem(Icons.grid_goldenratio_rounded, 'Commodities', 'Trade in Crude Oil, Gold, etc', isDark, onTap: () {
                    subTabController.animateTo(4);
                  }),
                  _buildQuickLinkItem(Icons.lock_person_outlined, 'Gold Vault', 'Buy 99.9% pure Gold & Silver', isDark, onTap: () {
                    subTabController.animateTo(4);
                  }),
                  _buildQuickLinkItem(Icons.show_chart_rounded, 'Futures', 'Trade in Futures contracts', isDark, isLast: true, onTap: () {
                    subTabController.animateTo(2);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // More on Markets Header
            const Text(
              'More on Markets',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMarketsGridCard(Icons.pie_chart_outline_rounded, 'IPOs', isDark, onTap: () {
                    subTabController.animateTo(1);
                  }),
                  const SizedBox(width: 12),
                  _buildMarketsGridCard(Icons.query_stats_rounded, 'All Indices', isDark, onTap: () {
                    _showAllIndicesSheet(context, isDark);
                  }),
                  const SizedBox(width: 12),
                  _buildMarketsGridCard(Icons.newspaper_rounded, 'News Insights', isDark, onTap: () {
                    subTabController.animateTo(1);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Access Cards Block
            const Text(
              'Quick Access',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildQuickAccessTile('Scalper', 'Fast Scalping on Charts', isDark, color: Colors.blue[300]!)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuickAccessTile('Charts', 'Trade Directly on Charts', isDark, color: Colors.green[300]!)),
              ],
            ),
            const SizedBox(height: 20),

            // Premium rocket banner exactly matching MTF Upgrade in Dhan UI screenshot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                      : [const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.rocket_launch_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('LIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.green)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MTF Upgrade: ₹5 Cr Funding Limit!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Explore margins on 1700+ Stocks >>',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // "Your Portfolio Summary on Dhan" section
            const Text(
              'Your Portfolio Summary on Dhan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final pl = portCtrl.totalPL.value;
              final invested = portCtrl.totalInvested.value;
              final currentVal = portCtrl.currentValue.value;
              final double roi = invested > 0 ? (pl / invested * 100) : 0.0;
              final isProfit = pl >= 0;

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
                    // Sub-tabs row
                    Row(
                      children: [
                        _buildSummaryTab('All', active: true),
                        const SizedBox(width: 8),
                        _buildSummaryTab('Stocks'),
                        const SizedBox(width: 8),
                        _buildSummaryTab('ETFs'),
                        const SizedBox(width: 8),
                        _buildSummaryTab('MF'),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Profit',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${pl.toStringAsFixed(2)} ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isProfit ? AppColors.green : AppColors.red,
                          ),
                        ),
                        Text(
                          '(${roi.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isProfit ? AppColors.green : AppColors.red,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Investment', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Text('₹${invested.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current Value', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Text('₹${currentVal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Invest / Trade on Stock Exchanges block
            const Text(
              'Invest / Trade on Stock Exchanges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildExchangesItem(Icons.business_center_outlined, 'Stocks', 'Invest or Trade in Equity', isDark, onTap: () {
                    subTabController.animateTo(1);
                  }),
                  _buildExchangesItem(Icons.bar_chart_rounded, 'Options Trading', 'Trade in Derivatives contracts', isDark, onTap: () {
                    subTabController.animateTo(2);
                  }),
                  _buildExchangesItem(Icons.pie_chart_rounded, 'Mutual Funds', 'Higher returns with direct mutual funds', isDark, onTap: () {
                    subTabController.animateTo(3);
                  }),
                  _buildExchangesItem(Icons.home_outlined, 'Rent Stocks', 'Rent and Earn Extra on your Stocks', isDark, onTap: () {
                    subTabController.animateTo(1);
                  }),
                  _buildExchangesItem(Icons.analytics_rounded, 'ETFs', 'Exchange Traded Funds', isDark, isLast: true, onTap: () {
                    subTabController.animateTo(1);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(String label, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppColors.primary : Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.primary : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildQuickLinkItem(IconData icon, String title, String desc, bool isDark, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        ),
        if (!isLast) Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ],
    );
  }

  Widget _buildExchangesItem(IconData icon, String title, String desc, bool isDark, {required VoidCallback onTap, bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(desc, style: const TextStyle(fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        ),
        if (!isLast) Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ],
    );
  }

  Widget _buildMarketsGridCard(IconData icon, String title, bool isDark, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessTile(String title, String desc, bool isDark, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: color, size: 20),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// SUB-TAB: STOCKS (Discover & Trending)
class _StocksSubTab extends StatefulWidget {
  const _StocksSubTab();

  @override
  State<_StocksSubTab> createState() => _StocksSubTabState();
}

class _StocksSubTabState extends State<_StocksSubTab> {
  String _selectedCategory = 'Stocks in News';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• Live Markets',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),

          // Live markets cards (Nifty 50 and SENSEX side-by-side)
          Obx(() {
            final nifty = controller.indices.firstWhereOrNull((item) => item.symbol == 'NIFTY');
            final sensex = controller.indices.firstWhereOrNull((item) => item.symbol == 'SENSEX');

            final niftyLtp = nifty?.price ?? 23401.25;
            final niftyChange = nifty?.change ?? -82.90;
            final niftyPct = nifty?.changePercent ?? -0.35;

            final sensexLtp = sensex?.price ?? 74330.77;
            final sensexChange = sensex?.change ?? -320.75;
            final sensexPct = sensex?.changePercent ?? -0.43;

            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.find<StockDetailController>().initialize('NIFTY');
                      Get.toNamed(RouteHelper.stockDetail, arguments: 'NIFTY');
                    },
                    child: _buildIndexHeaderCard('Nifty 50', niftyLtp, niftyChange, niftyPct, isDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.find<StockDetailController>().initialize('SENSEX');
                      Get.toNamed(RouteHelper.stockDetail, arguments: 'SENSEX');
                    },
                    child: _buildIndexHeaderCard('SENSEX', sensexLtp, sensexChange, sensexPct, isDark),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Discover Stocks Header
          const Text(
            'Discover Stocks to Invest or Trade',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 14),

          // Trending on Dhan box
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
                  children: [
                    const Icon(Icons.analytics, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Trending on Dhan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Pill buttons row
                Row(
                  children: [
                    _buildInteractivePill('Stocks in News', isDark),
                    const SizedBox(width: 8),
                    _buildInteractivePill('Most Traded', isDark),
                    const SizedBox(width: 8),
                    _buildInteractivePill('Most Bought MTF', isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Stocks list view
                Obx(() {
                  final List<MarketDataModel> list;
                  if (_selectedCategory == 'Most Traded') {
                    list = controller.topGainers;
                  } else if (_selectedCategory == 'Most Bought MTF') {
                    list = controller.topLosers;
                  } else {
                    list = controller.trendingStocks;
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(height: 24, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isPos = item.change >= 0;
                      return GestureDetector(
                        onTap: () {
                          Get.find<StockDetailController>().initialize(item.symbol);
                          Get.toNamed(RouteHelper.stockDetail, arguments: item.symbol);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.companyName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'NSE',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.price.toStringAsFixed(2),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${isPos ? '+' : ''}${item.change.toStringAsFixed(2)} (${item.changePercent.toStringAsFixed(2)}%)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isPos ? AppColors.green : AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View all Trending Stocks', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_circle_right_outlined, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractivePill(String label, bool isDark) {
    final active = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.08)
              : (isDark ? Colors.grey[850] : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(6),
          border: active
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active
                ? AppColors.primary
                : (isDark ? Colors.grey[300] : Colors.grey[800]),
          ),
        ),
      ),
    );
  }

  Widget _buildIndexHeaderCard(String label, double price, double change, double pct, bool isDark) {
    final isPos = change >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isPos ? Icons.trending_up : Icons.trending_down, color: isPos ? AppColors.green : AppColors.red, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            '${isPos ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPos ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================== TABS 2: WATCHLIST ========================
class _WatchlistView extends StatefulWidget {
  const _WatchlistView();

  @override
  State<_WatchlistView> createState() => _WatchlistViewState();
}

class _WatchlistViewState extends State<_WatchlistView> {
  final _searchController = TextEditingController();
  var _isSearching = false.obs;
  var _searchResults = <dynamic>[].obs;
  var _searchLoading = false.obs;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      return;
    }
    try {
      _searchLoading.value = true;
      final results = await Get.find<DashboardController>().tradeRepository.searchStocks(query);
      _searchResults.value = results;
    } catch (_) {
    } finally {
      _searchLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Watchlists',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),

          // Search Box
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: TextFormField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search & Add stocks to Watchlist',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: Obx(() {
                  return _isSearching.value
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _isSearching.value = false;
                            _searchResults.clear();
                          },
                        )
                      : const SizedBox();
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (val) {
                _isSearching.value = val.trim().isNotEmpty;
                _performSearch(val);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Search overlay list
          Obx(() {
            if (!_isSearching.value) return const SizedBox();
            if (_searchLoading.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppColors.primary)));
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                itemBuilder: (context, index) {
                  final item = _searchResults[index];
                  return ListTile(
                    title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.companyName),
                    trailing: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                    onTap: () {
                      controller.watchlistStocks.add(item);
                      _searchController.clear();
                      _isSearching.value = false;
                      _searchResults.clear();
                      Get.snackbar('Watchlist Updated', 'Added ${item.symbol} to your Watchlist.');
                    },
                  );
                },
              ),
            );
          }),

          // Watchlisted list items
          Obx(() {
            final list = controller.watchlistStocks;
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Text('Your watchlist is empty.', style: TextStyle(color: Colors.grey[500])),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                itemBuilder: (context, index) {
                  final item = list[index];
                  final isPos = item.changePercent >= 0;

                  return Dismissible(
                    key: Key(item.symbol),
                    background: Container(
                      color: AppColors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      controller.watchlistStocks.removeAt(index);
                      Get.snackbar('Removed', 'Removed ${item.symbol} from Watchlist.');
                    },
                    child: ListTile(
                      title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5)),
                      subtitle: Text(item.companyName, style: const TextStyle(fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5)),
                          Text(
                            '${isPos ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isPos ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.find<StockDetailController>().initialize(item.symbol);
                        Get.toNamed(RouteHelper.stockDetail, arguments: item.symbol);
                      },
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ======================== TABS 3: PORTFOLIO VIEW ========================
class _PortfolioView extends StatelessWidget {
  const _PortfolioView();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => controller.loadPortfolioDetails(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Wealth Portfolio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Portfolio net worth card
            Obx(() {
              final invested = controller.totalInvested.value;
              final current = controller.currentValue.value;
              final pl = controller.totalPL.value;
              final roi = controller.totalROI.value;
              final isProfit = pl >= 0;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat('INVESTED VALUE', '₹${invested.toStringAsFixed(2)}', isDark),
                        _buildStat('CURRENT VALUE', '₹${current.toStringAsFixed(2)}', isDark),
                      ],
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Portfolio P&L',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        Text(
                          '${isProfit ? '+' : ''}₹${pl.toStringAsFixed(2)} (${roi.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isProfit ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Holdings List (Only Stocks)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Holding Assets',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Obx(() => Text('${controller.holdings.length} Equities', style: const TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
            const SizedBox(height: 12),

            Obx(() {
              final list = controller.holdings;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text('No shares in holdings yet.', style: TextStyle(color: Colors.grey[500])),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final isProfit = item.profitLoss >= 0;

                    return ListTile(
                      title: Text(item.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.quantity.toInt()} Qty • Avg ₹${item.avgBuyPrice.toStringAsFixed(2)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${item.totalValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${isProfit ? '+' : ''}₹${item.profitLoss.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isProfit ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.find<StockDetailController>().initialize(item.symbol);
                        Get.toNamed(RouteHelper.stockDetail, arguments: item.symbol);
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String val, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}

// ======================== TABS 4: ORDERS VIEW (Exact Dhan Style) ========================
class _OrdersView extends StatelessWidget {
  final VoidCallback? onSearchTap;
  const _OrdersView({this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _DhanHeader(onSearchTap: onSearchTap),
          // Tabs row: Positions, Orders, Super, Flash
          Container(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Positions'),
                Tab(text: 'Orders'),
                Tab(text: 'Super'),
                Tab(text: 'Flash'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // SUB-TAB: POSITIONS
                _buildPositionsListTab(controller, isDark),
                // SUB-TAB: ORDERS LIST (Active + History)
                _buildActiveOrdersTab(controller, isDark),
                _buildPlaceholderTab('Super-Fast Trading Actions Workspace', isDark),
                _buildPlaceholderTab('Flash Scalper Workspace Mode under development', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsListTab(PortfolioController controller, bool isDark) {
    return Column(
      children: [
        // Overall P&L header bar
        Obx(() {
          final pl = controller.totalPL.value;
          final count = controller.holdings.length + controller.positions.length;
          final isProfit = pl >= 0;
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overall P&L', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(
                  '₹${pl.toStringAsFixed(2)} on $count positions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
            ),
          );
        }),

        Expanded(
          child: Obx(() {
            final activePos = controller.positions;
            if (activePos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Colors.grey[400], size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No Positions Today',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'P&L for your Open Positions will appear here',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        // Triggers search action
                      },
                      child: const Text('Search to Place Order', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: activePos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pos = activePos[index];
                final isBuy = pos.orderSide == '1';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(pos.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isBuy ? AppColors.green : AppColors.red).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isBuy ? 'BUY' : 'SELL',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isBuy ? AppColors.green : AppColors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${pos.quantity.toInt()} Qty • Rate ₹${pos.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => controller.cancelPositionOrder(pos.id),
                        child: const Text('EXIT', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActiveOrdersTab(PortfolioController controller, bool isDark) {
    return Obx(() {
      final trades = controller.trades;
      if (trades.isEmpty) {
        return Center(
          child: Text('No orders logs available today.', style: TextStyle(color: Colors.grey[500])),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: trades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = trades[index];
          final isBuy = t.orderSide == '1';
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(t.symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isBuy ? AppColors.green : AppColors.red).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuy ? 'BUY' : 'SELL',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isBuy ? AppColors.green : AppColors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${t.quantity.toInt()} Qty • Price ₹${t.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Text(
                  t.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: t.status == 'completed' ? AppColors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildPlaceholderTab(String text, bool isDark) {
    return Center(
      child: Text(text, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
    );
  }
}

// ======================== TABS 5: MONEY / WALLET VIEW ========================
class _MoneyView extends StatefulWidget {
  const _MoneyView();

  @override
  State<_MoneyView> createState() => _MoneyViewState();
}

class _MoneyViewState extends State<_MoneyView> {
  final _amountController = TextEditingController(text: '1000000');
  var _isLoading = false.obs;

  Future<void> _resetPortfolio() async {
    final controller = Get.find<AuthController>();
    final dashboardCtrl = Get.find<DashboardController>();
    final portfolioCtrl = Get.find<PortfolioController>();
    
    try {
      _isLoading.value = true;
      final response = await dashboardCtrl.tradeRepository.apiClient.post(
        '/api/admin/reset_user',
        data: {'email': controller.user.value?.email ?? 'admin@trading.ai'},
      );
      if (response.data['status'] == 'ok') {
        Get.snackbar('Success', 'Portfolio assets & balance reset successfully!', backgroundColor: AppColors.green.withOpacity(0.9), colorText: Colors.white);
        dashboardCtrl.loadDashboardData();
        portfolioCtrl.loadPortfolioDetails();
      }
    } catch (e) {
      Get.snackbar('Error', 'Reset failed: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateBalance() async {
    final dashboardCtrl = Get.find<DashboardController>();
    final portfolioCtrl = Get.find<PortfolioController>();
    final double amount = double.tryParse(_amountController.text) ?? 1000000.0;
    
    try {
      _isLoading.value = true;
      final response = await dashboardCtrl.tradeRepository.apiClient.post(
        '/api/admin/configure_wallet',
        data: {'amount': amount},
      );
      if (response.data['status'] == 'ok') {
        Get.snackbar('Success', 'Initial wallet balance set to ₹${amount.toStringAsFixed(2)}', backgroundColor: AppColors.green.withOpacity(0.9), colorText: Colors.white);
        dashboardCtrl.loadDashboardData();
        portfolioCtrl.loadPortfolioDetails();
      }
    } catch (e) {
      Get.snackbar('Error', 'Configuration failed: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => controller.loadDashboardData(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Virtual Wallet Insights',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic Balance Card
            Obx(() {
              final bal = controller.balance.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), AppColors.surfaceDark]
                        : [Colors.white, const Color(0xFFF1F5F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE VIRTUAL BALANCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${bal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This balance is virtual, only for paper trading practice.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Admin config actions (only if user is logged in as admin)
            Text(
              'Reset & Configuration Console',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Set Initial Balance amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'e.g. 1000000',
                            filled: true,
                            fillColor: isDark ? AppColors.bgDark : AppColors.bgLight,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        return ElevatedButton(
                          onPressed: _isLoading.value ? null : _updateBalance,
                          child: const Text('Update'),
                        );
                      }),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('Reset user transactions and restore starting balance:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: _isLoading.value ? null : _resetPortfolio,
                        child: _isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('RESET SYSTEM PORTFOLIO', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Account Logout preferences
            Text(
              'Preferences & Security',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: const Text('Dark Mode Toggle'),
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        Get.changeTheme(val ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  authCtrl.logout();
                },
                child: const Text('Log Out Session', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SUB-TAB: OPTIONS (Dhan Style)
class _OptionsSubTab extends StatefulWidget {
  const _OptionsSubTab();

  @override
  State<_OptionsSubTab> createState() => _OptionsSubTabState();
}

class _OptionsSubTabState extends State<_OptionsSubTab> {
  String _selectedSegment = 'Index'; // Toggle: 'Index' | 'Stocks'
  String _selectedIndexPill = 'Sensex'; // Index Pills: 'Sensex' | 'Nifty 50' | 'BSE BANKEX' | 'Finnifty'
  String _selectedStockPill = 'RELIANCE'; // Stock Options Pills: 'RELIANCE' | 'TCS' | 'INFY' | 'HDFCBANK'

  // Standard Mock Option Contracts
  List<Map<String, dynamic>> _getOptionContracts() {
    if (_selectedSegment == 'Index') {
      if (_selectedIndexPill == 'Sensex') {
        return [
          {'symbol': 'SENSEX 04 JUN 74400 CALL', 'exchange': 'BSE', 'price': 0.10, 'change': -370.90, 'changePct': -99.97},
          {'symbol': 'SENSEX 04 JUN 74500 CALL', 'exchange': 'BSE', 'price': 0.15, 'change': -321.70, 'changePct': -99.95},
          {'symbol': 'SENSEX 04 JUN 74300 PUT', 'exchange': 'BSE', 'price': 0.10, 'change': -249.80, 'changePct': -99.96},
          {'symbol': 'SENSEX 04 JUN 74000 PUT', 'exchange': 'BSE', 'price': 0.05, 'change': -150.90, 'changePct': -99.97},
          {'symbol': 'SENSEX 04 JUN 74200 PUT', 'exchange': 'BSE', 'price': 0.10, 'change': -212.40, 'changePct': -99.95},
        ];
      } else if (_selectedIndexPill == 'Nifty 50') {
        return [
          {'symbol': 'NIFTY 04 JUN 23400 CALL', 'exchange': 'NSE', 'price': 85.40, 'change': -45.20, 'changePct': -34.61},
          {'symbol': 'NIFTY 04 JUN 23450 CALL', 'exchange': 'NSE', 'price': 55.20, 'change': -62.10, 'changePct': -52.94},
          {'symbol': 'NIFTY 04 JUN 23350 PUT', 'exchange': 'NSE', 'price': 92.15, 'change': 22.30, 'changePct': 31.93},
          {'symbol': 'NIFTY 04 JUN 23300 PUT', 'exchange': 'NSE', 'price': 68.50, 'change': 12.40, 'changePct': 22.10},
          {'symbol': 'NIFTY 04 JUN 23500 CALL', 'exchange': 'NSE', 'price': 32.10, 'change': -58.00, 'changePct': -64.37},
        ];
      } else if (_selectedIndexPill == 'BSE BANKEX') {
        return [
          {'symbol': 'BANKEX 04 JUN 53200 CALL', 'exchange': 'BSE', 'price': 12.50, 'change': -145.30, 'changePct': -92.08},
          {'symbol': 'BANKEX 04 JUN 53300 CALL', 'exchange': 'BSE', 'price': 5.40, 'change': -182.10, 'changePct': -97.12},
          {'symbol': 'BANKEX 04 JUN 53100 PUT', 'exchange': 'BSE', 'price': 24.80, 'change': 5.20, 'changePct': 26.53},
          {'symbol': 'BANKEX 04 JUN 53000 PUT', 'exchange': 'BSE', 'price': 14.10, 'change': 2.10, 'changePct': 17.50},
        ];
      } else { // Finnifty
        return [
          {'symbol': 'FINNIFTY 04 JUN 21400 CALL', 'exchange': 'NSE', 'price': 3.40, 'change': -45.10, 'changePct': -92.99},
          {'symbol': 'FINNIFTY 04 JUN 21450 CALL', 'exchange': 'NSE', 'price': 1.25, 'change': -58.20, 'changePct': -97.90},
          {'symbol': 'FINNIFTY 04 JUN 21350 PUT', 'exchange': 'NSE', 'price': 8.90, 'change': 1.40, 'changePct': 18.67},
          {'symbol': 'FINNIFTY 04 JUN 21300 PUT', 'exchange': 'NSE', 'price': 4.20, 'change': 0.30, 'changePct': 7.69},
        ];
      }
    } else { // Stocks Option contracts
      if (_selectedStockPill == 'RELIANCE') {
        return [
          {'symbol': 'RELIANCE 25 JUN 2900 CALL', 'exchange': 'NSE', 'price': 45.30, 'change': -12.50, 'changePct': -21.63},
          {'symbol': 'RELIANCE 25 JUN 2950 CALL', 'exchange': 'NSE', 'price': 24.10, 'change': -18.20, 'changePct': -43.03},
          {'symbol': 'RELIANCE 25 JUN 2850 PUT', 'exchange': 'NSE', 'price': 52.40, 'change': 8.60, 'changePct': 19.64},
          {'symbol': 'RELIANCE 25 JUN 2800 PUT', 'exchange': 'NSE', 'price': 31.25, 'change': 3.40, 'changePct': 12.19},
        ];
      } else if (_selectedStockPill == 'TCS') {
        return [
          {'symbol': 'TCS 25 JUN 3800 CALL', 'exchange': 'NSE', 'price': 72.10, 'change': -8.40, 'changePct': -10.43},
          {'symbol': 'TCS 25 JUN 3700 PUT', 'exchange': 'NSE', 'price': 64.30, 'change': 12.50, 'changePct': 24.13},
        ];
      } else if (_selectedStockPill == 'INFY') {
        return [
          {'symbol': 'INFY 25 JUN 1500 CALL', 'exchange': 'NSE', 'price': 28.40, 'change': -4.20, 'changePct': -12.88},
          {'symbol': 'INFY 25 JUN 1450 PUT', 'exchange': 'NSE', 'price': 35.10, 'change': 6.20, 'changePct': 21.45},
        ];
      } else { // HDFCBANK
        return [
          {'symbol': 'HDFCBANK 25 JUN 1600 CALL', 'exchange': 'NSE', 'price': 32.50, 'change': -2.10, 'changePct': -6.07},
          {'symbol': 'HDFCBANK 25 JUN 1550 PUT', 'exchange': 'NSE', 'price': 41.80, 'change': 4.30, 'changePct': 11.47},
        ];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• Live Markets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),

          // Live Markets Cards with Option Expiries
          Obx(() {
            final List<Map<String, dynamic>> displayConfigs = [
              {
                'symbol': 'NIFTY',
                'name': 'Nifty 50',
                'defaultPrice': 23416.10,
                'defaultChange': 9.50,
                'defaultPct': 0.04,
                'hasExpiry': false,
              },
              {
                'symbol': 'SENSEX',
                'name': 'Sensex',
                'defaultPrice': 74363.50,
                'defaultChange': 15.20,
                'defaultPct': 0.02,
                'hasExpiry': true,
              },
              {
                'symbol': 'BANKNIFTY',
                'name': 'Nifty Bank',
                'defaultPrice': 52800.00,
                'defaultChange': 120.50,
                'defaultPct': 0.23,
                'hasExpiry': false,
              },
              {
                'symbol': 'FINNIFTY',
                'name': 'Fin Nifty',
                'defaultPrice': 21380.20,
                'defaultChange': -45.10,
                'defaultPct': -0.21,
                'hasExpiry': false,
              },
              {
                'symbol': 'MIDCPNIFTY',
                'name': 'Midcap Nifty',
                'defaultPrice': 12150.80,
                'defaultChange': 55.10,
                'defaultPct': 0.45,
                'hasExpiry': false,
              },
            ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: displayConfigs.map((cfg) {
                  final matched = controller.indices.firstWhereOrNull((item) => item.symbol == cfg['symbol']);
                  final ltp = matched?.price ?? cfg['defaultPrice'];
                  final change = matched?.change ?? cfg['defaultChange'];
                  final pct = matched?.changePercent ?? cfg['defaultPct'];
                  final isPos = change >= 0;
                  final isExpiry = cfg['hasExpiry'] as bool;

                  return GestureDetector(
                    onTap: () {
                      Get.find<StockDetailController>().initialize(cfg['symbol']);
                      Get.toNamed(RouteHelper.stockDetail, arguments: cfg['symbol']);
                    },
                    child: Container(
                      width: 145,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      isPos ? Icons.trending_up : Icons.trending_down,
                                      color: isPos ? AppColors.green : AppColors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        cfg['name'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isExpiry)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF332010) : const Color(0xFFFFF2E6),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFFD9B3), width: 0.5),
                                  ),
                                  child: const Text(
                                    'Expiry',
                                    style: TextStyle(color: Color(0xFFFF8000), fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ltp.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${isPos ? '+' : ''}${change.toStringAsFixed(2)} (${isPos ? '+' : ''}${pct.toStringAsFixed(2)}%)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isPos ? AppColors.green : AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Discover Options / Top Traded Header
          const Text(
            'Top Traded Options',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5),
          ),
          const SizedBox(height: 14),

          // Index / Stocks Segment toggle styled like folder tabs
          Row(
            children: [
              _buildSegmentTab('Index'),
              _buildSegmentTab('Stocks'),
            ],
          ),

          // Option filter pills and contract list box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal scroll filter pills row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Overlapping CE/PE Icon representation box
                        Container(
                          width: 32,
                          height: 28,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                left: 0,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7E6),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFFD580), width: 0.5),
                                  ),
                                  child: const Text('CE', style: TextStyle(color: Color(0xFFE68A00), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFD8B4FE), width: 0.5),
                                  ),
                                  child: const Text('PE', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Render Option Pills
                        if (_selectedSegment == 'Index') ...[
                          _buildOptionPill('Sensex'),
                          _buildOptionPill('Nifty 50'),
                          _buildOptionPill('BSE BANKEX'),
                          _buildOptionPill('Finnifty'),
                        ] else ...[
                          _buildOptionPill('RELIANCE'),
                          _buildOptionPill('TCS'),
                          _buildOptionPill('INFY'),
                          _buildOptionPill('HDFCBANK'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),

                // Option contracts list view
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getOptionContracts().length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppColors.borderDark.withOpacity(0.5) : AppColors.borderLight.withOpacity(0.5)),
                  itemBuilder: (context, idx) {
                    final item = _getOptionContracts()[idx];
                    final isPos = item['change'] >= 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        item['symbol'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.2),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item['exchange'],
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['price'].toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isPos ? '+' : ''}${item['change'].toStringAsFixed(2)} (${item['changePct'].toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isPos ? AppColors.green : AppColors.red,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                isPos ? Icons.trending_up : Icons.trending_down,
                                size: 10,
                                color: isPos ? AppColors.green : AppColors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Get.find<StockDetailController>().initialize(item['symbol']);
                        Get.toNamed(RouteHelper.stockDetail, arguments: item['symbol']);
                      },
                    );
                  },
                ),

                // Top 100 Traded Contracts footer
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Color chart representation
                          Row(
                            children: [
                              Container(width: 4, height: 16, color: Colors.green),
                              const SizedBox(width: 2),
                              Container(width: 4, height: 20, color: Colors.blue),
                              const SizedBox(width: 2),
                              Container(width: 4, height: 12, color: Colors.orange),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Top 100 Traded Contracts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.play_circle_fill_rounded, color: Colors.orange[400], size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Segment Tab Selector ('Index' or 'Stocks')
  Widget _buildSegmentTab(String label) {
    final active = _selectedSegment == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : (isDark ? Colors.grey[900] : const Color(0xFFEEEEEE)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          border: active
              ? Border(
                  top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                  left: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                  right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey[600] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  // Option pill selector
  Widget _buildOptionPill(String label) {
    final active = (_selectedSegment == 'Index') ? (_selectedIndexPill == label) : (_selectedStockPill == label);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dhan active selection has amber border and amber background tint
    final activeBg = isDark ? const Color(0xFF2C2210) : const Color(0xFFFFFDF0);
    final activeBorder = const Color(0xFFE6A100);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedSegment == 'Index') {
            _selectedIndexPill = label;
          } else {
            _selectedStockPill = label;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? activeBg
              : (isDark ? Colors.transparent : Colors.transparent),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? activeBorder : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: active ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active
                ? activeBorder
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
