import 'dart:convert';

BlogScreenResponseModel blogScreenResponseModelFromJson(String str) => BlogScreenResponseModel.fromJson(json.decode(str));

class BlogScreenResponseModel {
  BlogScreenResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  BlogScreenResponseModel.fromJson(dynamic json) {
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
    this.blogs,
    this.path,
  });

  Data.fromJson(dynamic json) {
    blogs = json['blogs'] != null ? Blogs.fromJson(json['blogs']) : null;
    path = json['path']?.toString();
  }

  Blogs? blogs;
  String? path;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (blogs != null) {
      map['blogs'] = blogs?.toJson();
    }
    map['path'] = path;
    return map;
  }
}

class Blogs {
  Blogs({
    this.currentPage,
    this.data,
    this.nextPageUrl,
  });

  Blogs.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(BlogData.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
  }

  int? currentPage;
  List<BlogData>? data;
  String? nextPageUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['current_page'] = currentPage;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['next_page_url'] = nextPageUrl;
    return map;
  }
}

class BlogData {
  BlogData({
    this.id,
    this.dataKeys,
    this.dataValues,
  });

  BlogData.fromJson(dynamic json) {
    id = json['id'];
    dataKeys = json['data_keys']?.toString();
    dataValues = json['data_values'] != null ? BlogDataValues.fromJson(json['data_values']) : null;
  }

  int? id;
  String? dataKeys;
  BlogDataValues? dataValues;

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

class BlogDataValues {
  BlogDataValues({
    this.title,
    this.image,
    this.descriptionNic,
  });

  BlogDataValues.fromJson(dynamic json) {
    title = json['title']?.toString();
    image = json['image']?.toString();
    descriptionNic = json['description_nic']?.toString() ?? json['description']?.toString();
  }

  String? title;
  String? image;
  String? descriptionNic;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['image'] = image;
    map['description_nic'] = descriptionNic;
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
