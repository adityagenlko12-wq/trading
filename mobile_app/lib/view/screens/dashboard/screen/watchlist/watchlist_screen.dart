import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/utils/my_color.dart';
import 'package:vinance/core/utils/dimensions.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/core/utils/method.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/data/services/api_service.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient apiClient = Get.find();
  bool isLoading = true;
  List<List<dynamic>> watchlistsData = [[], [], []];
  int activeWatchlistIndex = 0;
  
  // Search state
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        activeWatchlistIndex = _tabController.index;
      });
    });
    fetchWatchlists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchWatchlists() async {
    setState(() {
      isLoading = true;
    });
    try {
      for (int i = 1; i <= 3; i++) {
        final response = await apiClient.request(
          '${UrlContainer.baseUrl}watchlist/$i',
          Method.getMethod,
          null,
          passHeader: true,
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.responseJson);
          if (data is List) {
            watchlistsData[i - 1] = data;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching watchlists: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }
    setState(() {
      isSearching = true;
    });
    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}stocks/search?q=${Uri.encodeComponent(query)}',
        Method.getMethod,
        null,
        passHeader: false,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.responseJson);
        setState(() {
          searchResults = data;
        });
      }
    } catch (e) {
      debugPrint("Error searching stocks: $e");
    }
  }

  Future<void> toggleWatchlist(String symbol, String name, String type) async {
    final activeList = watchlistsData[activeWatchlistIndex];
    final exists = activeList.any((item) => item['symbol'] == symbol);
    
    final endpoint = exists ? 'watchlist/remove' : 'watchlist/add';
    final payload = {
      'watchlist_num': (activeWatchlistIndex + 1).toString(),
      'symbol': symbol,
      'name': name,
      'type': type,
    };

    try {
      final response = await apiClient.request(
        '${UrlContainer.baseUrl}$endpoint',
        Method.postMethod,
        payload,
        passHeader: true,
        isOnlyAcceptType: true,
      );
      
      if (response.statusCode == 200) {
        fetchWatchlists();
        // Clear search
        searchController.clear();
        setState(() {
          searchResults = [];
          isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exists ? "$symbol removed from Watchlist ${activeWatchlistIndex + 1}" : "$symbol added to Watchlist ${activeWatchlistIndex + 1}"),
            backgroundColor: MyColor.primaryColor500,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error modifying watchlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Watchlists",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: fetchWatchlists,
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(105),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: performSearch,
                  decoration: InputDecoration(
                    hintText: "Search & add stocks...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              performSearch("");
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xffeef0f6),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Watchlist tabs selector
              TabBar(
                controller: _tabController,
                indicatorColor: MyColor.primaryColor500,
                indicatorWeight: 3,
                labelColor: MyColor.primaryColor500,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Watchlist 1"),
                  Tab(text: "Watchlist 2"),
                  Tab(text: "Watchlist 3"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isSearching 
          ? _buildSearchResults()
          : isLoading 
              ? const Center(child: CircularProgressIndicator(color: MyColor.primaryColor500))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWatchlistContent(0),
                    _buildWatchlistContent(1),
                    _buildWatchlistContent(2),
                  ],
                ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(child: Text("No stocks found matching query."));
    }
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];
        final symbol = item['symbol'] ?? '';
        final name = item['name'] ?? '';
        final type = item['type'] ?? 'STOCK';
        
        final activeList = watchlistsData[activeWatchlistIndex];
        final isAdded = activeList.any((e) => e['symbol'] == symbol);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: Icon(
                isAdded ? Icons.check_circle : Icons.add_circle_outline,
                color: isAdded ? MyColor.primaryColor500 : Colors.grey,
              ),
              onPressed: () => toggleWatchlist(symbol, name, type),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatchlistContent(int wlIndex) {
    final list = watchlistsData[wlIndex];
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Watchlist ${wlIndex + 1} is empty",
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text("Search for stocks above and add them.", style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final symbol = item['symbol'] ?? '';
        final name = item['name'] ?? symbol;
        final ltp = item['ltp'] ?? 0.0;
        final change = item['day_change'] ?? 0.0;
        final pct = item['percentage_change'] ?? 0.0;
        final isBullish = pct >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              symbol,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            subtitle: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${ltp.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isBullish ? const Color(0xffe6fbf2) : const Color(0xfffdf2f2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "${isBullish ? '+' : ''}${change.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isBullish ? MyColor.primaryColor500 : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              _showTradeBottomSheet(item);
            },
          ),
        );
      },
    );
  }

  void _showTradeBottomSheet(dynamic stock) {
    final symbol = stock['symbol'] ?? '';
    final name = stock['name'] ?? symbol;
    final ltp = stock['ltp'] ?? 0.0;
    
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
                      // Redirect to order placement screen
                      Get.toNamed(
                        RouteHelper.tradeBuySellScreen, 
                        arguments: [symbol, 'buy'], 
                        preventDuplicates: true
                      );
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
                      Get.toNamed(
                        RouteHelper.tradeBuySellScreen, 
                        arguments: [symbol, 'sell'], 
                        preventDuplicates: true
                      );
                    },
                    child: const Text("SELL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Get.back();
                toggleWatchlist(symbol, name, stock['type'] ?? 'STOCK');
              },
              child: const Text("Remove from Watchlist", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
