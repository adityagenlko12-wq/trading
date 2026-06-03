// To parse this JSON data, do
//
//     final metamaskGetMessageResponseModel = metamaskGetMessageResponseModelFromJson(jsonString);

import 'dart:convert';

import '../../model/auth/login/login_response_model.dart';

MetamaskGetMessageResponseModel metamaskGetMessageResponseModelFromJson(String str) => MetamaskGetMessageResponseModel.fromJson(json.decode(str));

String metamaskGetMessageResponseModelToJson(MetamaskGetMessageResponseModel data) => json.encode(data.toJson());

class MetamaskGetMessageResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  MetamaskGetMessageResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory MetamaskGetMessageResponseModel.fromJson(Map<String, dynamic> json) => MetamaskGetMessageResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "status": status,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Data {
  String? wallet;
  String? nonce;
  String? message;

  Data({
    this.wallet,
    this.nonce,
    this.message,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        wallet: json["wallet"].toString(),
        nonce: json["nonce"].toString(),
        message: json["message"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "wallet": wallet,
        "nonce": nonce,
        "message": message,
      };
}
