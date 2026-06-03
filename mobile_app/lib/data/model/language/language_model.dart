class MyLanguageModel {
  String languageName;
  String countryCode;
  String languageCode;
  String? imageUrl;
  bool isDefault;

  MyLanguageModel({
    required this.languageName,
    required this.countryCode,
    required this.languageCode,
    this.imageUrl,
    this.isDefault = false,
  });
}
