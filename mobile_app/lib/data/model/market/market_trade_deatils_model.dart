import 'dart:convert';

MarketTradeDetailsModel marketTradeDetailsModelFromJson(String str) => MarketTradeDetailsModel.fromJson(json.decode(str));

String marketTradeDetailsModelToJson(MarketTradeDetailsModel data) => json.encode(data.toJson());

class MarketTradeDetailsModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MarketTradeDetailsModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MarketTradeDetailsModel.fromJson(Map<String, dynamic> json) => MarketTradeDetailsModel(
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
  Pair? pair;
  String? isFavorite;
  Wallet? coinWallet;
  Wallet? marketCurrencyWallet;

  Data({
    this.pair,
    this.isFavorite,
    this.coinWallet,
    this.marketCurrencyWallet,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        pair: json["pair"] == null ? null : Pair.fromJson(json["pair"]),
        isFavorite: json["is_favorite"]?.toString(),
        coinWallet: json["coin_wallet"] == null ? null : Wallet.fromJson(json["coin_wallet"]),
        marketCurrencyWallet: json["market_currency_wallet"] == null ? null : Wallet.fromJson(json["market_currency_wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "pair": pair?.toJson(),
        "is_favorite": isFavorite,
        "coin_wallet": coinWallet?.toJson(),
        "market_currency_wallet": marketCurrencyWallet?.toJson(),
      };
}

class Pair {
  int? id;
  String? symbol;
  Coin? coin;
  Market? market;
  MarketData? marketData;
  String? percentChargeForBuy;
  String? percentChargeForSell;
  String? minimumBuyAmount;
  String? maximumBuyAmount;
  String? minimumSellAmount;
  String? maximumSellAmount;
  String? _listedMarketName;
  String? coinId;
  String? marketId;

  String? get listedMarketName => _listedMarketName ?? market?.name;

  Pair({
    this.id,
    this.symbol,
    this.coin,
    this.market,
    this.marketData,
    this.percentChargeForBuy,
    this.percentChargeForSell,
    this.minimumBuyAmount,
    this.maximumBuyAmount,
    this.minimumSellAmount,
    this.maximumSellAmount,
    String? listedMarketName,
    this.coinId,
    this.marketId,
  }) : _listedMarketName = listedMarketName;

  factory Pair.fromJson(Map<String, dynamic> json) => Pair(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        coin: json["coin"] == null ? null : Coin.fromJson(json["coin"]),
        market: json["market"] == null ? null : Market.fromJson(json["market"]),
        marketData: json["market_data"] == null ? null : MarketData.fromJson(json["market_data"]),
        percentChargeForBuy: json["percent_charge_for_buy"]?.toString(),
        percentChargeForSell: json["percent_charge_for_sell"]?.toString(),
        minimumBuyAmount: json["minimum_buy_amount"]?.toString(),
        maximumBuyAmount: json["maximum_buy_amount"]?.toString(),
        minimumSellAmount: json["minimum_sell_amount"]?.toString(),
        maximumSellAmount: json["maximum_sell_amount"]?.toString(),
        listedMarketName: json["listed_market_name"]?.toString() ?? json["listed_market"]?.toString(),
        coinId: json["coin_id"]?.toString(),
        marketId: json["market_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "coin": coin?.toJson(),
        "market": market?.toJson(),
        "market_data": marketData?.toJson(),
        "percent_charge_for_buy": percentChargeForBuy,
        "percent_charge_for_sell": percentChargeForSell,
        "minimum_buy_amount": minimumBuyAmount,
        "maximum_buy_amount": maximumBuyAmount,
        "minimum_sell_amount": minimumSellAmount,
        "maximum_sell_amount": maximumSellAmount,
        "listed_market_name": _listedMarketName,
        "coin_id": coinId,
        "market_id": marketId,
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
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["image_url"]?.toString(),
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
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["image_url"]?.toString(),
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
  String? price;
  String? percentChange1H;
  String? percentChange24H;
  String? marketCap;
  HtmlClasses? htmlClasses;

  MarketData({
    this.id,
    this.price,
    this.percentChange1H,
    this.percentChange24H,
    this.marketCap,
    this.htmlClasses,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) => MarketData(
        id: json["id"]?.toString() ?? json["market_id"]?.toString(),
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString(),
        marketCap: json["market_cap"]?.toString(),
        htmlClasses: json["html_classes"] == null ? null : HtmlClasses.fromJson(json["html_classes"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "price": price,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
        "market_cap": marketCap,
        "html_classes": htmlClasses?.toJson(),
      };
}

class HtmlClasses {
  String? price;
  String? percentChange1H;
  String? percentChange24H;
  String? marketCap;
  String? priceChange;

  HtmlClasses({
    this.price,
    this.percentChange1H,
    this.percentChange24H,
    this.marketCap,
    this.priceChange,
  });

  factory HtmlClasses.fromJson(Map<String, dynamic> json) => HtmlClasses(
        price: json["price"]?.toString(),
        percentChange1H: json["percent_change_1h"]?.toString(),
        percentChange24H: json["percent_change_24h"]?.toString(),
        marketCap: json["market_cap"]?.toString(),
        priceChange: json["price_change"]?.toString() ?? json["price"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "percent_change_1h": percentChange1H,
        "percent_change_24h": percentChange24H,
        "market_cap": marketCap,
        "price_change": priceChange,
      };
}

class Wallet {
  int? id;
  String? userType;
  String? walletType;
  String? balance;
  Currency? currency;

  Wallet({
    this.id,
    this.userType,
    this.walletType,
    this.balance,
    this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        userType: json["user_type"]?.toString(),
        walletType: json["wallet_type"]?.toString(),
        balance: json["balance"]?.toString(),
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "wallet_type": walletType,
        "balance": balance,
        "currency": currency?.toJson(),
      };
}
