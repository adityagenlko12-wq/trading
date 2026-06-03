class GeneralSettingResponseModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  GeneralSettingResponseModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory GeneralSettingResponseModel.fromJson(Map<String, dynamic> json) => GeneralSettingResponseModel(
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
  GeneralSetting? generalSetting;
  String? socialLoginRedirect;

  Data({this.generalSetting, this.socialLoginRedirect});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        generalSetting: json["general_setting"] == null ? null : GeneralSetting.fromJson(json["general_setting"]),
        socialLoginRedirect: json["social_login_redirect"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "general_setting": generalSetting?.toJson(),
        "social_login_redirect": socialLoginRedirect,
      };
}

class GeneralSetting {
  String? siteName;
  String? curSym;
  String? curText;
  String? allowDecimalAfterNumber;
  String? otherUserTransferCharge;
  String? p2PTradeCharge;
  WalletTypes? walletTypes;
  String? securePassword;
  PusherConfig? pusherConfig;
  SocialiteCredentials? socialiteCredentials;
  String? metamaskLogin;
  String? activeTemplate;
  String? multiLanguage;
  String? agree;

  GeneralSetting({
    this.siteName,
    this.curSym,
    this.curText,
    this.allowDecimalAfterNumber,
    this.otherUserTransferCharge,
    this.p2PTradeCharge,
    this.walletTypes,
    this.securePassword,
    this.pusherConfig,
    this.socialiteCredentials,
    this.metamaskLogin,
    this.activeTemplate,
    this.multiLanguage,
    this.agree,
  });

  factory GeneralSetting.fromJson(Map<String, dynamic> json) => GeneralSetting(
        siteName: json["site_name"]?.toString(),
        curSym: json["cur_sym"]?.toString(),
        curText: json["cur_text"]?.toString(),
        allowDecimalAfterNumber: json["allow_decimal_after_number"]?.toString() ?? json["allow_decimal"]?.toString(),
        otherUserTransferCharge: json["other_user_transfer_charge"]?.toString(),
        p2PTradeCharge: json["p2p_trade_charge"]?.toString(),
        walletTypes: json["wallet_types"] == null ? null : WalletTypes.fromJson(json["wallet_types"]),
        securePassword: json["secure_password"]?.toString(),
        pusherConfig: json["pusher_config"] == null ? null : PusherConfig.fromJson(json["pusher_config"]),
        socialiteCredentials: json["socialite_credentials"] == null ? null : SocialiteCredentials.fromJson(json["socialite_credentials"]),
        metamaskLogin: json["metamask_login"]?.toString(),
        activeTemplate: json["active_template"]?.toString(),
        multiLanguage: json["multi_language"]?.toString(),
        agree: json["agree"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "site_name": siteName,
        "cur_sym": curSym,
        "cur_text": curText,
        "allow_decimal_after_number": allowDecimalAfterNumber,
        "other_user_transfer_charge": otherUserTransferCharge,
        "p2p_trade_charge": p2PTradeCharge,
        "wallet_types": walletTypes?.toJson(),
        "secure_password": securePassword,
        "pusher_config": pusherConfig?.toJson(),
        "socialite_credentials": socialiteCredentials?.toJson(),
        "metamask_login": metamaskLogin,
        "active_template": activeTemplate,
        "multi_language": multiLanguage,
        "agree": agree,
      };
}

class WalletTypes {
  WalletTypeConfig? spot;
  WalletTypeConfig? funding;

  WalletTypes({this.spot, this.funding});

  factory WalletTypes.fromJson(Map<String, dynamic> json) => WalletTypes(
        spot: json["spot"] == null ? null : WalletTypeConfig.fromJson(json["spot"]),
        funding: json["funding"] == null ? null : WalletTypeConfig.fromJson(json["funding"]),
      );

  Map<String, dynamic> toJson() => {
        "spot": spot?.toJson(),
        "funding": funding?.toJson(),
      };
}

class WalletTypeConfig {
  String? name;
  WalletTypeConfiguration? configuration;

  WalletTypeConfig({this.name, this.configuration});

