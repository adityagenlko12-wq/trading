import 'dart:convert';

MarketCurrencyDataList marketCurrencyDataListFromJson(String str) => MarketCurrencyDataList.fromJson(json.decode(str));

String marketCurrencyDataListToJson(MarketCurrencyDataList data) => json.encode(data.toJson());

class MarketCurrencyDataList {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketCurrencyDataList({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketCurrencyDataList.fromJson(Map<String, dynamic> json) => MarketCurrencyDataList(
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
  List<CurrencyMarket>? markets;

  Data({this.markets});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        markets: json["markets"] == null
            ? []
            : List<CurrencyMarket>.from(json["markets"].map((x) => CurrencyMarket.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "markets": markets == null ? [] : List<dynamic>.from(markets!.map((x) => x.toJson())),
      };
}

class CurrencyMarket {
  int? id;
  String? name;
  Currency? currency;

  CurrencyMarket({
    this.id,
    this.name,
    this.currency,
  });

  factory CurrencyMarket.fromJson(Map<String, dynamic> json) => CurrencyMarket(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "currency": currency?.toJson(),
      };
}

class Currency {
  int? id;
  String? symbol;
  String? name;
  String? imageUrl;

  Currency({this.id, this.symbol, this.name, this.imageUrl});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["image_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "image_path": imageUrl,
      };
}
