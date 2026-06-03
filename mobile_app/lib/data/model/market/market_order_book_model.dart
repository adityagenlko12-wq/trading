import 'dart:convert';

MarketOrderBookModel marketOrderBookModelFromJson(String str) => MarketOrderBookModel.fromJson(json.decode(str));

String marketOrderBookModelToJson(MarketOrderBookModel data) => json.encode(data.toJson());

class MarketOrderBookModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketOrderBookModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketOrderBookModel.fromJson(Map<String, dynamic> json) => MarketOrderBookModel(
        status: json["status"]?.toString(),
        remark: json["remark"]?.toString(),
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "remark": remark,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({this.success, this.error});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] == null ? [] : List<String>.from(json["success"].map((x) => x.toString())),
        error: json["error"] == null ? [] : List<String>.from(json["error"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "error": error,
      };
}

class Data {
  List<SideOrderBook>? buySideOrders;
  List<SideOrderBook>? sellSideOrders;

  Data({
    this.buySideOrders,
    this.sellSideOrders,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        buySideOrders: json["buy_side_orders"] == null
            ? []
            : List<SideOrderBook>.from(json["buy_side_orders"].map((x) => SideOrderBook.fromJson(x))),
        sellSideOrders: json["sell_side_orders"] == null
            ? []
            : List<SideOrderBook>.from(json["sell_side_orders"].map((x) => SideOrderBook.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "buy_side_orders": buySideOrders == null ? [] : List<dynamic>.from(buySideOrders!.map((x) => x.toJson())),
        "sell_side_orders": sellSideOrders == null ? [] : List<dynamic>.from(sellSideOrders!.map((x) => x.toJson())),
      };
}

class SideOrderBook {
  dynamic id;
  String? userId;
  String? pairId;
  String? coinId;
  String? trx;
  String? orderSide;
  String? orderType;
  String? rate;
  String? price;
  String? amount;
  String? total;
  String? filledAmount;
  String? filedPercentage;
  String? charge;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? orderSideBadge;
  String? formattedDate;
  String? statusBadge;

  String? get totalAmount => amount;

  SideOrderBook({
    this.id,
    this.userId,
    this.pairId,
    this.coinId,
    this.trx,
    this.orderSide,
    this.orderType,
    this.rate,
    this.price,
    this.amount,
    this.total,
    this.filledAmount,
    this.filedPercentage,
    this.charge,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.orderSideBadge,
    this.formattedDate,
    this.statusBadge,
  });

  factory SideOrderBook.fromJson(Map<String, dynamic> json) => SideOrderBook(
        id: json["id"],
        userId: json["user_id"]?.toString(),
        pairId: json["pair_id"]?.toString(),
        coinId: json["coin_id"]?.toString(),
        trx: json["trx"]?.toString(),
        orderSide: json["order_side"]?.toString(),
        orderType: json["order_type"]?.toString(),
        rate: json["rate"]?.toString(),
        price: json["price"]?.toString(),
        amount: json["amount"]?.toString(),
        total: json["total"]?.toString(),
        filledAmount: json["filled_amount"]?.toString(),
        filedPercentage: json["filed_percentage"]?.toString(),
        charge: json["charge"]?.toString(),
        status: json["status"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        orderSideBadge: json["order_side_badge"]?.toString(),
        formattedDate: json["formatted_date"]?.toString(),
        statusBadge: json["status_badge"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "pair_id": pairId,
        "coin_id": coinId,
        "trx": trx,
        "order_side": orderSide,
        "order_type": orderType,
        "rate": rate,
        "price": price,
        "amount": amount,
        "total": total,
        "filled_amount": filledAmount,
        "filed_percentage": filedPercentage,
        "charge": charge,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "order_side_badge": orderSideBadge,
        "formatted_date": formattedDate,
        "status_badge": statusBadge,
      };
}
