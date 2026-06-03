import 'dart:convert';
import 'package:vinance/data/model/wallet/single_wallet_details.dart';

TransactionResponseModel transactionResponseModelFromJson(String str) => TransactionResponseModel.fromJson(json.decode(str));

String transactionResponseModelToJson(TransactionResponseModel data) => json.encode(data.toJson());

class TransactionResponseModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  TransactionResponseModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) => TransactionResponseModel(
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
  Transactions? transactions;
  List<Remarks>? remarks;

  Data({this.transactions, this.remarks});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        transactions: json["transactions"] == null ? null : Transactions.fromJson(json["transactions"]),
        remarks: json["remarks"] == null ? [] : List<Remarks>.from(json["remarks"].map((x) => Remarks.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "transactions": transactions?.toJson(),
        "remarks": remarks == null ? [] : List<dynamic>.from(remarks!.map((x) => x.toJson())),
      };
}

class Transactions {
  List<TransactionSingleData>? data;
  String? nextPageUrl;

  Transactions({this.data, this.nextPageUrl});

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        data: json["data"] == null ? [] : List<TransactionSingleData>.from(json["data"].map((x) => TransactionSingleData.fromJson(x))),
        nextPageUrl: json["next_page_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class Remarks {
  int? id;
  String? remark;

  Remarks({this.id, this.remark});

  factory Remarks.fromJson(Map<String, dynamic> json) => Remarks(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        remark: json["remark"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "remark": remark,
      };
}
