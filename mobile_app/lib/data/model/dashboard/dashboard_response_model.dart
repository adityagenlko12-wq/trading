import 'dart:convert';
import 'package:vinance/data/model/user/user_model.dart';

DashboardResponseModel dashboardResponseModelFromJson(String str) => DashboardResponseModel.fromJson(json.decode(str));

String dashboardResponseModelToJson(DashboardResponseModel data) => json.encode(data.toJson());

class DashboardResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  DashboardResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) => DashboardResponseModel(
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
  User? user;
  String? estimatedBalance;

  Data({
    this.user,
    this.estimatedBalance,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        estimatedBalance: json["estimated_balance"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "estimated_balance": estimatedBalance,
      };
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({
    this.success,
    this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] == null ? null : List<String>.from(json["success"].map((x) => x.toString())),
        error: json["error"] == null ? null : List<String>.from(json["error"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : List<dynamic>.from(success!.map((x) => x)),
        "error": error == null ? null : List<dynamic>.from(error!.map((x) => x)),
      };
}
