import 'kyc_form_model.dart';

class KycResponseModel {
  KycResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  KycResponseModel.fromJson(dynamic json) {
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
    this.path,
    this.kycPendingData,
    this.form,
  });

  Data.fromJson(dynamic json) {
    path = json['path']?.toString();
    if (json['kyc_pending_data'] != null) {
      kycPendingData = [];
      json['kyc_pending_data'].forEach((v) {
        kycPendingData?.add(KycPendingData.fromJson(v));
      });
    }
    form = json['form'] != null ? KycForm.fromJson(json['form']) : null;
  }

  String? path;
  List<KycPendingData>? kycPendingData;
  KycForm? form;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['path'] = path;
    if (kycPendingData != null) {
      map['kyc_pending_data'] = kycPendingData?.map((v) => v.toJson()).toList();
    }
    if (form != null) {
      map['form'] = form?.toJson();
    }
    return map;
  }
}

class KycForm {
  KycForm({
    this.list,
  });

  KycForm.fromJson(dynamic json) {
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

class KycPendingData {
  KycPendingData({
    this.name,
    this.value,
    this.type,
  });

  KycPendingData.fromJson(dynamic json) {
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
