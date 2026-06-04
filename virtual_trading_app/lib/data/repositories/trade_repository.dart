import '../../core/network/api_client.dart';
import '../models/market_data_model.dart';
import '../models/order_model.dart';
import '../models/holdings_model.dart';

class TradeRepository {
  final ApiClient apiClient;

  TradeRepository({required this.apiClient});

  Future<List<MarketDataModel>> getIndices() async {
    try {
      final response = await apiClient.get('/api/indices/quotes');
      final dynamic responseData = response.data;
      
      List<MarketDataModel> list = [];
      if (responseData is List) {
        for (var item in responseData) {
          if (item is Map) {
            list.add(MarketDataModel(
              symbol: item['symbol']?.toString() ?? '',
              companyName: item['display_name']?.toString() ?? item['symbol']?.toString() ?? '',
              price: double.tryParse(item['ltp']?.toString() ?? '') ?? 0.0,
              change: double.tryParse(item['day_change']?.toString() ?? '') ?? 0.0,
              changePercent: double.tryParse(item['percentage_change']?.toString() ?? '') ?? 0.0,
              open: double.tryParse(item['open']?.toString() ?? '') ?? 0.0,
              high: double.tryParse(item['high']?.toString() ?? '') ?? 0.0,
              low: double.tryParse(item['low']?.toString() ?? '') ?? 0.0,
              prevClose: double.tryParse(item['close']?.toString() ?? '') ?? 0.0,
            ));
          }
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPortfolio() async {
    try {
      final response = await apiClient.get('/api/portfolio');
      final dynamic data = response.data;
      
      final Map<String, dynamic> result = {};
      
      if (data is Map) {
        result['stats'] = data['stats'] ?? {};
        
        final List<HoldingsModel> holdings = [];
        if (data['holdings'] is List) {
          for (var item in data['holdings']) {
            holdings.add(HoldingsModel.fromJson(item));
          }
        }
        result['holdings'] = holdings;

        final List<OrderModel> activeOrders = [];
        if (data['positions'] is List) {
          for (var item in data['positions']) {
            activeOrders.add(OrderModel.fromJson(item));
          }
        }
        result['positions'] = activeOrders;

        final List<OrderModel> trades = [];
        if (data['trades'] is List) {
          for (var item in data['trades']) {
            trades.add(OrderModel.fromJson(item));
          }
        }
        result['trades'] = trades;
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<MarketDataModel> getStockQuote(String symbol) async {
    try {
      final response = await apiClient.get('/api/trade/$symbol');
      final dynamic data = response.data;
      
      if (data is Map && data['status'] == 'success') {
        final pair = data['data']['pair'];
        return MarketDataModel.fromJson(pair);
      } else {
        throw 'Failed to fetch quote details.';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> placeOrder({
    required String symbol,
    required double price,
    required double quantity,
    required bool isBuy,
    required bool isLimit,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/order/save/$symbol',
        data: {
          'rate': price.toString(),
          'amount': quantity.toString(),
          'order_side': isBuy ? '1' : '2',
          'order_type': isLimit ? '1' : '2',
        },
      );
      final dynamic data = response.data;
      return data['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    try {
      final response = await apiClient.post('/api/order/cancel/$orderId');
      final dynamic data = response.data;
      return data['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MarketDataModel>> searchStocks(String query) async {
    try {
      final response = await apiClient.get('/api/stocks/search', queryParameters: {'query': query});
      final dynamic data = response.data;
      
      List<MarketDataModel> results = [];
      if (data is List) {
        for (var item in data) {
          if (item is Map) {
            results.add(MarketDataModel(
              symbol: item['symbol'] ?? '',
              companyName: item['name'] ?? item['company_name'] ?? item['symbol'] ?? '',
              price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
              change: double.tryParse(item['change']?.toString() ?? '') ?? 0.0,
              changePercent: double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0,
            ));
          }
        }
      } else if (data is Map && data.containsKey('results') && data['results'] is List) {
        for (var item in data['results']) {
          results.add(MarketDataModel(
            symbol: item['symbol'] ?? '',
            companyName: item['name'] ?? item['company_name'] ?? item['symbol'] ?? '',
            price: double.tryParse(item['price']?.toString() ?? '') ?? 0.0,
            change: double.tryParse(item['change']?.toString() ?? '') ?? 0.0,
            changePercent: double.tryParse(item['change_percent']?.toString() ?? '') ?? 0.0,
          ));
        }
      }
      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCommodityData() async {
    try {
      final response = await apiClient.get('/api/commodity/data');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
