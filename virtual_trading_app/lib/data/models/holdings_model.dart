class HoldingsModel {
  final String symbol;
  final String companyName;
  final double quantity;
  final double avgBuyPrice;
  final double currentPrice;

  HoldingsModel({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
  });

  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * avgBuyPrice;
  double get profitLoss => totalValue - totalCost;
  double get profitLossPercentage => totalCost > 0 ? (profitLoss / totalCost) * 100 : 0.0;

  factory HoldingsModel.fromJson(Map<String, dynamic> json) {
    double getDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return HoldingsModel(
      symbol: json['symbol']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? json['symbol']?.toString() ?? '',
      quantity: getDouble(json['quantity'] ?? json['amount']),
      avgBuyPrice: getDouble(json['avg_price'] ?? json['rate']),
      currentPrice: getDouble(json['current_price'] ?? json['price'] ?? json['rate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'company_name': companyName,
    'quantity': quantity,
    'avg_price': avgBuyPrice,
    'current_price': currentPrice,
  };
}
