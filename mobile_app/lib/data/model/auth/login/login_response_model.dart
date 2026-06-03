import 'package:vinance/data/model/user/user_model.dart';

class LoginResponseModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  LoginResponseModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
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
  User? user;
  String? accessToken;
  String? tokenType;

  Data({this.user, this.accessToken, this.tokenType});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        accessToken: json["access_token"]?.toString(),
        tokenType: json["token_type"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "access_token": accessToken,
        "token_type": tokenType,
      };
}
