class WithdrawMethodResponseModel {
  WithdrawMethodResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  WithdrawMethodResponseModel.fromJson(dynamic json) {
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
    this.withdrawMethod,
    this.currencies,
    this.spotWallets,
    this.fundingWallets,
  });

  Data.fromJson(dynamic json) {
    if (json['withdraw_method'] != null) {
      withdrawMethod = [];
      json['withdraw_method'].forEach((v) {
        withdrawMethod?.add(WithdrawMethod.fromJson(v));
      });
    } else if (json['methods'] != null) {
      withdrawMethod = [];
      json['methods'].forEach((v) {
        withdrawMethod?.add(WithdrawMethod.fromJson(v));
      });
    }
    if (json['currencies'] != null) {
      currencies = [];
      json['currencies'].forEach((v) {
        currencies?.add(WithdrawCurrency.fromJson(v));
      });
    }
    if (json['spot_wallets'] != null) {
      spotWallets = [];
      json['spot_wallets'].forEach((v) {
        spotWallets?.add(WithdrawWallet.fromJson(v));
      });
    }
    if (json['funding_wallets'] != null) {
      fundingWallets = [];
      json['funding_wallets'].forEach((v) {
        fundingWallets?.add(WithdrawWallet.fromJson(v));
      });
    }
  }

  List<WithdrawMethod>? withdrawMethod;
  List<WithdrawCurrency>? currencies;
  List<WithdrawWallet>? spotWallets;
  List<WithdrawWallet>? fundingWallets;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (withdrawMethod != null) {
      map['withdraw_method'] = withdrawMethod?.map((v) => v.toJson()).toList();
    }
    if (currencies != null) {
      map['currencies'] = currencies?.map((v) => v.toJson()).toList();
    }
    if (spotWallets != null) {
      map['spot_wallets'] = spotWallets?.map((v) => v.toJson()).toList();
    }
    if (fundingWallets != null) {
      map['funding_wallets'] = fundingWallets?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class WithdrawMethod {
  WithdrawMethod({
    this.id,
    this.name,
    this.minLimit,
    this.maxLimit,
    this.percentCharge,
    this.fixedCharge,
    this.rate,
    this.currency,
    this.description,
  });

  WithdrawMethod.fromJson(dynamic json) {
    id = json['id'];
    name = json['name']?.toString();
    minLimit = json['min_limit']?.toString() ?? json['min_amo']?.toString();
    maxLimit = json['max_limit']?.toString() ?? json['max_amo']?.toString();
    percentCharge = json['percent_charge']?.toString();
    fixedCharge = json['fixed_charge']?.toString();
    rate = json['rate']?.toString();
    currency = json['currency']?.toString();
    description = json['description']?.toString();
  }

  int? id;
  String? name;
  String? minLimit;
  String? maxLimit;
  String? percentCharge;
  String? fixedCharge;
  String? rate;
  String? currency;
  String? description;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['min_limit'] = minLimit;
    map['max_limit'] = maxLimit;
    map['percent_charge'] = percentCharge;
    map['fixed_charge'] = fixedCharge;
    map['rate'] = rate;
    map['currency'] = currency;
    map['description'] = description;
    return map;
  }
}

class WithdrawCurrency {
  WithdrawCurrency({
    this.id,
    this.symbol,
    this.name,
    this.imageUrl,
  });

  WithdrawCurrency.fromJson(dynamic json) {
    id = json['id']?.toString();
    symbol = json['symbol']?.toString();
    name = json['name']?.toString();
    imageUrl = json['image_path']?.toString() ?? json['image']?.toString() ?? json['image_url']?.toString();
  }

  String? id;
  String? symbol;
  String? name;
  String? imageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['symbol'] = symbol;
    map['name'] = name;
    map['image_path'] = imageUrl;
    return map;
  }
}

class WithdrawWallet {
  WithdrawWallet({
    this.currencyId,
    this.balance,
  });

  WithdrawWallet.fromJson(dynamic json) {
    currencyId = json['currency_id']?.toString();
    balance = json['balance']?.toString();
  }

  String? currencyId;
  String? balance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['currency_id'] = currencyId;
    map['balance'] = balance;
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
