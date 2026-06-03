import 'dart:convert';

TransferResponseModel transferResponseModelFromJson(String str) => TransferResponseModel.fromJson(json.decode(str));

class TransferResponseModel {
  TransferResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  TransferResponseModel.fromJson(dynamic json) {
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
    this.amount,
    this.chargeAmount,
    this.transaction,
    this.toWallet,
  });

  Data.fromJson(dynamic json) {
    amount = json['amount']?.toString();
    chargeAmount = json['charge_amount']?.toString() ?? json['charge']?.toString();
    transaction = json['transaction'] != null ? TransactionData.fromJson(json['transaction']) : null;
    toWallet = json['to_wallet'] != null ? ToWallet.fromJson(json['to_wallet']) : null;
  }

  String? amount;
  String? chargeAmount;
  TransactionData? transaction;
  ToWallet? toWallet;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['amount'] = amount;
    map['charge_amount'] = chargeAmount;
    if (transaction != null) {
      map['transaction'] = transaction?.toJson();
    }
    if (toWallet != null) {
      map['to_wallet'] = toWallet?.toJson();
    }
    return map;
  }
}

class TransactionData {
  TransactionData({
    this.postBalance,
    this.trx,
    this.createdAt,
    this.details,
  });

  TransactionData.fromJson(dynamic json) {
    postBalance = json['post_balance']?.toString();
    trx = json['trx']?.toString();
    createdAt = json['created_at']?.toString();
    details = json['details']?.toString();
  }

  String? postBalance;
  String? trx;
  String? createdAt;
  String? details;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['post_balance'] = postBalance;
    map['trx'] = trx;
    map['created_at'] = createdAt;
    map['details'] = details;
    return map;
  }
}

class ToWallet {
  ToWallet({
    this.walletType,
  });

  ToWallet.fromJson(dynamic json) {
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
