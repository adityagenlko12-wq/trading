class SignUpModel {
  final String firstName;
  final String lastName;
  final String email;
  final bool agree;
  final String password;
  final String refer;

  SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.agree,
    required this.password,
    required this.refer,
  });

  Map<String, dynamic> toJson() => {
        "firstname": firstName,
        "lastname": lastName,
        "email": email,
        "agree": agree,
        "password": password,
        "reference": refer,
      };
}
