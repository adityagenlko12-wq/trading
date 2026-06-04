class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final double balance;
  final String? referralCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.balance,
    this.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    double getDouble(dynamic val) {
      if (val == null) return 0.0;
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? json['firstname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      balance: getDouble(json['balance'] ?? json['wallet_balance']),
      referralCode: json['referral_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'mobile': mobile,
    'balance': balance,
    'referral_code': referralCode,
  };
}
