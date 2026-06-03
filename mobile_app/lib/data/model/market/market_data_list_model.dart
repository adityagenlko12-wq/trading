import 'dart:convert';

MarketDataListModel marketDataListModelFromJson(String str) => MarketDataListModel.fromJson(json.decode(str));

String marketDataListModelToJson(MarketDataListModel data) => json.encode(data.toJson());

class MarketDataListModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketDataListModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketDataListModel.fromJson(Map<String, dynamic> json) => MarketDataListModel(
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
  Pairs? pairs;

  Data({this.pairs});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        pairs: json["pairs"] == null ? null : Pairs.fromJson(json["pairs"]),
      );

  Map<String, dynamic> toJson() => {
        "pairs": pairs?.toJson(),
      };
}

class Pairs {
  List<MarketPairSingleData>? data;
  String? nextPageUrl;

  Pairs({this.data, this.nextPageUrl});

  factory Pairs.fromJson(Map<String, dynamic> json) => Pairs(
        data: json["data"] == null ? [] : List<MarketPairSingleData>.from(json["data"].map((x) => MarketPairSingleData.fromJson(x))),
        nextPageUrl: json["next_page_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class MarketPairSingleData {
  int? id;
  String? symbol;
  Coin? coin;
  Market? market;
  MarketData? marketData;

  MarketPairSingleData({
    this.id,
    this.symbol,
    this.coin,
    this.market,
    this.marketData,
  });

  factory MarketPairSingleData.fromJson(Map<String, dynamic> json) => MarketPairSingleData(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        coin: json["coin"] == null ? null : Coin.fromJson(json["coin"]),
        market: json["market"] == null ? null : Market.fromJson(json["market"]),
        marketData: json["market_data"] == null ? null : MarketData.fromJson(json["market_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "coin": coin?.toJson(),
        "market": market?.toJson(),
        "market_data": marketData?.toJson(),
      };
}

class Coin {
  int? id;
  String? symbol;
  String? name;
  String? imageUrl;

  Coin({this.id, this.symbol, this.name, this.imageUrl});

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["imageUrl"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "image_path": imageUrl,
      };
}

class Market {
  int? id;
  String? name;
  Currency? currency;

  Market({this.id, this.name, this.currency});

  factory Market.fromJson(Map<String, dynamic> json) => Market(
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
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["imageUrl"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "image_path": imageUrl,
      };
}

class MarketData {
  String? id;
  String? symbol;
  String? price;
  String? percentChange1H;
  String? percentChange24H;
  String? marketCap;
  String? htmlCode;
  HtmlClasses? htmlClasses;

  MarketData({
    this.id,
    this.symbol,
    this.price,
    this.percentChange1H,
    this.percentChange24H,
    this.marketCap,
    this.htmlCode,
    this.htmlClasses,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => MarketData(
        id: json["id"]?.toString() ?? json["market_id"]?.toString(),
        symbol: json["symbol"]?.toString(),
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString() ?? json["percent_change_24h_class"]?.toString(),
        marketCap: json["market_cap"]?.toString() ?? json["market_cap_class"]?.toString(),
        htmlCode: json["html_code"]?.toString(),
        htmlClasses: json["html_classes"] == null ? null : HtmlClasses.fromJson(json["html_classes"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "price": price,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
        "market_cap": marketCap,
        "html_code": htmlCode,
        "html_classes": htmlClasses?.toJson(),
      };
}

class HtmlClasses {
  String? priceChange;
  String? percentChange1H;
  String? percentChange24H;

  HtmlClasses({
    this.priceChange,
    this.percentChange1H,
    this.percentChange24H,
  });

  factory HtmlClasses.fromJson(Map<String, dynamic> json) => HtmlClasses(
        priceChange: json["price_change"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "price_change": priceChange,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
      };
}
