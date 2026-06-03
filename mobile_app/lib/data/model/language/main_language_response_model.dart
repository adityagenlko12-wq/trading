class MainLanguageResponseModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  MainLanguageResponseModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory MainLanguageResponseModel.fromJson(Map<String, dynamic> json) => MainLanguageResponseModel(
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
  List<Language>? languages;
  String? imagePath;

  Data({this.languages, this.imagePath});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        languages: json["languages"] == null ? [] : List<Language>.from(json["languages"].map((x) => Language.fromJson(x))),
        imagePath: json["image_path"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x.toJson())),
        "image_path": imagePath,
      };
}

class Language {
  int? id;
  String? name;
  String? code;
  String? image;
  String? isDefault;

  Language({
    this.id,
    this.name,
    this.code,
    this.image,
    this.isDefault,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        code: json["code"]?.toString(),
        image: json["image"]?.toString(),
        isDefault: json["is_default"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "image": image,
        "is_default": isDefault,
      };
}
