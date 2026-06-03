import 'dart:convert';

WithdrawConfirmationResponseModel withdrawConfirmationResponseModelFromJson(String str) => WithdrawConfirmationResponseModel.fromJson(json.decode(str));

String withdrawConfirmationResponseModelToJson(WithdrawConfirmationResponseModel data) => json.encode(data.toJson());

class WithdrawConfirmationResponseModel {
  WithdrawConfirmationResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  WithdrawConfirmationResponseModel.fromJson(dynamic json) {
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
    this.withdraw,
  });

  Data.fromJson(dynamic json) {
    withdraw = json['withdraw'] != null ? WithdrawConfirmationData.fromJson(json['withdraw']) : null;
  }

  WithdrawConfirmationData? withdraw;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (withdraw != null) {
      map['withdraw'] = withdraw?.toJson();
    }
    return map;
  }
}

class WithdrawConfirmationData {
  WithdrawConfirmationData({
    this.id,
    this.amount,
    this.currency,
    this.charge,
    this.afterCharge,
    this.finalAmount,
    this.trx,
    this.method,
    this.status,
    this.createdAt,
  });

  WithdrawConfirmationData.fromJson(dynamic json) {
    id = json['id'];
    amount = json['amount']?.toString();
    currency = json['currency']?.toString();
    charge = json['charge']?.toString();
    afterCharge = json['after_charge']?.toString() ?? json['final_amo']?.toString();
    finalAmount = json['final_amount']?.toString() ?? json['final_amo']?.toString();
    trx = json['trx']?.toString();
    method = json['method'] != null ? WithdrawConfirmationMethod.fromJson(json['method']) : null;
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
  }

  int? id;
  String? amount;
  String? currency;
  String? charge;
  String? afterCharge;
  String? finalAmount;
  String? trx;
  WithdrawConfirmationMethod? method;
  String? status;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['amount'] = amount;
    map['currency'] = currency;
    map['charge'] = charge;
    map['after_charge'] = afterCharge;
    map['final_amount'] = finalAmount;
    map['trx'] = trx;
    if (method != null) {
      map['method'] = method?.toJson();
    }
    map['status'] = status;
    map['created_at'] = createdAt;
    return map;
  }
}

class WithdrawConfirmationMethod {
  WithdrawConfirmationMethod({
    this.name,
  });

  WithdrawConfirmationMethod.fromJson(dynamic json) {
    name = json['name']?.toString();
  }

  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
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
