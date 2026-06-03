// Import necessary dependencies or models
import 'package:get/get.dart';
import 'package:vinance/data/repo/faq/faq_repository.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/faq/faq_model.dart';
import '../../model/global/response_model/response_model.dart';

class FaqController extends GetxController {
  FaqRepository faqRepository;
  FaqController({required this.faqRepository});

  bool isLoading = false;
  List<FaqsDataModel> faqDataList = [];
  int page = 0;
  int faqSelectedIndex = -1;
  String? imagePath;
  String? nextPageUrl;

  Future<void> getAllFaqList({bool isFromLoad = false}) async {
    page = page + 1;
    if (page == 1) {
      faqDataList.clear();
      isLoading = true;
      update();
    }

    try {
      ResponseModel responseModel = await faqRepository.fetchAllFaq(page.toString());
      if (responseModel.statusCode == 200) {
        final faqsResponseModel = faqsResponseModelFromJson(responseModel.responseJson);
        if (faqsResponseModel.status == MyStrings.success) {
          nextPageUrl = faqsResponseModel.data?.faqs?.nextPageUrl;
          imagePath = faqsResponseModel.data?.faqs?.path;
          printx(nextPageUrl);

          List<FaqsDataModel>? tempFaq = faqsResponseModel.data?.faqs?.data;
          if (tempFaq != null && tempFaq.isNotEmpty) {
            faqDataList.addAll(tempFaq);
          }
          update();
        } else {
          // CustomSnackBar.error(errorList: faqsResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    } catch (e) {
      printx(e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  changeFaqSelectedIndex(int index) {
    if (faqSelectedIndex == index) {
      faqSelectedIndex = -1;
      update();
      return;
    }
    faqSelectedIndex = index;
    update();
  }
}
