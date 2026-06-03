class UrlContainer {
  static const String domainUrl = 'https://trading-wsxw.onrender.com';

  static const String baseUrl = '$domainUrl/api/';

  static const String dashBoardEndPoint = 'dashboard';
  static const String depositHistoryUrl = 'deposit/history';
  static const String depositMethodUrl = 'deposit/methods';
  static const String depositInsertUrl = 'deposit/insert';

  static const String registrationEndPoint = 'register';
  static const String loginEndPoint = 'login';
  static const String socialLoginEndPoint = 'social-login';
  static const String metamaskGetMessageEndPoint = 'web3/metamask-login/message';
  static const String metamaskMessageVerifyEndPoint = 'web3/metamask-login/verify';

  static const String logoutUrl = 'logout';
  static const String forgetPasswordEndPoint = 'password/email';
  static const String passwordVerifyEndPoint = 'password/verify-code';
  static const String resetPasswordEndPoint = 'password/reset';
  static const String verify2FAUrl = 'verify-g2fa';

  static const String otpVerify = 'otp-verify';

  static const String otpResend = 'otp-resend';

  static const String verifyEmailEndPoint = 'verify-email';
  static const String verifySmsEndPoint = 'verify-mobile';
  static const String resendVerifyCodeEndPoint = 'resend-verify/';
  static const String authorizationCodeEndPoint = 'authorization';
  static const String referralsEndPoint = 'referrals';

  static const String transactionEndpoint = 'transactions';

  static const String addWithdrawRequestUrl = 'withdraw-request';
  static const String withdrawMethodUrl = 'withdraw-method';
  static const String withdrawRequestConfirm = 'withdraw-request/confirm';
  static const String withdrawHistoryUrl = 'withdraw/history';
  static const String withdrawStoreUrl = 'withdraw/store/';
  static const String withdrawConfirmScreenUrl = 'withdraw/preview/';

  static const String kycFormUrl = 'kyc-form';
  static const String kycSubmitUrl = 'kyc-submit';

  static const String generalSettingEndPoint = 'general-setting';
  //Notification
  static const String notificationListApi = "notifications";

  static const String privacyPolicyEndPoint = 'policy-pages';
  static const String faqEndPoint = 'faqs';
  static const String blogsEndPoint = 'blogs';
  static const String blogDetailsEndPoint = 'blog/details';

  static const String getProfileEndPoint = 'user-info';
  static const String updateProfileEndPoint = 'profile-setting';
  static const String profileCompleteEndPoint = 'user-data-submit';

  static const String changePasswordEndPoint = 'change-password';
  static const String countryEndPoint = 'get-countries';

  static const String deviceTokenEndPoint = 'add-device-token';
  static const String languageUrl = 'language/';
  static const String onBoardsApiEndPoint = 'onboarding';

  static const String twoFactor = "twofactor";
  static const String twoFactorEnable = "twofactor/enable";
  static const String twoFactorDisable = "twofactor/disable";

  //market
  static const String marketDataListApi = "market-list";
  static const String marketMarketOverviewApi = "market-overview";
  static const String marketTradeCurrencyApi = "trade/currency";

  //trade
  static const String marketTradeApi = "trade";
  static const String marketTradeHistoryEndPoint = "trade/history";
  static const String marketTradeOrderListEndPoint = "trade/order/list";
  static const String marketTradeOrderBookEndPoint = "trade/order/book";
  static const String marketTradePairEndPoint = "trade/pairs";
  static const String tradePairAddToFavoriteEndPoint = "pair/add/to/favorite";
  static const String tradeOrderBookApi = "trade/order/book";

  static const String tradeAllHistoryApi = "trade-history";
  //order
  static const String tradeOrderList = "trade/order/list";
  static const String updateOrder = "order/update";
  static const String saveOrder = "order/save";
  static const String cancelOrder = "order/cancel";
  static const String orderHistoryApi = "order";
  //Coin Fav
  static const String addToFavCoinEndPoint = "pair/add/to/favorite";
  //Wallet
  static const String walletEndPoint = "wallet";
  static const String walletListEndPoint = "wallet/list";
  static const String walletTransferToUserEndPoint = "wallet/transfer";
  static const String walletTransferToWalletEndPoint = "wallet/transfer/to/wallet";
  static const String pinValidate = "validate/password";
  //Crypto list
  static const String cryptoListEndPoint = "crypto-list";
  static const String currencyListEndPoint = "currencies";
  //Pusher auth

  static const String pusherAuthApiURl = "pusher/auth";
  //Referrals
  static const String referURl = "$domainUrl?reference=";

//support ticket
  static const String supportMethodsEndPoint = 'support/method';
  static const String supportListEndPoint = 'ticket';
  static const String storeSupportEndPoint = 'ticket/create';
  static const String supportViewEndPoint = 'ticket/view';
  static const String supportReplyEndPoint = 'ticket/reply';
  static const String supportCloseEndPoint = 'ticket/close';
  static const String supportDownloadEndPoint = 'ticket/download';
  static const String accountDisable = 'delete-account';

  //Url image
  static const String countryFlagImageLink = 'https://flagpedia.net/data/flags/h24/{countryCode}.webp';
  static const String withdraw = 'assets/images/verify/withdraw';
  static const String supportImagePath = '$domainUrl/assets/support/';
}
