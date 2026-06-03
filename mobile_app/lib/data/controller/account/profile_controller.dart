import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/core/helper/shared_preference_helper.dart';
import 'package:vinance/core/helper/string_format_helper.dart';
import 'package:vinance/core/utils/my_strings.dart';
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/model/profile/profile_response_model.dart';
import 'package:vinance/data/model/user_post_model/user_post_model.dart';
import 'package:vinance/data/repo/account/profile_repo.dart';
import 'package:vinance/view/components/snack_bar/show_custom_snackbar.dart';

import '../../model/user/user_model.dart';

class ProfileController extends GetxController {
  ProfileRepo profileRepo;
  ProfileResponseModel profileResponseModel = ProfileResponseModel();

  ProfileController({required this.profileRepo});

  String imageUrl = '';

  bool isLoading = true;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  File? imageFile;
  String country = '';
  String fullName = '';
  String mobileNo = '';
  String userName = '';
  loadProfileInfo() async {
    if (profileResponseModel.data?.user == null) {
      isLoading = true;
    } else {
      isLoading = false;
    }

    update();
    try {
      profileResponseModel = await profileRepo.loadProfileInfo();

      if (profileResponseModel.data != null && profileResponseModel.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        loadData(profileResponseModel);
      } else {
        fullName = profileRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.userFullNameKey) ?? '';
        userName = profileRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.userNameKey) ?? '';
        mobileNo = profileRepo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.userPhoneNumberKey) ?? '';
        isLoading = false;
        update();
      }
    } catch (e) {
      isLoading = false;
      update();
    }
  }

  bool user2faIsOne = false;

  void loadData(ProfileResponseModel? model) {
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '${model?.data?.user?.username}');
    fullName = model?.data?.user?.getFullName() ?? '';
    userName = model?.data?.user?.username ?? '';
    mobileNo = model?.data?.user?.mobile ?? '';
    firstNameController.text = model?.data?.user?.firstname ?? '';
    lastNameController.text = model?.data?.user?.lastname ?? '';
    emailController.text = model?.data?.user?.email ?? '';
    mobileNoController.text = model?.data?.user?.mobile ?? '';
    addressController.text = model?.data?.user?.address ?? '';
    stateController.text = model?.data?.user?.state ?? '';
    zipCodeController.text = model?.data?.user?.zip ?? '';
    cityController.text = model?.data?.user?.city ?? '';
    imageUrl = model?.data?.user?.image == null ? '' : '${model?.data?.user?.image}';
    user2faIsOne = model?.data?.user?.ts == '1' ? true : false;

    imageFile = null;
    if (imageUrl.isNotEmpty && imageUrl != 'null') {
      imageUrl = '${UrlContainer.domainUrl}/assets/images/user/profile/$imageUrl';
    }
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, userName);
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userFullNameKey, fullName);
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userEmailKey, emailController.text);
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userPhoneNumberKey, mobileNo);
    isLoading = false;
    update();
  }

  bool isSubmitLoading = false;

  updateProfile() async {
    isSubmitLoading = true;
    update();

    String firstName = firstNameController.text;
    String lastName = lastNameController.text.toString();
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String zip = zipCodeController.text.toString();
    String state = stateController.text.toString();
    User? user = profileResponseModel.data?.user;

    try {
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        isLoading = true;
        update();

        UserPostModel model = UserPostModel(
          firstname: firstName,
          lastName: lastName,
          mobile: "",
          email: "",
          username: user?.username ?? '',
          countryCode: user?.countryCode ?? '',
          country: user?.country ?? '',
          mobileCode: '',
          image: imageFile,
          state: state,
          city: city,
          address: address,
          zip: zip,
        );

        bool b = await profileRepo.updateProfileInfo(model, true);

        if (b) {
          await loadProfileInfo();
        }
      } else {
        if (firstName.isEmpty) {
          CustomSnackBar.error(errorList: [MyStrings.kFirstNameNullError.tr]);
        } else if (lastName.isEmpty) {
          CustomSnackBar.error(errorList: [MyStrings.kLastNameNullError.tr]);
        }
      }
    } catch (e) {
      printx(e.toString());
    }

    isSubmitLoading = false;
    update();
  }

  void pickAImage(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg']);

      imageFile = File(result!.files.single.path!);

      update();
    } catch (e) {
      printx(e.toString());
    }
  }
}
