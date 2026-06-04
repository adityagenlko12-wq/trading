class MarketDataModel {
  final String symbol;
  final String companyName;
  final double price;
  final double change;
  final double changePercent;
  final String exchange;
  final double open;
  final double high;
  final double low;
  final double prevClose;
  final double yearHigh;
  final double yearLow;

  MarketDataModel({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    this.exchange = 'NSE',
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.prevClose = 0.0,
    this.yearHigh = 0.0,
    this.yearLow = 0.0,
  });

  factory MarketDataModel.fromJson(Map<String, dynamic> json) {
    // Check if we have a nested coin object (from api/trade/<symbol_id> details)
    final coin = json['coin'] as Map<String, dynamic>?;
    final symbol = coin != null ? (coin['symbol']?.toString() ?? '') : (json['symbol']?.toString() ?? '');
    final companyName = coin != null ? (coin['name']?.toString() ?? '') : (json['company_name']?.toString() ?? json['name']?.toString() ?? '');

    // Parse marketData object
    final m = json['market_data'] ?? json;
    
    double getDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return MarketDataModel(
      symbol: symbol.isNotEmpty ? symbol : (m['id']?.toString() ?? ''),
      companyName: companyName.isNotEmpty ? companyName : (m['id']?.toString() ?? ''),
      price: getDouble(m['price'] ?? m['ltp']),
      change: getDouble(m['day_change'] ?? m['price_change'] ?? 0.0),
      changePercent: getDouble(m['percent_change_24h'] ?? m['percentage_change'] ?? m['change_percent'] ?? 0.0),
      exchange: m['exchange']?.toString() ?? 'NSE',
      open: getDouble(m['open']),
      high: getDouble(m['high']),
      low: getDouble(m['low']),
      prevClose: getDouble(m['prev_close']),
      yearHigh: getDouble(m['year_high']),
      yearLow: getDouble(m['year_low']),
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'company_name': companyName,
    'price': price,
    'change': change,
    'changePercent': changePercent,
    'exchange': exchange,
    'open': open,
    'high': high,
    'low': low,
    'prev_close': prevClose,
    'year_high': yearHigh,
    'year_low': yearLow,
  };
}
