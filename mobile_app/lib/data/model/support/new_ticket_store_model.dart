import 'dart:io';

class TicketStoreModel {
  TicketStoreModel({
    required this.name,
    required this.email,
    required this.subject,
    required this.priority,
    required this.message,
    required this.list,
  });

  String name;
  String email;
  String subject;
  String priority;
  String message;
  List<File> list;
}
