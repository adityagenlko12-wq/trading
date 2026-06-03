import 'dart:convert';

FaqsResponseModel faqsResponseModelFromJson(String str) => FaqsResponseModel.fromJson(json.decode(str));

class FaqsResponseModel {
  FaqsResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  FaqsResponseModel.fromJson(dynamic json) {
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
    this.faqs,
  });

  Data.fromJson(dynamic json) {
    faqs = json['faqs'] != null ? Faqs.fromJson(json['faqs']) : null;
  }

  Faqs? faqs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (faqs != null) {
      map['faqs'] = faqs?.toJson();
    }
    return map;
  }
}

class Faqs {
  Faqs({
    this.currentPage,
    this.data,
    this.nextPageUrl,
    this.path,
  });

  Faqs.fromJson(dynamic json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(FaqsDataModel.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
  }

  int? currentPage;
  List<FaqsDataModel>? data;
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

class FaqsDataModel {
  FaqsDataModel({
    this.id,
    this.dataKeys,
    this.dataValues,
  });

  FaqsDataModel.fromJson(dynamic json) {
    id = json['id'];
    dataKeys = json['data_keys']?.toString();
    dataValues = json['data_values'] != null ? DataValues.fromJson(json['data_values']) : null;
  }

  int? id;
  String? dataKeys;
  DataValues? dataValues;

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

class DataValues {
  DataValues({
    this.question,
    this.answer,
  });

  DataValues.fromJson(dynamic json) {
    question = json['question']?.toString();
    answer = json['answer']?.toString();
  }

  String? question;
  String? answer;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['question'] = question;
    map['answer'] = answer;
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
