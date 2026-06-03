import 'package:get/get.dart';
import 'package:vinance/view/screens/auth/authentication_screen.dart';
import 'package:vinance/view/screens/auth/email_verification_page/email_verification_screen.dart';
import 'package:vinance/view/screens/auth/forget_password/reset_password/reset_password_screen.dart';
import 'package:vinance/view/screens/auth/forget_password/verify_forget_password/verify_forget_password_screen.dart';
import 'package:vinance/view/screens/deposit/deposit_screen.dart';
import 'package:vinance/view/screens/deposit/history/deposit_history_screen.dart';
import 'package:vinance/view/screens/edit_profile/edit_profile_screen.dart';
import 'package:vinance/view/screens/language/language_screen.dart';
import 'package:vinance/view/screens/notification/notification_screen.dart';
import 'package:vinance/view/screens/preview_image/preview_image.dart';
import 'package:vinance/view/screens/profile/profile_screen.dart';
import 'package:vinance/view/screens/referral/referral_screen.dart';
import 'package:vinance/view/screens/ticket/all_support_ticket_screen.dart';
import 'package:vinance/view/screens/ticket/add_new_ticket_screen/add_new_ticket_screen.dart';

import 'package:vinance/view/screens/ticket/support_ticket_details/support_ticket_details.dart';
import 'package:vinance/view/screens/trade_page/screen/my_order_history/my_order_history_screen.dart';
import 'package:vinance/view/screens/trade_page/screen/trade_history/trade_history_screen.dart';
import 'package:vinance/view/screens/transfer/transfer_screen.dart';
import 'package:vinance/view/screens/withdraw/screen/history/withdraw_history_screen.dart';
import 'package:vinance/view/screens/withdraw/screen/withdraw_confirmation_screen/withdraw_confirmation_screen.dart';
import 'package:vinance/view/screens/withdraw/screen/withdraw_details/withdraw_details_screen.dart';
import 'package:vinance/view/screens/withdraw/withdraw_screen.dart';
import '../../view/screens/auth/forget_password/forget_password/forget_password.dart';
import '../../view/screens/auth/kyc/kyc_screen.dart';
import '../../view/screens/auth/profile_complete/profile_complete_screen.dart';
import '../../view/screens/auth/sms_verification_page/sms_verification_screen.dart';
import '../../view/screens/auth/two_factor_screen/two_factor_setup_screen.dart';
import '../../view/screens/auth/two_factor_screen/two_factor_verification_screen.dart';
import '../../view/screens/blogs/blogs_details_screen.dart';
import '../../view/screens/blogs/blogs_screen.dart';
import '../../view/screens/change-password/change_password_screen.dart';
import '../../view/screens/dashboard/dashboard_screen.dart';
import '../../view/screens/dashboard/screen/profile_and_settings/screen/security_setup_screen.dart';
import '../../view/screens/deposit/widgets/webview/deposit_webview_widget.dart';
import '../../view/screens/faq/faq_screen.dart';
import '../../view/screens/onboard/onboard_screen.dart';
import '../../view/screens/privacy_policy/privacy_policy_screen.dart';
import '../../view/screens/splash/splash_screen.dart';
import '../../view/screens/trade_page/screen/buy_sell_screen/trade_buy_sell_screen.dart';
import '../../view/screens/trade_page/trade_page_screen.dart';
import '../../view/screens/transfer/widgets/transfer_details_screen.dart';
import '../../view/screens/dashboard/screen/wallet/screen/wallet_history/wallet_history_screen.dart';
import '../../view/screens/dashboard/screen/wallet/screen/wallet_single_coin_details/single_coin_wallet_details_screen.dart';
import '../../view/screens/options/options_chain_webview_screen.dart';

class RouteHelper {
  static const String splashScreen = "/splash_screen";
  static const String onboardScreen = "/onboard_screen";
  //Auth
  static const String authenticationScreen = "/authentication_screen";
  //Auth END

  static const String forgotPasswordScreen = "/forgot_password_screen";
  static const String changePasswordScreen = "/change_password_screen";
  static const String resetPasswordScreen = "/reset_pass_screen";
  static const String profileCompleteScreen = "/profile_complete_screen";

