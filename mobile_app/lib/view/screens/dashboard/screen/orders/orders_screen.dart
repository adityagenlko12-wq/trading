import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/data/services/api_service.dart';
import 'package:vinance/data/controller/dashbaord/dashboard_controller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient apiClient = Get.find();
  bool isLoading = true;
  
  Map<String, dynamic> stats = {};
  List<dynamic> openPositions = [];
  List<dynamic> historicalTrades = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchTradingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchTradingData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}virtual_trades',
        Method.getMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.responseJson);
        setState(() {
          stats = data['stats'] ?? {};
          openPositions = data['open_trades'] ?? [];
          historicalTrades = data['recent_trades'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching virtual trades: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> closePosition(int tradeId) async {
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}close_trade/$tradeId',
        Method.postMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        fetchTradingData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Position exited successfully!"),
            backgroundColor: MyColor.primaryColor500,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error closing position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double overallPnl = 0.0;
    try {
      overallPnl = double.parse(stats['overall_pnl']?.toString() ?? '0.0');
    } catch (_) {}
    
    final isBullish = overallPnl >= 0;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Orders & Positions",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchTradingData,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // P&L Header card (screenshot 4 style)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xfffcfdfe),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Overall P&L",
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${isBullish ? '₹' : '-₹'}${overallPnl.abs().toStringAsFixed(2)} on ${openPositions.length} positions",
                      style: TextStyle(
                        color: isBullish ? MyColor.primaryColor500 : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: MyColor.primaryColor500,
                indicatorWeight: 3,
                labelColor: MyColor.primaryColor500,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Positions"),
                  Tab(text: "Orders"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: MyColor.primaryColor500))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPositionsTab(),
                _buildOrdersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyColor.primaryColor500,
        onPressed: () {
          // Switch to Watchlist tab to search & place order
          final dashboard = Get.find<DashboardController>();
          dashboard.changeSelectedIndex(1);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPositionsTab() {
    if (openPositions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_outline, size: 70, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "No Positions Today",
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "P&L for your Open Positions will appear here",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xffd1d5db)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  final dashboard = Get.find<DashboardController>();
                  dashboard.changeSelectedIndex(1); // Go to Watchlist to search
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Search to Place Order", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: openPositions.length,
      itemBuilder: (context, index) {
        final pos = openPositions[index];
        final id = pos['id'] ?? 0;
        final symbol = pos['symbol'] ?? '';
        final type = pos['type'] ?? 'STOCK';
        final signalType = pos['signal_type'] ?? 'BUY';
        final entryPrice = pos['entry_price'] ?? 0.0;
        final currentPrice = pos['current_premium'] ?? entryPrice;
        final qty = pos['quantity'] ?? 1;
        final pnl = pos['current_pnl'] ?? 0.0;
        final isBullish = pnl >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: signalType.contains('BUY') || signalType.contains('CALL') 
                            ? const Color(0xffe6fbf2) 
                            : const Color(0xfffdf2f2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        signalType,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: signalType.contains('BUY') || signalType.contains('CALL') 
                              ? MyColor.primaryColor500 
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    "Qty: $qty | Avg: ₹${entryPrice.toStringAsFixed(2)} | LTP: ₹${currentPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                trailing: Text(
                  "${isBullish ? '+' : ''}₹${pnl.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isBullish ? MyColor.primaryColor500 : Colors.red,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.exit_to_app, size: 16, color: Colors.red),
                      label: const Text("Exit Position", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                      onPressed: () => _confirmExit(id, symbol),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    if (historicalTrades.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description_outlined, size: 70, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "No Orders Today",
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Orders placed for the day will appear here",
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: historicalTrades.length,
      itemBuilder: (context, index) {
        final trade = historicalTrades[index];
        final symbol = trade['symbol'] ?? '';
        final type = trade['type'] ?? 'STOCK';
        final signalType = trade['signal_type'] ?? 'BUY';
        final entry = trade['entry_price'] ?? 0.0;
        final exit = trade['exit_price'] ?? 0.0;
        final qty = trade['quantity'] ?? 1;
        final pnl = trade['pnl'] ?? 0.0;
        final status = trade['status'] ?? 'CLOSED';
        final isWin = pnl >= 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'TARGET_HIT' 
                        ? const Color(0xffe6fbf2) 
                        : status == 'SL_HIT' 
                            ? const Color(0xfffdf2f2) 
                            : const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: status == 'TARGET_HIT' 
                          ? MyColor.primaryColor500 
                          : status == 'SL_HIT' 
                              ? Colors.red 
                              : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Qty: $qty | Buy: ₹${entry.toStringAsFixed(2)} | Sell: ₹${exit.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            trailing: Text(
              "${isWin ? '+' : ''}₹${pnl.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isWin ? MyColor.primaryColor500 : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmExit(int tradeId, String symbol) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Exit"),
          content: Text("Do you want to manually exit position for $symbol at market price?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Exit", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                closePosition(tradeId);
              },
            ),
          ],
        );
      },
    );
  }
}
