import 'dart:convert';

OrderHistoryPageResponseModel orderHistoryPageResponseModelFromJson(String str) => OrderHistoryPageResponseModel.fromJson(json.decode(str));

class OrderHistoryPageResponseModel {
  OrderHistoryPageResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  OrderHistoryPageResponseModel.fromJson(dynamic json) {
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
    this.orders,
  });

  Data.fromJson(dynamic json) {
    orders = json['orders'] != null ? Orders.fromJson(json['orders']) : null;
  }

  Orders? orders;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (orders != null) {
      map['orders'] = orders?.toJson();
    }
    return map;
  }
}

class Orders {
  Orders({
    this.currentPage,
    this.data,
    this.nextPageUrl,
  });

  Orders.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(OrderHistoryPageResponseModelData.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
  }

  int? currentPage;
  List<OrderHistoryPageResponseModelData>? data;
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

class OrderHistoryPageResponseModelData {
  OrderHistoryPageResponseModelData({
    this.id,
    this.amount,
    this.rate,
    this.orderSide,
    this.orderType,
    this.status,
    this.trx,
    this.total,
    this.filledAmount,
    this.createdAt,
    this.pair,
  });

  OrderHistoryPageResponseModelData.fromJson(dynamic json) {
    id = json['id']?.toString();
    amount = json['amount']?.toString();
    rate = json['rate']?.toString();
    orderSide = json['order_side']?.toString() ?? json['side']?.toString();
    orderType = json['order_type']?.toString() ?? json['type']?.toString();
    status = json['status']?.toString();
    trx = json['trx']?.toString();
    total = json['total']?.toString();
    filledAmount = json['filled_amount']?.toString() ?? json['filled_amo']?.toString();
    createdAt = json['created_at']?.toString();
    pair = json['pair'] != null ? Pair.fromJson(json['pair']) : null;
  }

  String? id;
  String? amount;
  String? rate;
  String? orderSide;
  String? orderType;
  String? status;
  String? trx;
  String? total;
  String? filledAmount;
  String? createdAt;
  Pair? pair;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['amount'] = amount;
    map['rate'] = rate;
    map['order_side'] = orderSide;
    map['order_type'] = orderType;
    map['status'] = status;
    map['trx'] = trx;
    map['total'] = total;
    map['filled_amount'] = filledAmount;
    map['created_at'] = createdAt;
    if (pair != null) {
      map['pair'] = pair?.toJson();
    }
    return map;
  }
}

class Pair {
  Pair({
    this.symbol,
  });

  Pair.fromJson(dynamic json) {
    symbol = json['symbol']?.toString();
  }

  String? symbol;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
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
