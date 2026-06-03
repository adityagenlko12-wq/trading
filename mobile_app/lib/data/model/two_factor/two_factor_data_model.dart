import 'dart:convert';

TwoFactorCodeModel twoFactorCodeModelFromJson(String str) => TwoFactorCodeModel.fromJson(json.decode(str));

String twoFactorCodeModelToJson(TwoFactorCodeModel data) => json.encode(data.toJson());

class TwoFactorCodeModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  TwoFactorCodeModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory TwoFactorCodeModel.fromJson(Map<String, dynamic> json) => TwoFactorCodeModel(
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
  String? qrCodeUrl;
  String? secret;

  Data({
    this.qrCodeUrl,
    this.secret,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        qrCodeUrl: json["qr_code_url"]?.toString(),
        secret: json["secret"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "qr_code_url": qrCodeUrl,
        "secret": secret,
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
