import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController with GetSingleTickerProviderStateMixin {
  int currentIndex = 0;

  TabController? tabController;
  @override
  void onInit() {
    super.onInit();
    loadActivityTabsData();
  }

  loadActivityTabsData() {
    tabController = TabController(initialIndex: currentIndex, length: 3, vsync: this);
  }

  int selectedFilterIndex = 0;
  changeSelectedFilterIndex(int value) {
    selectedFilterIndex = value;
    update();
  }

  List serviceList = [
    {"name": "Ride", "subtitle": "Ride in comfort and style."},
    {"name": "Intercity", "subtitle": "Travel seamlessly between cities."},
    {"name": "Rentals", "subtitle": "Rent the perfect car for your needs."},
    {"name": "Reserve", "subtitle": "Reserve your ride in advance. Reserve your ride in advance.  Reserve your ride in advance. "},
  ];
}
