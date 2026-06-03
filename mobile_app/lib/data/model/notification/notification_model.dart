import 'dart:convert';

NotificationResponseModel notificationResponseModelFromJson(String str) => NotificationResponseModel.fromJson(json.decode(str));

class NotificationResponseModel {
  NotificationResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  NotificationResponseModel.fromJson(dynamic json) {
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
    this.notifications,
  });

  Data.fromJson(dynamic json) {
    notifications = json['notifications'] != null ? Notifications.fromJson(json['notifications']) : null;
  }

  Notifications? notifications;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (notifications != null) {
      map['notifications'] = notifications?.toJson();
    }
    return map;
  }
}

class Notifications {
  Notifications({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.path,
  });

  Notifications.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(NotificationsData.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
  }

  int? currentPage;
  List<NotificationsData>? data;
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

class NotificationsData {
  NotificationsData({
    this.id,
    this.notificationType,
    this.subject,
    this.message,
    this.createdAt,
  });

  NotificationsData.fromJson(dynamic json) {
    id = json['id'];
    notificationType = json['notification_type']?.toString() ?? json['notification_type_id']?.toString();
    subject = json['subject']?.toString();
    message = json['message']?.toString();
    createdAt = json['created_at']?.toString();
  }

  int? id;
  String? notificationType;
  String? subject;
  String? message;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['notification_type'] = notificationType;
    map['subject'] = subject;
    map['message'] = message;
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
