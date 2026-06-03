import 'dart:convert';

MarketOverviewDataModel marketOverviewDataModelFromJson(String str) => MarketOverviewDataModel.fromJson(json.decode(str));

String marketOverviewDataModelToJson(MarketOverviewDataModel data) => json.encode(data.toJson());

class MarketOverviewDataModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketOverviewDataModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketOverviewDataModel.fromJson(Map<String, dynamic> json) => MarketOverviewDataModel(
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
  List<TopExchangesCoin>? topExchangesCoins;
  List<OverViewCoinModel>? highLightedCoins;
  List<OverViewCoinModel>? newCoins;

  Data({
    this.topExchangesCoins,
    this.highLightedCoins,
    this.newCoins,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        topExchangesCoins: json["top_exchanges_coins"] == null ? [] : List<TopExchangesCoin>.from(json["top_exchanges_coins"].map((x) => TopExchangesCoin.fromJson(x))),
        highLightedCoins: json["highlighted_coins"] == null ? [] : List<OverViewCoinModel>.from(json["highlighted_coins"].map((x) => OverViewCoinModel.fromJson(x))),
        newCoins: json["new_coins"] == null ? [] : List<OverViewCoinModel>.from(json["new_coins"].map((x) => OverViewCoinModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "top_exchanges_coins": topExchangesCoins == null ? [] : List<dynamic>.from(topExchangesCoins!.map((x) => x.toJson())),
        "highlighted_coins": highLightedCoins == null ? [] : List<dynamic>.from(highLightedCoins!.map((x) => x.toJson())),
        "new_coins": newCoins == null ? [] : List<dynamic>.from(newCoins!.map((x) => x.toJson())),
      };
}

class TopExchangesCoin {
  int? id;
  Coin? coin;

  TopExchangesCoin({this.id, this.coin});

  factory TopExchangesCoin.fromJson(Map<String, dynamic> json) => TopExchangesCoin(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        coin: json["coin"] == null ? null : Coin.fromJson(json["coin"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coin": coin?.toJson(),
      };
}

class OverViewCoinModel {
  int? id;
  String? name;
  String? symbol;
  String? image;
  MarketData? marketData;

  OverViewCoinModel({
    this.id,
    this.name,
    this.symbol,
    this.image,
    this.marketData,
  });

  String? get imageUrl => image;

  factory OverViewCoinModel.fromJson(Map<String, dynamic> json) => OverViewCoinModel(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        symbol: json["symbol"]?.toString(),
        image: json["image"]?.toString() ?? json["image_path"]?.toString() ?? json["imageUrl"]?.toString(),
        marketData: json["market_data"] == null ? null : MarketData.fromJson(json["market_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "symbol": symbol,
        "image": image,
        "market_data": marketData?.toJson(),
      };
}

class Coin {
  int? id;
  String? symbol;
  String? name;
  String? image;
  MarketData? marketData;

  Coin({
    this.id,
    this.symbol,
    this.name,
    this.image,
    this.marketData,
  });

  String? get imageUrl => image;

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
        image: json["image"]?.toString() ?? json["image_path"]?.toString() ?? json["imageUrl"]?.toString(),
        marketData: json["market_data"] == null ? null : MarketData.fromJson(json["market_data"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "image": image,
        "market_data": marketData?.toJson(),
      };
}

class MarketData {
  String? id;
  String? price;
  String? percentChange1H;
  String? marketCap;
  HtmlClasses? htmlClasses;

  MarketData({
    this.id,
    this.price,
    this.percentChange1H,
    this.marketCap,
    this.htmlClasses,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => MarketData(
        id: json["id"]?.toString() ?? json["market_id"]?.toString(),
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        marketCap: json["market_cap"]?.toString(),
        htmlClasses: json["html_classes"] == null ? null : HtmlClasses.fromJson(json["html_classes"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "percent_change_1h": percentChange1H,
        "market_cap": marketCap,
        "html_classes": htmlClasses?.toJson(),
      };
}

class HtmlClasses {
  String? priceChange;
  String? percentChange1H;

  HtmlClasses({this.priceChange, this.percentChange1H});

  factory HtmlClasses.fromJson(Map<String, dynamic> json) => HtmlClasses(
        priceChange: json["price_change"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "price_change": priceChange,
        "percent_change_1h": percentChange1H,
      };
}
