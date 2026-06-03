class DepositMethodResponseModel {
  DepositMethodResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  DepositMethodResponseModel.fromJson(dynamic json) {
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
    this.methods,
    this.currencies,
  });

  Data.fromJson(dynamic json) {
    if (json['methods'] != null) {
      methods = [];
      json['methods'].forEach((v) {
        methods?.add(DepositMethod.fromJson(v));
      });
    }
    if (json['currencies'] != null) {
      currencies = [];
      json['currencies'].forEach((v) {
        currencies?.add(DepositCurrency.fromJson(v));
      });
    }
  }

  List<DepositMethod>? methods;
  List<DepositCurrency>? currencies;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (methods != null) {
      map['methods'] = methods?.map((v) => v.toJson()).toList();
    }
    if (currencies != null) {
      map['currencies'] = currencies?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class DepositMethod {
  DepositMethod({
    this.id,
    this.name,
    this.currency,
    this.minAmount,
    this.maxAmount,
    this.percentCharge,
    this.fixedCharge,
    this.rate,
    this.methodCode,
  });

  DepositMethod.fromJson(dynamic json) {
    id = json['id'];
    name = json['name']?.toString();
    currency = json['currency']?.toString();
    minAmount = json['min_amount']?.toString() ?? json['min_amo']?.toString();
    maxAmount = json['max_amount']?.toString() ?? json['max_amo']?.toString();
    percentCharge = json['percent_charge']?.toString();
    fixedCharge = json['fixed_charge']?.toString();
    rate = json['rate']?.toString();
    methodCode = json['method_code']?.toString();
  }

  int? id;
  String? name;
  String? currency;
  String? minAmount;
  String? maxAmount;
  String? percentCharge;
  String? fixedCharge;
  String? rate;
  String? methodCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['currency'] = currency;
    map['min_amount'] = minAmount;
    map['max_amount'] = maxAmount;
    map['percent_charge'] = percentCharge;
    map['fixed_charge'] = fixedCharge;
    map['rate'] = rate;
    map['method_code'] = methodCode;
    return map;
  }
}

class DepositCurrency {
  DepositCurrency({
    this.id,
    this.symbol,
    this.name,
    this.imageUrl,
  });

  DepositCurrency.fromJson(dynamic json) {
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
