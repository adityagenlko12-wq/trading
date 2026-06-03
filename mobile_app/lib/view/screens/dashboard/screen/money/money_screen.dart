import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/data/services/api_service.dart';

class MoneyScreen extends StatefulWidget {
  const MoneyScreen({super.key});

  @override
  State<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends State<MoneyScreen> {
  final ApiClient apiClient = Get.find();
  bool isLoading = true;
  
  Map<String, dynamic> stats = {};
  String userEmail = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    userEmail = apiClient.getUserEmail();
    userName = apiClient.getCurrencyOrUsername(isCurrency: false);
    fetchWalletStats();
  }

  Future<void> fetchWalletStats() async {
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
        });
      }
    } catch (e) {
      debugPrint("Error fetching wallet stats: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> resetPortfolio() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}admin/reset_user',
        Method.postMethod,
        {'email': userEmail},
        passHeader: true,
        isOnlyAcceptType: true,
      );
      if (response.statusCode == 200) {
        fetchWalletStats();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Portfolio reset successfully to ₹10,00,000!"),
            backgroundColor: MyColor.primaryColor500,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error resetting portfolio: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double walletBalance = 1000000.0;
    double invested = 0.0;
    double todaysPnl = 0.0;
    double overallPnl = 0.0;

    try {
      walletBalance = double.parse(stats['wallet_balance']?.toString() ?? '1000000.0');
      invested = double.parse(stats['invested_amount']?.toString() ?? '0.0');
      todaysPnl = double.parse(stats['todays_pnl']?.toString() ?? '0.0');
      overallPnl = double.parse(stats['overall_pnl']?.toString() ?? '0.0');
    } catch (_) {}

    final overallBullish = overallPnl >= 0;
    final todaysBullish = todaysPnl >= 0;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Money & Account",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchWalletStats,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: MyColor.primaryColor500))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: MyColor.primaryColor500,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName.isNotEmpty ? userName : "Valued User",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Wallet & Balance Overview Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Available Virtual Balance",
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "₹${walletBalance.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniMetric("Invested Amount", "₹${invested.toStringAsFixed(2)}", Colors.black),
                            _buildMiniMetric(
                              "Today's P&L", 
                              "${todaysBullish ? '+' : ''}₹${todaysPnl.toStringAsFixed(2)}", 
                              todaysBullish ? MyColor.primaryColor500 : Colors.red
                            ),
                            _buildMiniMetric(
                              "Overall P&L", 
                              "${overallBullish ? '+' : ''}₹${overallPnl.toStringAsFixed(2)}", 
                              overallBullish ? MyColor.primaryColor500 : Colors.red
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Actions List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.refresh, color: MyColor.primaryColor500),
                          title: const Text("Reset Portfolio & Balance", style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: const Text("Re-allocates ₹10,00,000 and clears all assets"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => _confirmReset(),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                          onTap: () {
                            apiClient.clearOldAuthData();
                            Get.offAllNamed(RouteHelper.authenticationScreen);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Reset"),
          content: const Text("Are you sure you want to reset your virtual portfolio? All active holdings and trades will be permanently deleted and your wallet balance will return to ₹10,00,000."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                resetPortfolio();
              },
            ),
          ],
        );
      },
    );
  }
}