  factory WalletTypeConfig.fromJson(Map<String, dynamic> json) => WalletTypeConfig(
        name: json["name"]?.toString(),
        configuration: json["configuration"] == null ? null : WalletTypeConfiguration.fromJson(json["configuration"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "configuration": configuration?.toJson(),
      };
}

class WalletTypeConfiguration {
  StatusConfig? transferOtherUser;
  StatusConfig? transferOtherWallet;
  StatusConfig? deposit;
  StatusConfig? withdraw;

  WalletTypeConfiguration({
    this.transferOtherUser,
    this.transferOtherWallet,
    this.deposit,
    this.withdraw,
  });

  factory WalletTypeConfiguration.fromJson(Map<String, dynamic> json) => WalletTypeConfiguration(
        transferOtherUser: json["transfer_other_user"] == null ? null : StatusConfig.fromJson(json["transfer_other_user"]),
        transferOtherWallet: json["transfer_other_wallet"] == null ? null : StatusConfig.fromJson(json["transfer_other_wallet"]),
        deposit: json["deposit"] == null ? null : StatusConfig.fromJson(json["deposit"]),
        withdraw: json["withdraw"] == null ? null : StatusConfig.fromJson(json["withdraw"]),
      );

  Map<String, dynamic> toJson() => {
        "transfer_other_user": transferOtherUser?.toJson(),
        "transfer_other_wallet": transferOtherWallet?.toJson(),
        "deposit": deposit?.toJson(),
        "withdraw": withdraw?.toJson(),
      };
}

class StatusConfig {
  String? status;

  StatusConfig({this.status});

  factory StatusConfig.fromJson(Map<String, dynamic> json) => StatusConfig(
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
      };
}

class PusherConfig {
  String? appKey;
  String? appCluster;

  PusherConfig({this.appKey, this.appCluster});

  String? get pusherAppKey => appKey;
  String? get pusherAppCluster => appCluster;

  factory PusherConfig.fromJson(Map<String, dynamic> json) => PusherConfig(
        appKey: json["app_key"]?.toString() ?? json["key"]?.toString(),
        appCluster: json["app_cluster"]?.toString() ?? json["cluster"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "app_key": appKey,
        "app_cluster": appCluster,
      };
}

class SocialiteCredentials {
  LinkedinSocial? linkedin;
  GoogleSocial? google;
  FacebookSocial? facebook;

  SocialiteCredentials({this.linkedin, this.google, this.facebook});

  factory SocialiteCredentials.fromJson(Map<String, dynamic> json) => SocialiteCredentials(
        linkedin: json["linkedin"] == null ? null : LinkedinSocial.fromJson(json["linkedin"]),
        google: json["google"] == null ? null : GoogleSocial.fromJson(json["google"]),
        facebook: json["facebook"] == null ? null : FacebookSocial.fromJson(json["facebook"]),
      );

  Map<String, dynamic> toJson() => {
        "linkedin": linkedin?.toJson(),
        "google": google?.toJson(),
        "facebook": facebook?.toJson(),
      };
}

class LinkedinSocial {
  String? clientId;
  String? clientSecret;
  String? status;

  LinkedinSocial({this.clientId, this.clientSecret, this.status});

  factory LinkedinSocial.fromJson(Map<String, dynamic> json) => LinkedinSocial(
        clientId: json["client_id"]?.toString(),
        clientSecret: json["client_secret"]?.toString(),
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "status": status,
      };
}

class GoogleSocial {
  String? clientId;
  String? clientSecret;
  String? status;

  GoogleSocial({this.clientId, this.clientSecret, this.status});

  factory GoogleSocial.fromJson(Map<String, dynamic> json) => GoogleSocial(
        clientId: json["client_id"]?.toString(),
        clientSecret: json["client_secret"]?.toString(),
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "status": status,
      };
}

class FacebookSocial {
  String? clientId;
  String? clientSecret;
  String? status;

  FacebookSocial({this.clientId, this.clientSecret, this.status});

  factory FacebookSocial.fromJson(Map<String, dynamic> json) => FacebookSocial(
        clientId: json["client_id"]?.toString(),
        clientSecret: json["client_secret"]?.toString(),
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "client_secret": clientSecret,
        "status": status,
      };
}
