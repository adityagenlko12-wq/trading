import 'dart:convert';

SupportTicketViewResponseModel supportTicketViewResponseModelFromJson(String str) => SupportTicketViewResponseModel.fromJson(json.decode(str));

String supportTicketViewResponseModelToJson(SupportTicketViewResponseModel data) => json.encode(data.toJson());

class SupportTicketViewResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  SupportTicketViewResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory SupportTicketViewResponseModel.fromJson(Map<String, dynamic> json) => SupportTicketViewResponseModel(
        remark: json["remark"],
        status: json["status"],
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "remark": remark,
        "status": status,
        "message": message?.toJson(),
        "data": data?.toJson(),
      };
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({
    this.success,
    this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: json["success"] == null ? null : List<String>.from(json["success"].map((x) => x.toString())),
        error: json["error"] == null ? null : List<String>.from(json["error"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "success": success == null ? null : List<dynamic>.from(success!.map((x) => x)),
        "error": error == null ? null : List<dynamic>.from(error!.map((x) => x)),
      };
}

class Data {
  MyTickets? myTickets;
  List<SupportMessage>? myMessages;

  Data({
    this.myTickets,
    this.myMessages,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        myTickets: json["my_tickets"] == null ? null : MyTickets.fromJson(json["my_tickets"]),
        myMessages: json["my_messages"] == null
            ? []
            : List<SupportMessage>.from(json["my_messages"].map((x) => SupportMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "my_tickets": myTickets?.toJson(),
        "my_messages": myMessages == null ? [] : List<dynamic>.from(myMessages!.map((x) => x.toJson())),
      };
}

class MyTickets {
  int? id;
  String? name;
  String? email;
  String? ticket;
  String? subject;
  String? status;
  String? priority;
  String? createdAt;
  String? updatedAt;

  MyTickets({
    this.id,
    this.name,
    this.email,
    this.ticket,
    this.subject,
    this.status,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory MyTickets.fromJson(Map<String, dynamic> json) => MyTickets(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        ticket: json["ticket"]?.toString(),
        subject: json["subject"]?.toString(),
        status: json["status"]?.toString(),
        priority: json["priority"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "ticket": ticket,
        "subject": subject,
        "status": status,
        "priority": priority,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class SupportMessage {
  int? id;
  String? supportticketId;
  String? adminId;
  String? message;
  String? createdAt;
  String? updatedAt;
  Admin? admin;
  MyTickets? ticket;
  List<SupportAttachment>? attachments;

  SupportMessage({
    this.id,
    this.supportticketId,
    this.adminId,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.admin,
    this.ticket,
    this.attachments,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) => SupportMessage(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        supportticketId: json["supportticket_id"]?.toString(),
        adminId: json["admin_id"]?.toString(),
        message: json["message"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        admin: json["admin"] == null ? null : Admin.fromJson(json["admin"]),
        ticket: json["ticket"] == null ? null : MyTickets.fromJson(json["ticket"]),
        attachments: json["attachments"] == null
            ? []
            : List<SupportAttachment>.from(json["attachments"].map((x) => SupportAttachment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "supportticket_id": supportticketId,
        "admin_id": adminId,
        "message": message,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "admin": admin?.toJson(),
        "ticket": ticket?.toJson(),
        "attachments": attachments == null ? [] : List<dynamic>.from(attachments!.map((x) => x.toJson())),
      };
}

class Admin {
  int? id;
  String? name;
  String? username;

  Admin({
    this.id,
    this.name,
    this.username,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        name: json["name"]?.toString(),
        username: json["username"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
      };
}

class SupportAttachment {
  int? id;
  String? supportMessageId;
  String? attachment;
  String? createdAt;
  String? updatedAt;

  SupportAttachment({
    this.id,
    this.supportMessageId,
    this.attachment,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportAttachment.fromJson(Map<String, dynamic> json) => SupportAttachment(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        supportMessageId: json["support_message_id"]?.toString(),
        attachment: json["attachment"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "support_message_id": supportMessageId,
        "attachment": attachment,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
