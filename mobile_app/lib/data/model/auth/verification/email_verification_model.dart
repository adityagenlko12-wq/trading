class EmailVerificationModel {
  int? code;
  String? status;
  String? remark;
  Message? message;
  Data? data;

  EmailVerificationModel({
    this.code,
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  void setCode(int codeVal) {
    code = codeVal;
  }

  factory EmailVerificationModel.fromJson(Map<String, dynamic> json) => EmailVerificationModel(
        code: json["code"] != null ? int.tryParse(json["code"].toString()) : null,
        status: json["status"]?.toString(),
        remark: json["remark"]?.toString(),
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
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
  String? email;
  String? code;
  String? token;

  Data({this.email, this.code, this.token});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        email: json["email"]?.toString(),
        code: json["code"]?.toString(),
        token: json["token"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "code": code,
        "token": token,
      };
}
