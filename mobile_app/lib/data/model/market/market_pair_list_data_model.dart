import 'dart:convert';

MarketPairListDataModel marketPairListDataModelFromJson(String str) => MarketPairListDataModel.fromJson(json.decode(str));

String marketPairListDataModelToJson(MarketPairListDataModel data) => json.encode(data.toJson());

class MarketPairListDataModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketPairListDataModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketPairListDataModel.fromJson(Map<String, dynamic> json) => MarketPairListDataModel(
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
  List<String>? favoritePairId;

  Data({this.pairs, this.favoritePairId});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        pairs: json["pairs"] == null ? null : Pairs.fromJson(json["pairs"]),
        favoritePairId: json["favorite_pair_id"] == null ? [] : List<String>.from(json["favorite_pair_id"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "pairs": pairs?.toJson(),
        "favorite_pair_id": favoritePairId,
      };
}

class Pairs {
  dynamic currentPage;
  List<MarketSinglePairData>? data;
  String? nextPageUrl;
  dynamic lastPage;

  Pairs({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.lastPage,
  });

  factory Pairs.fromJson(Map<String, dynamic> json) => Pairs(
        currentPage: json["current_page"],
        data: json["data"] == null ? [] : List<MarketSinglePairData>.from(json["data"].map((x) => MarketSinglePairData.fromJson(x))),
        nextPageUrl: json["next_page_url"]?.toString(),
        lastPage: json["last_page"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "last_page": lastPage,
      };
}

class MarketSinglePairData {
  int? id;
  String? symbol;
  Coin? coin;
  Market? market;
  MarketData? marketData;

  MarketSinglePairData({
    this.id,
    this.symbol,
    this.coin,
    this.market,
    this.marketData,
  });

  factory MarketSinglePairData.fromJson(Map<String, dynamic> json) => MarketSinglePairData(
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

  Coin({this.id, this.symbol, this.name});

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
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

  Currency({this.id, this.symbol, this.name});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
      };
}

class MarketData {
  String? id;
  String? price;
  String? percentChange1H;
  String? percentChange24H;
  String? marketCap;
  String? htmlCode;
  HtmlClasses? htmlClasses;

  MarketData({
    this.id,
    this.price,
    this.percentChange1H,
    this.percentChange24H,
    this.marketCap,
    this.htmlCode,
    this.htmlClasses,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => MarketData(
        id: json["id"]?.toString() ?? json["market_id"]?.toString(),
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString() ?? json["percent_change_1h_class"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString() ?? json["percent_change_24h_class"]?.toString(),
        marketCap: json["market_cap"]?.toString() ?? json["market_cap_class"]?.toString(),
        htmlCode: json["html_code"]?.toString(),
        htmlClasses: json["html_classes"] == null ? null : HtmlClasses.fromJson(json["html_classes"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
        "market_cap": marketCap,
        "html_code": htmlCode,
        "html_classes": htmlClasses?.toJson(),
      };
}

class HtmlClasses {
  String? price;
  String? percentChange1H;
  String? percentChange24H;
  String? marketCap;

  HtmlClasses({
    this.price,
    this.percentChange1H,
    this.percentChange24H,
    this.marketCap,
  });

  factory HtmlClasses.fromJson(Map<String, dynamic> json) => HtmlClasses(
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString(),
        marketCap: json["market_cap"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
        "market_cap": marketCap,
      };
}
