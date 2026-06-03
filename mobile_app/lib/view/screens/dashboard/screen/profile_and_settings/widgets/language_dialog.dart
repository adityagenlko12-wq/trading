import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vinance/view/components/bottom-sheet/custom_bottom_sheet_plus.dart';

import '../../../../../../core/utils/my_color.dart';
import '../../../../../../data/model/language/language_model.dart';
import '../../../../../../data/model/language/main_language_response_model.dart';
import 'language_dialog_body.dart';

void showLanguageDialog(String languageList, Locale selectedLocal, BuildContext context, String selectedlanguageCode, {bool fromSplash = false}) {
  var language = jsonDecode(languageList);
  MainLanguageResponseModel model = MainLanguageResponseModel.fromJson(language);

  List<MyLanguageModel> langList = [];

  if (model.data?.languages != null && model.data!.languages!.isNotEmpty) {
    for (var listItem in model.data!.languages!) {
      MyLanguageModel model = MyLanguageModel(languageCode: listItem.code ?? '', countryCode: listItem.name ?? '', languageName: listItem.name ?? '');
      langList.add(model);
    }
  }

  CustomBottomSheetPlus(
    bgColor: MyColor.getScreenBgColor(),
    isNeedPadding: false,
    child: LanguageDialogBody(
      langList: langList,
      fromSplashScreen: fromSplash,
      selectedlanguageCode: selectedlanguageCode,
    ),
  ).show(context);
}
