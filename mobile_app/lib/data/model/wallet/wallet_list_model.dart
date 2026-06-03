import 'dart:convert';
import 'package:vinance/data/model/wallet/single_wallet_details.dart';

WalletListModel walletListModelFromJson(String str) => WalletListModel.fromJson(json.decode(str));

String walletListModelToJson(WalletListModel data) => json.encode(data.toJson());

class WalletListModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  WalletListModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory WalletListModel.fromJson(Map<String, dynamic> json) => WalletListModel(
        status: json["status"]?.toString(),
        remark: json["remark"]?.toString(),
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "remark": remark,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({this.success, this.error});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] == null ? [] : List<String>.from(json["success"].map((x) => x.toString())),
        error: json["error"] == null ? [] : List<String>.from(json["error"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "error": error,
      };
}

class Data {
  Wallets? wallets;
  String? estimatedBalance;

  Data({this.wallets, this.estimatedBalance});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        wallets: json["wallets"] == null ? null : Wallets.fromJson(json["wallets"]),
        estimatedBalance: json["estimated_balance"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "wallets": wallets?.toJson(),
        "estimated_balance": estimatedBalance,
      };
}

class Wallets {
  List<WalletData>? data;
  String? nextPageUrl;

  Wallets({this.data, this.nextPageUrl});

  factory Wallets.fromJson(Map<String, dynamic> json) => Wallets(
        data: json["data"] == null ? [] : List<WalletData>.from(json["data"].map((x) => WalletData.fromJson(x))),
        nextPageUrl: json["next_page_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class WalletData {
  int? id;
  String? balance;
  String? walletType;
  Currency? currency;

  WalletData({
    this.id,
    this.balance,
    this.walletType,
    this.currency,
  });

  String get currencyId => currency?.id?.toString() ?? '';

  factory WalletData.fromJson(Map<String, dynamic> json) => WalletData(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        balance: json["balance"]?.toString(),
        walletType: json["wallet_type"]?.toString(),
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "balance": balance,
        "wallet_type": walletType,
        "currency": currency?.toJson(),
      };
}
