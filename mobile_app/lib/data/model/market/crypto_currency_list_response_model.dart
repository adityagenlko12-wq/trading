import 'dart:convert';

CryptoCurrencyListResponseModel cryptoCurrencyListResponseModelFromJson(String str) => CryptoCurrencyListResponseModel.fromJson(json.decode(str));

String cryptoCurrencyListResponseModelToJson(CryptoCurrencyListResponseModel data) => json.encode(data.toJson());

class CryptoCurrencyListResponseModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  CryptoCurrencyListResponseModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory CryptoCurrencyListResponseModel.fromJson(Map<String, dynamic> json) => CryptoCurrencyListResponseModel(
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
  List<CryptoCurrencyData>? currencies;

  Data({this.currencies});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currencies: json["currencies"] == null ? [] : List<CryptoCurrencyData>.from(json["currencies"].map((x) => CryptoCurrencyData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "currencies": currencies == null ? [] : List<dynamic>.from(currencies!.map((x) => x.toJson())),
      };
}

class CryptoCurrencyData {
  int? id;
  String? name;
  String? symbol;

  CryptoCurrencyData({
    this.id,
    this.name,
    this.symbol,
  });

  factory CryptoCurrencyData.fromJson(Map<String, dynamic> json) => CryptoCurrencyData(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        symbol: json["symbol"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "symbol": symbol,
      };
}
