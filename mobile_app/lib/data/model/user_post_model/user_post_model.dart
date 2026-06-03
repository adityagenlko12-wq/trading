import 'dart:io';

class UserPostModel {
  final String firstname;
  final String lastName;
  final String mobile;
  final String email;
  final String username;
  final String countryCode;
  final String country;
  final String mobileCode;
  final File? image;
  final String state;
  final String city;
  final String address;
  final String zip;

  UserPostModel({
    required this.firstname,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.username,
    required this.countryCode,
    required this.country,
    required this.mobileCode,
    this.image,
    required this.state,
    required this.city,
    required this.address,
    required this.zip,
  });

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "lastname": lastName,
        "mobile": mobile,
        "email": email,
        "username": username,
        "country_code": countryCode,
        "country": country,
        "mobile_code": mobileCode,
        "state": state,
        "city": city,
        "address": address,
        "zip": zip,
      };
}
