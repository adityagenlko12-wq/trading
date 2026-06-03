import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/data/controller/dashbaord/dashboard_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient apiClient = Get.find();

  bool isIndicesLoading = true;
  bool isStocksLoading = true;

  String userName = '';

  // All indices data
  List<Map<String, dynamic>> allIndices = [];

  // Trending stocks
  List<dynamic> trendingStocks = [];

  // Auto-refresh timer
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    userName = apiClient.getCurrencyOrUsername(isCurrency: false);
    if (userName.trim().isEmpty) {
      userName = "Trader";
    }

    fetchAllIndices();
    fetchTrendingStocks();

    // Refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchAllIndices();
      fetchTrendingStocks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAllIndices() async {
    setState(() => isIndicesLoading = true);
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}indices/quotes',
        Method.getMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.responseJson);
        setState(() {
          allIndices = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching indices: $e");
    } finally {
      setState(() => isIndicesLoading = false);
    }
  }

  Future<void> fetchTrendingStocks() async {
    setState(() => isStocksLoading = true);
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}stock/quote/HINDZINC,IDEA,TATACONSUM,RELIANCE,TCS',
        Method.getMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.responseJson);
        setState(() => trendingStocks = data);
      }
    } catch (e) {
      debugPrint("Error fetching trending stocks: $e");
    } finally {
      setState(() => isStocksLoading = false);
    }
  }

  Future<void> refreshAllData() async {
    await Future.wait([fetchAllIndices(), fetchTrendingStocks()]);
  }

  // Helper to safely parse a double from any type
  double _parseDouble(dynamic val, [double fallback = 0.0]) =>
      double.tryParse(val?.toString() ?? '') ?? fallback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: MyColor.primaryColor500.withValues(alpha: 0.1),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                style: const TextStyle(color: MyColor.primaryColor500, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dhan",
                  style: TextStyle(color: MyColor.primaryColor500, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  "Hello, $userName",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              final dashboard = Get.find<DashboardController>();
              dashboard.changeSelectedIndex(1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: refreshAllData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: MyColor.primaryColor500,
          indicatorWeight: 3,
          labelColor: MyColor.primaryColor500,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: "Home"),
            Tab(text: "Stocks"),
            Tab(text: "Options"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildStocksTab(),
          _buildOptionsTab(),
        ],
      ),
    );
  }

  // ─── HOME TAB ─────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    // Use first index (NIFTY) for the hero banner, fallback to defaults
    final hero = allIndices.isNotEmpty ? allIndices.first : <String, dynamic>{};
    final heroLtp    = _parseDouble(hero['ltp'], 24500.0);
    final heroChange = _parseDouble(hero['day_change'], 120.5);
    final heroPct    = _parseDouble(hero['percentage_change'], 0.49);
    final heroSym    = hero['display_name'] ?? 'NIFTY 50';
    final heroUp     = heroChange >= 0;

    return RefreshIndicator(
      onRefresh: refreshAllData,
      color: MyColor.primaryColor500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Banner ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColor.primaryColor500, MyColor.primaryColor600.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello $userName,",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Invest and Trade seamlessly today!",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Icon(Icons.rocket_launch, color: Colors.white, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Hero Index Card (tappable) ──
            GestureDetector(
              onTap: () => Get.toNamed(
                RouteHelper.tradeBuySellScreen,
                arguments: [hero['symbol'] ?? 'NIFTY', 'buy'],
                preventDuplicates: true,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: isIndicesLoading
                    ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: MyColor.primaryColor500)))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(heroSym, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(hero['exchange'] ?? 'NSE INDEX', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "₹${heroLtp.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${heroUp ? '+' : ''}${heroChange.toStringAsFixed(2)} (${heroPct.toStringAsFixed(2)}%)",
                                style: TextStyle(color: heroUp ? MyColor.primaryColor500 : Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Quick Actions ──
            const Text("QUICK TRANSACTIONS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionItem("ETFs", Icons.pie_chart, Colors.purple),
                _buildQuickActionItem("Commodities", Icons.waves, Colors.orange),
                _buildQuickActionItem("Gold Vault", Icons.wallet_giftcard, Colors.amber),
                _buildQuickActionItem("Futures", Icons.trending_up, Colors.blue),
              ],
            ),
            const SizedBox(height: 24),

            // ── Special Services ──
            const Text("SPECIAL SERVICES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _buildGridActionItem("Scalper Desk", Icons.bolt, const Color(0xff00b050)),
                _buildGridActionItem("Live Charts", Icons.show_chart, Colors.blueAccent),
                _buildGridActionItem("Flash Trade", Icons.flash_on, Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  Widget _buildGridActionItem(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // ─── STOCKS TAB ───────────────────────────────────────────────────────────
  Widget _buildStocksTab() {
    return RefreshIndicator(
      onRefresh: refreshAllData,
      color: MyColor.primaryColor500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── All Indices Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Market Indices", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                if (!isIndicesLoading)
                  Text(
                    "${allIndices.length} indices",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            isIndicesLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: MyColor.primaryColor500)))
                : allIndices.isEmpty
                    ? _buildEmptyState("No index data available", Icons.show_chart)
                    : _buildAllIndicesGrid(),

            const SizedBox(height: 24),

            // ── Trending Stocks ──
            const Text("Discover Stocks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 4),
            const Text("Trending on Dhan", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),

            isStocksLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: MyColor.primaryColor500)))
                : trendingStocks.isEmpty
                    ? _buildEmptyState("No stocks data available", Icons.bar_chart)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: trendingStocks.length,
                        itemBuilder: (context, index) {
                          final stock = trendingStocks[index];
                          final symbol = stock['symbol'] ?? '';
                          final companyName = stock['company_name'] ?? symbol;
                          final double price = _parseDouble(stock['ltp'] ?? stock['last_price']);
                          final double pct = _parseDouble(stock['percentage_change'] ?? stock['change_percent']);
                          final isBullish = pct >= 0;

                          return GestureDetector(
                            onTap: () => _showTradeBottomSheet(stock),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: (isBullish ? MyColor.primaryColor500 : Colors.red).withValues(alpha: 0.1),
                                  child: Text(
                                    symbol.isNotEmpty ? symbol[0] : '?',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: isBullish ? MyColor.primaryColor500 : Colors.red),
                                  ),
                                ),
                                title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: Text(companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("₹${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isBullish ? MyColor.primaryColor500 : Colors.red).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${isBullish ? '+' : ''}${pct.toStringAsFixed(2)}%",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isBullish ? MyColor.primaryColor500 : Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  // Grid of all indices cards (2 per row)
  Widget _buildAllIndicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allIndices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, i) {
        final idx = allIndices[i];
        final symbol   = idx['symbol'] ?? '';
        final dispName = idx['display_name'] ?? symbol;
        final exchange = idx['exchange'] ?? '';
        final ltp      = _parseDouble(idx['ltp']);
        final change   = _parseDouble(idx['day_change']);
        final pct      = _parseDouble(idx['percentage_change']);
        final isUp     = change >= 0;
        final isLive   = idx['is_live'] == true;

        return GestureDetector(
          onTap: () => Get.toNamed(
            RouteHelper.tradeBuySellScreen,
            arguments: [symbol, 'buy'],
            preventDuplicates: true,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dispName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                        child: const Text("~", style: TextStyle(fontSize: 9, color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                Text(
                  exchange,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ltp >= 1000
                          ? "₹${(ltp / 1000).toStringAsFixed(2)}K"
                          : "₹${ltp.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${isUp ? '+' : ''}${change.toStringAsFixed(1)} (${pct.toStringAsFixed(2)}%)",
                      style: TextStyle(color: isUp ? MyColor.primaryColor500 : Colors.red, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ─── OPTIONS TAB ──────────────────────────────────────────────────────────
  Widget _buildOptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indices Option Chains
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.layers, color: MyColor.primaryColor500),
                    SizedBox(width: 8),
                    Text("Indices Option Chains", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                // Dynamically build rows from allIndices; fallback to hardcoded list
                ...(_buildOptionChainRows()),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Popular Options Contracts
          const Text("POPULAR OPTIONS CONTRACTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe6fbf2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: MyColor.primaryColor500),
                    ),
                  ),
                  onPressed: () => Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: ['NIFTY', 'buy'], preventDuplicates: true),
                  child: const Text("NIFTY CALL", style: TextStyle(color: MyColor.primaryColor500, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffdf2f2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onPressed: () => Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: ['NIFTY', 'sell'], preventDuplicates: true),
                  child: const Text("NIFTY PUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe6fbf2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: MyColor.primaryColor500),
                    ),
                  ),
                  onPressed: () => Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: ['BANKNIFTY', 'buy'], preventDuplicates: true),
                  child: const Text("BANKNIFTY CALL", style: TextStyle(color: MyColor.primaryColor500, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfffdf2f2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  onPressed: () => Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: ['BANKNIFTY', 'sell'], preventDuplicates: true),
                  child: const Text("BANKNIFTY PUT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptionChainRows() {
    // If we have live index data, build dynamic rows
    final List<Map<String, dynamic>> targets = allIndices.isNotEmpty
        ? allIndices
        : [
            {"symbol": "NIFTY",     "display_name": "NIFTY 50"},
            {"symbol": "BANKNIFTY", "display_name": "BANK NIFTY"},
            {"symbol": "SENSEX",    "display_name": "SENSEX"},
            {"symbol": "FINNIFTY",  "display_name": "FIN NIFTY"},
          ];

    final rows = <Widget>[];
    for (int i = 0; i < targets.length; i++) {
      if (i > 0) rows.add(const Divider(height: 1));
      final t = targets[i];
      rows.add(_buildOptionChainLinkRow(t['display_name'] ?? t['symbol'], t['symbol'] ?? ''));
    }
    return rows;
  }

  Widget _buildOptionChainLinkRow(String title, String param) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColor.primaryColor500,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: [param, 'buy'], preventDuplicates: true),
            child: const Text("Trade Chain", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTradeBottomSheet(dynamic stock) {
    final symbol = stock['symbol'] ?? '';
    final name   = stock['company_name'] ?? symbol;
    final double ltp = _parseDouble(stock['ltp'] ?? stock['last_price']);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(name, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Text("LTP: ₹${ltp.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.primaryColor500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: [symbol, 'buy'], preventDuplicates: true);
                    },
                    child: const Text("BUY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.toNamed(RouteHelper.tradeBuySellScreen, arguments: [symbol, 'sell'], preventDuplicates: true);
                    },
                    child: const Text("SELL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
