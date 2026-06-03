import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vinance/view/components/image/my_network_image_widget.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/utils/url_container.dart';
import '../../../../../data/controller/account/profile_complete_controller.dart';
import '../../../../../data/controller/auth/auth/registration_controller.dart';
import '../../../../components/bottom-sheet/bottom_sheet_header_row.dart';
import '../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';

class CountryBottomSheetPlus {
  static void showSignUpBottomSheet(BuildContext context, RegistrationController controller) {
    CustomBottomSheetPlus(
      isNeedPadding: false,
      bgColor: MyColor.transparentColor,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              setState(() {
                controller.filteredCountries = controller.countryList.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 1,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgSecondaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const BottomSheetHeaderRow(header: '', bottomSpace: 15),

                // Add the search field.
                TextField(
                  controller: controller.searchCountryController,
                  onChanged: filterCountries,
                  decoration: InputDecoration(
                    hintText: MyStrings.searchCountry.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getBorderColor()),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getPrimaryColor()),
                    ),
                  ),
                  cursorColor: MyColor.getPrimaryColor(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            // controller.setCountryNameAndCode(
                            //   controller.filteredCountries[index].country.toString(),
                            //   controller.filteredCountries[index].countryCode.toString(),
                            //   controller.filteredCountries[index].dialCode.toString(),
                            // );
                            // controller.updateMobilecode(controller.filteredCountries[index].dialCode.toString());
                            // controller.selectCountryData(controller.filteredCountries[index]);
                            // Navigator.pop(context);
                            // FocusScopeNode currentFocus = FocusScope.of(context);
                            // if (!currentFocus.hasPrimaryFocus) {
                            //   currentFocus.unfocus();
                            // }
                            // controller.mobileFocusNode.nextFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: MyColor.transparentColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: MyColor.colorGrey.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: MyNetworkImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", countryItem.countryCode.toString().toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: Text(
                                    '+${countryItem.dialCode}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${countryItem.country}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    ).show(context);
  }

  static void showProfileCompleteBottomSheet(BuildContext context, ProfileCompleteController controller) {
    CustomBottomSheetPlus(
      isNeedPadding: false,
      bgColor: MyColor.transparentColor,
      child: StatefulBuilder(
        builder: (BuildContext context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              setState(() {
                controller.filteredCountries = controller.countryList.where((country) => country.country!.toLowerCase().contains(query.toLowerCase())).toList();
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 1,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgSecondaryColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const BottomSheetHeaderRow(header: '', bottomSpace: 15),

                // Add the search field.
                TextField(
                  controller: controller.searchCountryController,
                  onChanged: filterCountries,
                  decoration: InputDecoration(
                    hintText: MyStrings.searchCountry.tr,
                    prefixIcon: Icon(
                      Icons.search,
                      color: MyColor.getSecondaryTextColor(),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getBorderColor()),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: MyColor.getPrimaryColor()),
                    ),
                  ),
                  cursorColor: MyColor.getPrimaryColor(),
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            controller.setCountryNameAndCode(
                              controller.filteredCountries[index].country.toString(),
                              controller.filteredCountries[index].countryCode.toString(),
                              controller.filteredCountries[index].dialCode.toString(),
                            );
                            controller.updateMobilecode(controller.filteredCountries[index].dialCode.toString());
                            controller.selectCountryData(controller.filteredCountries[index]);
                            Navigator.pop(context);
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                            controller.mobileNoFocusNode.nextFocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: MyColor.transparentColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: MyColor.colorGrey.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: MyNetworkImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink.replaceAll("{countryCode}", countryItem.countryCode.toString().toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(end: Dimensions.space10),
                                  child: Text(
                                    '+${countryItem.dialCode}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${countryItem.country}',
                                    style: regularDefault.copyWith(color: MyColor.getPrimaryTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        },
      ),
    ).show(context);
  }
}
