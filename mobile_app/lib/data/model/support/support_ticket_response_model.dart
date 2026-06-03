class SupportTicketListResponseModel {
  SupportTicketListResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  SupportTicketListResponseModel.fromJson(dynamic json) {
    remark = json['remark']?.toString();
    status = json['status']?.toString();
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  String? remark;
  String? status;
  Message? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = remark;
    map['status'] = status;
    if (message != null) {
      map['message'] = message?.toJson();
    }
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data({
    this.tickets,
  });

  Data.fromJson(dynamic json) {
    tickets = json['tickets'] != null ? Tickets.fromJson(json['tickets']) : null;
  }

  Tickets? tickets;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (tickets != null) {
      map['tickets'] = tickets?.toJson();
    }
    return map;
  }
}

class Tickets {
  Tickets({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.path,
  });

  Tickets.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(TicketData.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
  }

  int? currentPage;
  List<TicketData>? data;
  String? nextPageUrl;
  String? path;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['next_page_url'] = nextPageUrl;
    map['path'] = path;
    return map;
  }
}

class TicketData {
  TicketData({
    this.id,
    this.ticket,
    this.subject,
    this.status,
    this.priority,
    this.createdAt,
  });

  TicketData.fromJson(dynamic json) {
    id = json['id'];
    ticket = json['ticket']?.toString();
    subject = json['subject']?.toString();
    status = json['status']?.toString();
    priority = json['priority']?.toString();
    createdAt = json['created_at']?.toString();
  }

  int? id;
  String? ticket;
  String? subject;
  String? status;
  String? priority;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['ticket'] = ticket;
    map['subject'] = subject;
    map['status'] = status;
    map['priority'] = priority;
    map['created_at'] = createdAt;
    return map;
  }
}

class Message {
  Message({
    this.success,
    this.error,
  });

  Message.fromJson(dynamic json) {
    success = json['success'] != null ? List<String>.from(json['success']) : null;
    error = json['error'] != null ? List<String>.from(json['error']) : null;
  }

  List<String>? success;
  List<String>? error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['error'] = error;
    return map;
  }
}
