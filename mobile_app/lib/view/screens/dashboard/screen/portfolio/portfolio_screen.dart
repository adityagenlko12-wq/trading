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

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ApiClient apiClient = Get.find();
  bool isLoading = true;
  
  Map<String, dynamic> stats = {};
  List<dynamic> holdings = [];

  @override
  void initState() {
    super.initState();
    fetchPortfolioData();
  }

  Future<void> fetchPortfolioData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}portfolio',
        Method.getMethod,
        null,
        passHeader: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.responseJson);
        setState(() {
          stats = data['stats'] ?? {};
          holdings = data['holdings'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching portfolio: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalInvested = 0.0;
    double currentVal = 0.0;
    double overallPnl = 0.0;

    for (var h in holdings) {
      final double avg = double.tryParse(h['average_price']?.toString() ?? '0.0') ?? 0.0;
      final int qty = int.tryParse(h['quantity']?.toString() ?? '0') ?? 0;
      final double currentLtp = avg * 1.02; // LTP estimation matching backend dashboard estimation
      
      totalInvested += qty * avg;
      currentVal += qty * currentLtp;
    }
    overallPnl = currentVal - totalInvested;
    final double pnlPercent = totalInvested > 0 ? (overallPnl / totalInvested) * 100 : 0.0;
    final isBullish = overallPnl >= 0;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Portfolio",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchPortfolioData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: MyColor.primaryColor500))
          : RefreshIndicator(
              onRefresh: fetchPortfolioData,
              color: MyColor.primaryColor500,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Portfolio Summary Header Card (Dhan style Premium card)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isBullish 
                              ? [const Color(0xff00b050), const Color(0xff008b3f)] 
                              : [const Color(0xffe15252), const Color(0xffc93b3b)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isBullish ? const Color(0xff00b050) : const Color(0xffe15252)).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Value",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${currentVal.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Invested Value", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text("₹${totalInvested.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Overall P&L", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isBullish ? Icons.arrow_upward : Icons.arrow_downward,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${isBullish ? '+' : ''}₹${overallPnl.abs().toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(2)}%)",
                                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Holdings List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Holdings (${holdings.length})",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    if (holdings.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: holdings.length,
                        itemBuilder: (context, index) {
                          final h = holdings[index];
                          final symbol = h['symbol'] ?? '';
                          final name = h['company_name'] ?? symbol;
                          final qty = int.tryParse(h['quantity']?.toString() ?? '0') ?? 0;
                          final avg = double.tryParse(h['average_price']?.toString() ?? '0.0') ?? 0.0;
                          final currentLtp = avg * 1.02; // Seeded estimation
                          
                          final investedVal = qty * avg;
                          final holdingVal = qty * currentLtp;
                          final itemPnl = holdingVal - investedVal;
                          final itemPnlPercent = avg > 0 ? (itemPnl / investedVal) * 100 : 0.0;
                          final isItemBullish = itemPnl >= 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.01),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showHoldingActionSheet(h),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  symbol,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "₹${holdingVal.toStringAsFixed(2)}",
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${isItemBullish ? '+' : ''}${itemPnlPercent.toStringAsFixed(2)}%",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isItemBullish ? MyColor.primaryColor500 : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Qty", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text("$qty", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Avg Price", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text("₹${avg.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("LTP", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text("₹${currentLtp.toStringAsFixed(2)}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text("P&L", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${isItemBullish ? '+' : ''}₹${itemPnl.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontSize: 13, 
                                                  fontWeight: FontWeight.bold, 
                                                  color: isItemBullish ? MyColor.primaryColor500 : Colors.red
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_outlined, size: 70, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No Stocks in Portfolio",
              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Invest in delivery stocks to build your long-term equity portfolio.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor500,
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
                  Text("Discover Stocks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHoldingActionSheet(dynamic holding) {
    final symbol = holding['symbol'] ?? '';
    final name = holding['company_name'] ?? symbol;
    final avg = double.tryParse(holding['average_price']?.toString() ?? '0.0') ?? 0.0;
    final currentLtp = avg * 1.02;

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
            Text(symbol, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(name, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Text("Est. Price: ₹${currentLtp.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      // Redirect to order placement screen
                      Get.toNamed(
                        RouteHelper.tradeBuySellScreen, 
                        arguments: [symbol, 'buy'], 
                        preventDuplicates: true
                      );
                    },
                    child: const Text("BUY MORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                      Get.toNamed(
                        RouteHelper.tradeBuySellScreen, 
                        arguments: [symbol, 'sell'], 
                        preventDuplicates: true
                      );
                    },
                    child: const Text("SELL HOLDING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