  static const String emailVerificationScreen = "/verify_email_screen";
  static const String smsVerificationScreen = "/verify_sms_screen";
  static const String verifyPassCodeScreen = "/verify_pass_code_screen";
  static const String twoFactorScreen = "/two-factor-screen";
  static const String twoFactorSetupScreen = "/two-factor-setup-screen";
  static const String securitySetupScreen = "/security_setup_screen";
  static const String kycScreen = "/kyc_screen";

  static const String profileScreen = "/profile_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String profileAndSettings = "/account_and_settings";

  static const String transactionHistoryScreen = "/transaction_history_screen";
  static const String notificationScreen = "/notification_screen";
  static const String privacyScreen = "/privacy-screen";

  static const String myWalletScreen = "/my_wallet_screen";
  static const String walletHistoryScreen = "/my_wallet_history_screen";
  static const String walletSingleCoinDetailsScreen = "/single_coin_details_screen";
  //DASHBAORD
  static const String dashboardScreen = "/dashboard_screen";
  //trade view
  static const String tradeViewDetailsScreen = "/trade_screen";
  static const String tradeBuySellScreen = "/trade_buy_sell_screen";
  static const String tradeHistoryScreen = "/trade_history";
  static const String myOrderHistoryScreen = "/my_order_history";

  //Withdraw
  static const String withdrawScreen = "/withdraw_screen";
  static const String withdrawConfirmScreenScreen = "/withdraw-confirm-screen";
  static const String withdrawDetailsScreen = "/withdraw_details_screen";
  static const String withdrawHistoryScreen = "/withdraw_history_screen";
  //Deposit
  static const String depositScreen = "/deposit_screen";
  static const String depositHistoryScreen = "/deposit_history_screen";
  static const String depositWebViewScreen = '/deposit_webView';

  //Transfer
  static const String transferScreen = "/transfer_screen";
  static const String transferDetailsScreen = "/transfer_details_screen";
  // Referral
  static const String referralScreen = "/referral_screen";
  //Blog
  static const String blogScreenScreen = "/blog_screen";
  static const String blogDetailScreenScreen = "/blog_detail_screen";
  //Faq
  static const String faqScreenScreen = "/faq_screen";

//Support
  static const String allSupportTicketScreen = '/all_support_ticket_screen';
  static const String supportTicketDetailsScreen = '/support_ticket_details_screen';
  static const String addNewSupportTicketScreen = '/add_new_support_ticket_screen';
  static const String previewImageScreen = "/preview-image-screen";

  static const String languageScreen = "/language-screen";
  static const String optionsChainScreen = "/options_chain_screen";

