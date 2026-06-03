import 'dart:convert';

CountryModel countryModelFromJson(String str) => CountryModel.fromJson(json.decode(str));

String countryModelToJson(CountryModel data) => json.encode(data.toJson());

class CountryModel {
  String? status;
  String? remark;
  Data? data;

  CountryModel({
    this.status,
    this.remark,
    this.data,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        status: json["status"]?.toString(),
        remark: json["remark"]?.toString(),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "remark": remark,
        "data": data?.toJson(),
      };
}

class Data {
  List<Countries>? countries;

  Data({this.countries});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        countries: json["countries"] == null
            ? []
            : List<Countries>.from(json["countries"].map((x) => Countries.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "countries": countries == null ? [] : List<dynamic>.from(countries!.map((x) => x.toJson())),
      };
}

class Countries {
  String? country;
  String? countryCode;
  String? dialCode;

  Countries({
    this.country,
    this.countryCode,
    this.dialCode,
  });

  factory Countries.fromJson(Map<String, dynamic> json) => Countries(
        country: json["country"]?.toString(),
        countryCode: json["country_code"]?.toString(),
        dialCode: json["dial_code"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "country_code": countryCode,
        "dial_code": dialCode,
      };
}
