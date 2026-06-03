import 'dart:convert';

TradeHistoryResponseModel tradeHistoryResponseModelFromJson(String str) => TradeHistoryResponseModel.fromJson(json.decode(str));

String tradeHistoryResponseModelToJson(TradeHistoryResponseModel data) => json.encode(data.toJson());

class TradeHistoryResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  TradeHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory TradeHistoryResponseModel.fromJson(Map<String, dynamic> json) => TradeHistoryResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "status": status,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({
    this.success,
    this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] == null ? null : List<String>.from(json["success"].map((x) => x.toString())),
        error: json["error"] == null ? null : List<String>.from(json["error"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : List<dynamic>.from(success!.map((x) => x)),
        "error": error == null ? null : List<dynamic>.from(error!.map((x) => x)),
      };
}

class Data {
  List<TradeHistoryData>? trades;

  Data({
    this.trades,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        trades: json["trades"] == null
            ? []
            : List<TradeHistoryData>.from(json["trades"].map((x) => TradeHistoryData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "trades": trades == null ? [] : List<dynamic>.from(trades!.map((x) => x.toJson())),
      };
}

class TradeHistoryData {
  int? id;
  String? orderId;
  String? pairId;
  String? amount;
  String? rate;
  String? tradeSide;
  String? createdAt;
  String? updatedAt;
  String? formattedDate;

  TradeHistoryData({
    this.id,
    this.orderId,
    this.pairId,
    this.amount,
    this.rate,
    this.tradeSide,
    this.createdAt,
    this.updatedAt,
    this.formattedDate,
  });

  factory TradeHistoryData.fromJson(Map<String, dynamic> json) => TradeHistoryData(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        orderId: json["order_id"]?.toString(),
        pairId: json["pair_id"]?.toString(),
        amount: json["amount"]?.toString(),
        rate: json["rate"]?.toString(),
        tradeSide: json["trade_side"]?.toString() ?? json["side"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        formattedDate: json["formatted_date"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "order_id": orderId,
        "pair_id": pairId,
        "amount": amount,
        "rate": rate,
        "trade_side": tradeSide,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "formatted_date": formattedDate,
      };
}