  List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onboardScreen, page: () => const OnBoardScreen()),

    //AUTH
    GetPage(name: authenticationScreen, page: () => AuthenticationScreen(isShowLoginTab: Get.arguments == null || Get.arguments == true ? true : false)),

    //AUTH END

    GetPage(name: profileCompleteScreen, page: () => const ProfileCompleteScreen()),
    //Reset

    GetPage(name: forgotPasswordScreen, page: () => const ForgetPasswordScreen()),
    GetPage(name: verifyPassCodeScreen, page: () => const VerifyForgetPassScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),

    //Verifications
    GetPage(name: emailVerificationScreen, page: () => const EmailVerificationScreen()),

    GetPage(name: smsVerificationScreen, page: () => const SmsVerificationScreen()),
    GetPage(name: twoFactorScreen, page: () => const TwoFactorVerificationScreen()),

    GetPage(name: twoFactorSetupScreen, page: () => const TwoFactorSetupScreen()),
    GetPage(name: securitySetupScreen, page: () => const SecuritySetupScreen()),
    GetPage(name: kycScreen, page: () => const KycScreen()),

    //Profile
    GetPage(name: profileScreen, page: () => const ProfileScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyPolicyScreen()),

    // dashboard
    GetPage(name: dashboardScreen, page: () => const DashboardScreen()),
    // Tread View
    GetPage(name: tradeViewDetailsScreen, page: () => TradePageScreen(tradeCoinSymbol: Get.arguments)),
    GetPage(
        name: tradeBuySellScreen,
        page: () => TradeBuySellScreen(
              tradeCoinSymbol: Get.arguments?[0] ?? "",
              typeBuyOrSell: Get.arguments?[1] ?? "",
            )),
    GetPage(name: tradeHistoryScreen, page: () => TradeHistoryScreen(tradeType: "${Get.arguments == null || Get.arguments == "" ? "" : Get.arguments}")),
    GetPage(name: myOrderHistoryScreen, page: () => MyOrderHistoryScreen(orderHistoryType: "${Get.arguments == null || Get.arguments == "" ? "" : Get.arguments}")),
    //Wallet
    GetPage(
      name: walletSingleCoinDetailsScreen,
      page: () => SingleCoinWalletDetailsScreen(
        coinSymbol: Get.arguments?[0] ?? "",
        walletType: Get.arguments?[1] ?? "",
      ),
    ),
    GetPage(name: walletHistoryScreen, page: () => WalletHistoryScreen(remarkType: "${Get.arguments == null || Get.arguments == "" ? "" : Get.arguments}")),
    //Deposit
    GetPage(
      name: depositScreen,
      page: () => DepositScreen(
        walletType: Get.arguments?[0] ?? "spot",
        selectedCurrencyFromParamsID: Get.arguments?[1] ?? "",
      ),
    ),
    GetPage(name: depositHistoryScreen, page: () => const DepositHistoryScreen()),
    GetPage(name: depositWebViewScreen, page: () => DepositWebviewWidget(redirectUrl: Get.arguments == null || Get.arguments == "" ? "" : Get.arguments)),

    //Withdraw
    GetPage(
        name: withdrawScreen,
        page: () => WithdrawScreen(
              walletType: Get.arguments?[0] ?? "spot",
              selectedCurrencyFromParamsID: Get.arguments?[1] ?? "",
            )),
    GetPage(name: withdrawConfirmScreenScreen, page: () => const WithdrawConfirmationScreen()),

    GetPage(name: withdrawHistoryScreen, page: () => const WithdrawHistoryScreen()),
    GetPage(
        name: withdrawDetailsScreen,
        page: () => WithdrawDetailsScreen(
              withdrawConfirmationData: Get.arguments == null || Get.arguments == "" ? null : Get.arguments,
            )),
    // Transfer
    GetPage(
        name: transferScreen,
        page: () => TransferScreen(
              walletType: Get.arguments?[0] ?? "spot",
              selectedCurrencyFromParamsID: Get.arguments?[1] ?? "",
            )),
    GetPage(
        name: transferDetailsScreen,
        page: () => TransferDetailsScreen(
              transferResponseModel: Get.arguments == null || Get.arguments == "" ? null : Get.arguments,
            )),
    GetPage(name: notificationScreen, page: () => const NotificationScreen()),

    //Referral
    GetPage(name: referralScreen, page: () => const ReferralScreen()),
    //Blog
    GetPage(name: blogScreenScreen, page: () => const BlogsScreen()),
    GetPage(
        name: blogDetailScreenScreen,
        page: () => BlogsDetailsScreen(
              blogData: Get.arguments?[0] ?? "",
              imagePath: Get.arguments?[1] ?? "",
            )),
    //Faq
    GetPage(name: faqScreenScreen, page: () => const FaqScreen()),
    //
    GetPage(name: allSupportTicketScreen, page: () => const AllSupportTicketListScreen()),
    GetPage(name: supportTicketDetailsScreen, page: () => const SupportTicketDetailsScreen()),
    GetPage(name: addNewSupportTicketScreen, page: () => const AddNewSupportTicketScreen()),
    GetPage(name: previewImageScreen, page: () => PreviewImage(url: Get.arguments)),

    GetPage(name: languageScreen, page: () => const LanguageScreen()),
    GetPage(name: optionsChainScreen, page: () => const OptionsChainWebviewScreen()),
  ];
}
