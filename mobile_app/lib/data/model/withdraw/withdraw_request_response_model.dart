import '../kyc/kyc_form_model.dart';

class WithdrawRequestResponseModel {
  WithdrawRequestResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  WithdrawRequestResponseModel.fromJson(dynamic json) {
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
    this.trx,
    this.user,
    this.form,
  });

  Data.fromJson(dynamic json) {
    trx = json['trx']?.toString();
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    form = json['form'] != null ? WithdrawForm.fromJson(json['form']) : null;
  }

  String? trx;
  UserData? user;
  WithdrawForm? form;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['trx'] = trx;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (form != null) {
      map['form'] = form?.toJson();
    }
    return map;
  }
}

class UserData {
  UserData({
    this.ts,
  });

  UserData.fromJson(dynamic json) {
    ts = json['ts']?.toString();
  }

  String? ts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ts'] = ts;
    return map;
  }
}

class WithdrawForm {
  WithdrawForm({
    this.list,
  });

  WithdrawForm.fromJson(dynamic json) {
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list?.add(KycFormModel.fromJson(v));
      });
    } else if (json['form_data'] != null) {
      list = [];
      json['form_data'].forEach((v) {
        list?.add(KycFormModel.fromJson(v));
      });
    }
  }

  List<KycFormModel>? list;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (list != null) {
      map['list'] = list?.map((v) => v.toJson()).toList();
    }
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
