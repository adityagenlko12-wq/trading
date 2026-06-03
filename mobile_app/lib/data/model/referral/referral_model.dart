import 'dart:convert';

ReferralScreenResponseModel referralScreenResponseModelFromJson(String str) => ReferralScreenResponseModel.fromJson(json.decode(str));

class ReferralScreenResponseModel {
  ReferralScreenResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  ReferralScreenResponseModel.fromJson(dynamic json) {
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
    this.referrals,
  });

  Data.fromJson(dynamic json) {
    referrals = json['referrals'] != null ? AllReferral.fromJson(json['referrals']) : null;
  }

  AllReferral? referrals;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (referrals != null) {
      map['referrals'] = referrals?.toJson();
    }
    return map;
  }
}

class AllReferral {
  AllReferral({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.allReferrals,
  });

  AllReferral.fromJson(dynamic json) {
    id = json['id'];
    firstname = json['firstname']?.toString();
    lastname = json['lastname']?.toString();
    username = json['username']?.toString();
    if (json['all_referrals'] != null) {
      allReferrals = [];
      json['all_referrals'].forEach((v) {
        allReferrals?.add(AllReferral.fromJson(v));
      });
    }
  }

  int? id;
  String? firstname;
  String? lastname;
  String? username;
  List<AllReferral>? allReferrals;

  String getFullName() {
    String f = firstname ?? '';
    String l = lastname ?? '';
    if (f.isEmpty && l.isEmpty) {
      return username ?? '';
    }
    return '$f $l'.trim();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['firstname'] = firstname;
    map['lastname'] = lastname;
    map['username'] = username;
    if (allReferrals != null) {
      map['all_referrals'] = allReferrals?.map((v) => v.toJson()).toList();
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
