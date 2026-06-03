class User {
  int? id;
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  String? countryCode;
  String? mobile;
  String? refBy;
  String? status;
  String? ev;
  String? sv;
  String? tv;
  String? kv;
  String? profileComplete;
  String? image;
  String? ts;
  String? tsc;
  String? address;
  String? state;
  String? zip;
  String? city;
  String? country;

  User({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.countryCode,
    this.mobile,
    this.refBy,
    this.status,
    this.ev,
    this.sv,
    this.tv,
    this.kv,
    this.profileComplete,
    this.image,
    this.ts,
    this.tsc,
    this.address,
    this.state,
    this.zip,
    this.city,
    this.country,
  });

  String getFullName() => "${firstname ?? ''} ${lastname ?? ''}".trim();

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        firstname: json["firstname"]?.toString(),
        lastname: json["lastname"]?.toString(),
        username: json["username"]?.toString(),
        email: json["email"]?.toString(),
        countryCode: json["country_code"]?.toString(),
        mobile: json["mobile"]?.toString(),
        refBy: json["ref_by"]?.toString(),
        status: json["status"]?.toString(),
        ev: json["ev"]?.toString(),
        sv: json["sv"]?.toString(),
        tv: json["tv"]?.toString(),
        kv: json["kv"]?.toString(),
        profileComplete: json["profile_complete"]?.toString(),
        image: json["image"]?.toString(),
        ts: json["ts"]?.toString(),
        tsc: json["tsc"]?.toString(),
        address: json["address"]?.toString(),
        state: json["state"]?.toString(),
        zip: json["zip"]?.toString(),
        city: json["city"]?.toString(),
        country: json["country"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "username": username,
        "email": email,
        "country_code": countryCode,
        "mobile": mobile,
        "ref_by": refBy,
        "status": status,
        "ev": ev,
        "sv": sv,
        "tv": tv,
        "kv": kv,
        "profile_complete": profileComplete,
        "image": image,
        "ts": ts,
        "tsc": tsc,
        "address": address,
        "state": state,
        "zip": zip,
        "city": city,
        "country": country,
      };
}
