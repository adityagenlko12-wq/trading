import 'dart:io';
import 'package:flutter/material.dart';

class KycFormModel {
  KycFormModel({
    this.name,
    this.label,
    this.type,
    this.isRequired,
    this.options,
    this.selectedValue,
    this.cbSelected,
    this.imageFile,
    this.textEditingController,
    this.instruction,
  });

  KycFormModel.fromJson(dynamic json) {
    name = json['name']?.toString();
    label = json['label']?.toString();
    type = json['type']?.toString();
    isRequired = json['is_required']?.toString();
    instruction = json['instruction']?.toString();
    if (json['options'] != null) {
      options = List<String>.from(json['options']);
    } else {
      options = [];
    }
    selectedValue = json['value']?.toString() ?? '';
    cbSelected = [];
    imageFile = null;
    textEditingController = TextEditingController(text: selectedValue);
  }

  String? name;
  String? label;
  String? type;
  String? isRequired;
  String? instruction;
  List<String>? options;
  String? selectedValue;
  List<String>? cbSelected;
  File? imageFile;
  TextEditingController? textEditingController;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['label'] = label;
    map['type'] = type;
    map['is_required'] = isRequired;
    map['instruction'] = instruction;
    map['options'] = options;
    map['value'] = selectedValue;
    return map;
  }
}
