class WithdrawHistoryResponseModel {
  WithdrawHistoryResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  WithdrawHistoryResponseModel.fromJson(dynamic json) {
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
    this.withdrawals,
    this.imagePath,
  });

  Data.fromJson(dynamic json) {
    withdrawals = json['withdrawals'] != null ? Withdrawals.fromJson(json['withdrawals']) : null;
    imagePath = json['image_path']?.toString() ?? json['path']?.toString();
  }

  Withdrawals? withdrawals;
  String? imagePath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (withdrawals != null) {
      map['withdrawals'] = withdrawals?.toJson();
    }
    map['image_path'] = imagePath;
    return map;
  }
}

class Withdrawals {
  Withdrawals({
    this.currentPage,
    this.data,
    this.nextPageUrl,
  });

  Withdrawals.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(WithdrawListModel.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
  }

  int? currentPage;
  List<WithdrawListModel>? data;
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

class WithdrawListModel {
  WithdrawListModel({
    this.id,
    this.methodId,
    this.userId,
    this.amount,
    this.currency,
    this.rate,
    this.charge,
    this.trx,
    this.status,
    this.afterCharge,
    this.withdrawInformation,
    this.createdAt,
    this.updatedAt,
    this.wallet,
    this.method,
  });

  WithdrawListModel.fromJson(dynamic json) {
    id = json['id'];
    methodId = json['method_id']?.toString();
    userId = json['user_id']?.toString();
    amount = json['amount']?.toString();
    currency = json['currency']?.toString();
    rate = json['rate']?.toString();
    charge = json['charge']?.toString();
    trx = json['trx']?.toString();
    status = json['status']?.toString();
    afterCharge = json['after_charge']?.toString() ?? json['final_amo']?.toString();
    if (json['withdraw_information'] != null) {
      withdrawInformation = [];
      json['withdraw_information'].forEach((v) {
        withdrawInformation?.add(WithdrawInformationData.fromJson(v));
      });
    } else if (json['user_data'] != null) {
      withdrawInformation = [];
      json['user_data'].forEach((v) {
        withdrawInformation?.add(WithdrawInformationData.fromJson(v));
      });
    }
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    wallet = json['wallet'] != null ? Wallet.fromJson(json['wallet']) : null;
    method = json['method'] != null ? WithdrawMethod.fromJson(json['method']) : null;
  }

  int? id;
  String? methodId;
  String? userId;
  String? amount;
  String? currency;
  String? rate;
  String? charge;
  String? trx;
  String? status;
  String? afterCharge;
  List<WithdrawInformationData>? withdrawInformation;
  String? createdAt;
  String? updatedAt;
  Wallet? wallet;
  WithdrawMethod? method;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['method_id'] = methodId;
    map['user_id'] = userId;
    map['amount'] = amount;
    map['currency'] = currency;
    map['rate'] = rate;
    map['charge'] = charge;
    map['trx'] = trx;
    map['status'] = status;
    map['after_charge'] = afterCharge;
    if (withdrawInformation != null) {
      map['withdraw_information'] = withdrawInformation?.map((v) => v.toJson()).toList();
    }
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (wallet != null) {
      map['wallet'] = wallet?.toJson();
    }
    if (method != null) {
      map['method'] = method?.toJson();
    }
    return map;
  }
}

class WithdrawMethod {
  WithdrawMethod({
    this.name,
    this.currency,
  });

  WithdrawMethod.fromJson(dynamic json) {
    name = json['name']?.toString();
    currency = json['currency']?.toString();
  }

  String? name;
  String? currency;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['currency'] = currency;
    return map;
  }
}

class WithdrawInformationData {
  WithdrawInformationData({
    this.name,
    this.value,
    this.type,
  });

  WithdrawInformationData.fromJson(dynamic json) {
    name = json['name']?.toString();
    value = json['value']?.toString();
    type = json['type']?.toString();
  }

  String? name;
  String? value;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['value'] = value;
    map['type'] = type;
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
