// Import necessary dependencies or models
import 'package:get/get.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_strings.dart';
import '../../../view/components/snack_bar/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/referral/referral_model.dart';
import '../../repo/referral/referral_repository.dart';

class ReferralController extends GetxController {
  ReferralRepository referralRepository;

  ReferralController({required this.referralRepository});

  bool isLoading = false;
  AllReferral? myReferralsData;

  Future<void> getAllReferralList({bool isFromLoad = false}) async {
    if (isFromLoad == true) {
      isLoading = true;
    }

    try {
      ResponseModel responseModel = await referralRepository.fetchAllRepository();
      if (responseModel.statusCode == 200) {
        final referralScreenResponseModel = referralScreenResponseModelFromJson(responseModel.responseJson);

        if (referralScreenResponseModel.status == MyStrings.success) {
          myReferralsData = referralScreenResponseModel.data?.referrals;
          update();
        } else {
          // CustomSnackBar.error(errorList: referralScreenResponseModel.message?.error ?? [MyStrings.somethingWentWrong]);
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
}
