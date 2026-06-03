import 'dart:convert';

SingleWalletDetailsModel singleWalletDetailsModelFromJson(String str) => SingleWalletDetailsModel.fromJson(json.decode(str));

String singleWalletDetailsModelToJson(SingleWalletDetailsModel data) => json.encode(data.toJson());

class SingleWalletDetailsModel {
  String? status;
  String? remark;
  Message? message;
  Data? data;

  SingleWalletDetailsModel({
    this.status,
    this.remark,
    this.message,
    this.data,
  });

  factory SingleWalletDetailsModel.fromJson(Map<String, dynamic> json) => SingleWalletDetailsModel(
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
  SingleWalletWidgetCounter? widgetCounter;
  Transactions? transactions;
  Wallet? wallet;

  Data({this.widgetCounter, this.transactions, this.wallet});

  SingleWalletWidgetCounter? get widget => widgetCounter;
  Currency? get currency => wallet?.currency;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        widgetCounter: json["widget_counter"] == null ? (json["widget"] == null ? null : SingleWalletWidgetCounter.fromJson(json["widget"])) : SingleWalletWidgetCounter.fromJson(json["widget_counter"]),
        transactions: json["transactions"] == null ? null : Transactions.fromJson(json["transactions"]),
        wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "widget_counter": widgetCounter?.toJson(),
        "transactions": transactions?.toJson(),
        "wallet": wallet?.toJson(),
      };
}

class SingleWalletWidgetCounter {
  String? totalDeposit;
  String? totalWithdraw;
  String? totalTransfer;
  String? estimatedBalance;
  String? totalTransaction;
  String? totalTrade;
  String? openOrder;
  String? completedOrder;
  String? canceledOrder;
  String? totalOrder;

  SingleWalletWidgetCounter({
    this.totalDeposit,
    this.totalWithdraw,
    this.totalTransfer,
    this.estimatedBalance,
    this.totalTransaction,
    this.totalTrade,
    this.openOrder,
    this.completedOrder,
    this.canceledOrder,
    this.totalOrder,
  });

  factory SingleWalletWidgetCounter.fromJson(Map<String, dynamic> json) => SingleWalletWidgetCounter(
        totalDeposit: json["total_deposit"]?.toString(),
        totalWithdraw: json["total_withdraw"]?.toString(),
        totalTransfer: json["total_transfer"]?.toString(),
        estimatedBalance: json["estimated_balance"]?.toString(),
        totalTransaction: json["total_transaction"]?.toString() ?? json["total_transactions"]?.toString(),
        totalTrade: json["total_trade"]?.toString() ?? json["total_trades"]?.toString(),
        openOrder: json["open_order"]?.toString() ?? json["open_orders"]?.toString(),
        completedOrder: json["completed_order"]?.toString() ?? json["completed_orders"]?.toString(),
        canceledOrder: json["canceled_order"]?.toString() ?? json["canceled_orders"]?.toString(),
        totalOrder: json["total_order"]?.toString() ?? json["total_orders"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "total_deposit": totalDeposit,
        "total_withdraw": totalWithdraw,
        "total_transfer": totalTransfer,
        "estimated_balance": estimatedBalance,
        "total_transaction": totalTransaction,
        "total_trade": totalTrade,
        "open_order": openOrder,
        "completed_order": completedOrder,
        "canceled_order": canceledOrder,
        "total_order": totalOrder,
      };
}

class Transactions {
  List<TransactionSingleData>? data;
  String? nextPageUrl;

  Transactions({this.data, this.nextPageUrl});

  factory Transactions.fromJson(Map<String, dynamic> json) => Transactions(
        data: json["data"] == null ? [] : List<TransactionSingleData>.from(json["data"].map((x) => TransactionSingleData.fromJson(x))),
        nextPageUrl: json["next_page_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class TransactionSingleData {
  int? id;
  String? trxType;
  String? trx;
  String? amount;
  String? postBalance;
  String? details;
  String? remark;
  Wallet? wallet;

  TransactionSingleData({
    this.id,
    this.trxType,
    this.trx,
    this.amount,
    this.postBalance,
    this.details,
    this.remark,
    this.wallet,
  });

  factory TransactionSingleData.fromJson(Map<String, dynamic> json) => TransactionSingleData(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        trxType: json["trx_type"]?.toString(),
        trx: json["trx"]?.toString(),
        amount: json["amount"]?.toString(),
        postBalance: json["post_balance"]?.toString(),
        details: json["details"]?.toString(),
        remark: json["remark"]?.toString(),
        wallet: json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "trx_type": trxType,
        "trx": trx,
        "amount": amount,
        "post_balance": postBalance,
        "details": details,
        "remark": remark,
        "wallet": wallet?.toJson(),
      };
}

class Wallet {
  int? id;
  String? userType;
  String? walletType;
  String? balance;
  String? inOrder;
  Currency? currency;

  Wallet({
    this.id,
    this.userType,
    this.walletType,
    this.balance,
    this.inOrder,
    this.currency,
  });

  String totalBalance() {
    double bal = double.tryParse(balance ?? '0') ?? 0;
    double order = double.tryParse(inOrder ?? '0') ?? 0;
    return (bal + order).toString();
  }

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        userType: json["user_type"]?.toString(),
        walletType: json["wallet_type"]?.toString(),
        balance: json["balance"]?.toString(),
        inOrder: json["in_order"]?.toString(),
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_type": userType,
        "wallet_type": walletType,
        "balance": balance,
        "in_order": inOrder,
        "currency": currency?.toJson(),
      };
}

class Currency {
  int? id;
  String? symbol;
  String? name;
  String? sign;
  String? createdAt;
  String? imageUrl;
  String? rate;

  Currency({
    this.id,
    this.symbol,
    this.name,
    this.sign,
    this.createdAt,
    this.imageUrl,
    this.rate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        symbol: json["symbol"]?.toString(),
        name: json["name"]?.toString(),
        sign: json["sign"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        imageUrl: json["image_path"]?.toString() ?? json["image"]?.toString() ?? json["image_url"]?.toString(),
        rate: json["rate"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
        "sign": sign,
        "created_at": createdAt,
        "image_path": imageUrl,
        "rate": rate,
      };
}
