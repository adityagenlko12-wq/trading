import 'dart:convert';

TradeHistoryPageResponseModel tradeHistoryPageResponseModelFromJson(String str) => TradeHistoryPageResponseModel.fromJson(json.decode(str));

class TradeHistoryPageResponseModel {
  TradeHistoryPageResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  TradeHistoryPageResponseModel.fromJson(dynamic json) {
    remark = json['remark']?.toString();
    status = json['status']?.toString();
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? remark;
  String? status;
  Message? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = remark;
    map['status'] = status;
    if (message != null) {
      map['message'] = message?.toJson();
    }
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.trades,
  });

  Data.fromJson(dynamic json) {
    trades = json['trades'] != null ? Trades.fromJson(json['trades']) : null;
  }

  Trades? trades;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (trades != null) {
      map['trades'] = trades?.toJson();
    }
    return map;
  }
}

class Trades {
  Trades({
    this.currentPage,
    this.data,
    this.nextPageUrl,
  });

  Trades.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(TradeHistoryPageListData.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
  }

  int? currentPage;
  List<TradeHistoryPageListData>? data;
  String? nextPageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['next_page_url'] = nextPageUrl;
    return map;
  }
}

class TradeHistoryPageListData {
  TradeHistoryPageListData({
    this.id,
    this.amount,
    this.tradeSide,
    this.order,
  });

  TradeHistoryPageListData.fromJson(dynamic json) {
    id = json['id']?.toString();
    amount = json['amount']?.toString();
    tradeSide = json['trade_side']?.toString() ?? json['side']?.toString();
    order = json['order'] != null ? OrderDetails.fromJson(json['order']) : null;
  }

  String? id;
  String? amount;
  String? tradeSide;
  OrderDetails? order;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['amount'] = amount;
    map['trade_side'] = tradeSide;
    if (order != null) {
      map['order'] = order?.toJson();
    }
    return map;
  }
}

class OrderDetails {
  OrderDetails({
    this.id,
    this.trx,
    this.rate,
    this.pair,
  });

  OrderDetails.fromJson(dynamic json) {
    id = json['id']?.toString();
    trx = json['trx']?.toString();
    rate = json['rate']?.toString();
    pair = json['pair'] != null ? Pair.fromJson(json['pair']) : null;
  }

  String? id;
  String? trx;
  String? rate;
  Pair? pair;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['trx'] = trx;
    map['rate'] = rate;
    if (pair != null) {
      map['pair'] = pair?.toJson();
    }
    return map;
  }
}

class Pair {
  Pair({
    this.symbol,
    this.createdAt,
    this.market,
  });

  Pair.fromJson(dynamic json) {
    symbol = json['symbol']?.toString();
    createdAt = json['created_at']?.toString();
    market = json['market'] != null ? Market.fromJson(json['market']) : null;
  }

  String? symbol;
  String? createdAt;
  Market? market;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
    map['created_at'] = createdAt;
    if (market != null) {
      map['market'] = market?.toJson();
    }
    return map;
  }
}

class Market {
  Market({
    this.currency,
  });

  Market.fromJson(dynamic json) {
    currency = json['currency'] != null ? Currency.fromJson(json['currency']) : null;
  }

  Currency? currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (currency != null) {
      map['currency'] = currency?.toJson();
    }
    return map;
  }
}

class Currency {
  Currency({
    this.sign,
  });

  Currency.fromJson(dynamic json) {
    sign = json['sign']?.toString();
  }

  String? sign;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sign'] = sign;
    return map;
  }
}

class Message {
  Message({
    this.success,
    this.error,
  });

  Message.fromJson(dynamic json) {
    success = json['success'] != null ? List<String>.from(json['success']) : null;
    error = json['error'] != null ? List<String>.from(json['error']) : null;
  }

  List<String>? success;
  List<String>? error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['error'] = error;
    return map;
  }
}
