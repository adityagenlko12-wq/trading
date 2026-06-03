class DepositHistoryResponseModel {
  DepositHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  DepositHistoryResponseModel.fromJson(dynamic json) {
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
    this.deposits,
  });

  Data.fromJson(dynamic json) {
    deposits = json['deposits'] != null ? Deposits.fromJson(json['deposits']) : null;
  }

  Deposits? deposits;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (deposits != null) {
      map['deposits'] = deposits?.toJson();
    }
    return map;
  }
}

class Deposits {
  Deposits({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  Deposits.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(DepositHistoryListModel.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
    perPage = json['per_page']?.toString();
    to = json['to'];
    total = json['total']?.toString();
  }

  int? currentPage;
  List<DepositHistoryListModel>? data;
  String? nextPageUrl;
  String? path;
  String? perPage;
  int? to;
  String? total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['next_page_url'] = nextPageUrl;
    map['path'] = path;
    map['per_page'] = perPage;
    map['to'] = to;
    map['total'] = total;
    return map;
  }
}

class DepositHistoryListModel {
  DepositHistoryListModel({
    this.id,
    this.userId,
    this.methodCode,
    this.amount,
    this.methodCurrency,
    this.charge,
    this.rate,
    this.finalAmount,
    this.trx,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.gateway,
  });

  DepositHistoryListModel.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id']?.toString();
    methodCode = json['method_code']?.toString();
    amount = json['amount']?.toString();
    methodCurrency = json['method_currency']?.toString();
    charge = json['charge']?.toString();
    rate = json['rate']?.toString();
    finalAmount = json['final_amo']?.toString() ?? json['final_amount']?.toString();
    trx = json['trx']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    gateway = json['gateway'] != null ? Gateway.fromJson(json['gateway']) : null;
  }

  int? id;
  String? userId;
  String? methodCode;
  String? amount;
  String? methodCurrency;
  String? charge;
  String? rate;
  String? finalAmount;
  String? trx;
  String? status;
  String? createdAt;
  String? updatedAt;
  Wallet? wallet;
  Gateway? gateway;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['method_code'] = methodCode;
    map['amount'] = amount;
    map['method_currency'] = methodCurrency;
    map['charge'] = charge;
    map['rate'] = rate;
    map['final_amount'] = finalAmount;
    map['trx'] = trx;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (wallet != null) {
      map['wallet'] = wallet?.toJson();
    }
    if (gateway != null) {
      map['gateway'] = gateway?.toJson();
    }
    return map;
  }
}

class Gateway {
  Gateway({
    this.name,
  });

  Gateway.fromJson(dynamic json) {
    name = json['name']?.toString();
  }

  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }
}

class Wallet {
  Wallet({
    this.walletType,
  });

  Wallet.fromJson(dynamic json) {
    walletType = json['wallet_type']?.toString();
  }

  String? walletType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['wallet_type'] = walletType;
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
