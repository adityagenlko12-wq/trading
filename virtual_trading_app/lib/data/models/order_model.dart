class OrderModel {
  final int id;
  final String symbol;
  final double price;
  final double quantity;
  final String orderSide; // '1' for BUY, '2' for SELL
  final String orderType; // '1' for Limit, '2' for Market
  final String status;    // 'open', 'completed', 'canceled'
  final String datetime;

  OrderModel({
    required this.id,
    required this.symbol,
    required this.price,
    required this.quantity,
    required this.orderSide,
    required this.orderType,
    required this.status,
    required this.datetime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double getDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return OrderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      symbol: json['symbol']?.toString() ?? json['coin_symbol']?.toString() ?? '',
      price: getDouble(json['rate'] ?? json['price']),
      quantity: getDouble(json['amount'] ?? json['quantity']),
      orderSide: json['order_side']?.toString() ?? '1',
      orderType: json['order_type']?.toString() ?? '1',
      status: json['status']?.toString() ?? 'open',
      datetime: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'rate': price,
    'amount': quantity,
    'order_side': orderSide,
    'order_type': orderType,
    'status': status,
    'created_at': datetime,
  };
}
