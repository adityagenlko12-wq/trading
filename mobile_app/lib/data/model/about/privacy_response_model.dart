class PrivacyResponseModel {
  PrivacyResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  PrivacyResponseModel.fromJson(dynamic json) {
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
    this.policyPages,
  });

  Data.fromJson(dynamic json) {
    if (json['policy_pages'] != null) {
      policyPages = [];
      json['policy_pages'].forEach((v) {
        policyPages?.add(PolicyPages.fromJson(v));
      });
    }
  }

  List<PolicyPages>? policyPages;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (policyPages != null) {
      map['policy_pages'] = policyPages?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PolicyPages {
  PolicyPages({
    this.id,
    this.dataKeys,
    this.dataValues,
  });

  PolicyPages.fromJson(dynamic json) {
    id = json['id'];
    dataKeys = json['data_keys']?.toString();
    dataValues = json['data_values'] != null ? PrivacyDataValues.fromJson(json['data_values']) : null;
  }

  int? id;
  String? dataKeys;
  PrivacyDataValues? dataValues;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['data_keys'] = dataKeys;
    if (dataValues != null) {
      map['data_values'] = dataValues?.toJson();
    }
    return map;
  }
}

class PrivacyDataValues {
  PrivacyDataValues({
    this.title,
    this.details,
  });

  PrivacyDataValues.fromJson(dynamic json) {
    title = json['title']?.toString();
    details = json['details']?.toString();
  }

  String? title;
  String? details;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['details'] = details;
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
