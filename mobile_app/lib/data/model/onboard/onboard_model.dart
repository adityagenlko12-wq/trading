import 'dart:convert';

OnBoardResponseModel onBoardsFromJson(String str) => OnBoardResponseModel.fromJson(json.decode(str));

class OnBoardResponseModel {
  OnBoardResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  OnBoardResponseModel.fromJson(dynamic json) {
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
    this.onBoards,
    this.imagePath,
  });

  Data.fromJson(dynamic json) {
    if (json['onboards'] != null) {
      onBoards = [];
      json['onboards'].forEach((v) {
        onBoards?.add(OnBoard.fromJson(v));
      });
    } else if (json['on_boards'] != null) {
      onBoards = [];
      json['on_boards'].forEach((v) {
        onBoards?.add(OnBoard.fromJson(v));
      });
    }
    imagePath = json['image_path']?.toString() ?? json['path']?.toString();
  }

  List<OnBoard>? onBoards;
  String? imagePath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (onBoards != null) {
      map['onboards'] = onBoards?.map((v) => v.toJson()).toList();
    }
    map['image_path'] = imagePath;
    return map;
  }
}

class OnBoard {
  OnBoard({
    this.id,
    this.dataKeys,
    this.dataValues,
  });

  OnBoard.fromJson(dynamic json) {
    id = json['id'];
    dataKeys = json['data_keys']?.toString();
    dataValues = json['data_values'] != null ? OnBoardDataValues.fromJson(json['data_values']) : null;
  }

  int? id;
  String? dataKeys;
  OnBoardDataValues? dataValues;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['data_keys'] = dataKeys;
    if (dataValues != null) {
      map['data_values'] = dataValues?.toJson();
    }
    return map;
  }
}

class OnBoardDataValues {
  OnBoardDataValues({
    this.image,
    this.title,
    this.subtitle,
  });

  OnBoardDataValues.fromJson(dynamic json) {
    image = json['image']?.toString();
    title = json['title']?.toString();
    subtitle = json['subtitle']?.toString();
  }

  String? image;
  String? title;
  String? subtitle;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['image'] = image;
    map['title'] = title;
    map['subtitle'] = subtitle;
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
