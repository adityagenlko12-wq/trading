// ignore_for_file: constant_identifier_names

class Environment {
/* ATTENTION Please update your desired data. */

  static const String appName = 'Trading Platform';
  static const String appSubTitle = 'Indian Equity & Derivatives Trading Platform';
  static const String appWebUrl = 'https://trading-wsxw.onrender.com';
  static const String version = '1.0.0';

  static const bool DEV_MODE = false;
  static const APP_ONBOARD = true;
  static const APP_VIBRATION = true;

  //Guest MODE
  static const bool isGuestModeEnable = true;

  //App GS Settings Auth Key
  static const String appAuthKey = "vinance*123"; //Don't touch here

  // LOGIN AND REG PART
  static String defaultPhoneCode = "1"; //don't put + here
  static String defaultCountryCode = "US";
  //Metamask Login

  static const bool enableLoginWithMetamask = true; // Set to false => to disable it.
  static const String walletConnectProjectID = '2f4a1cfa0b3305f4e91dc4c8bd1c0a99'; //Insert your wallet connect Project ID Here
  //WalletConnect link - https://cloud.walletconnect.com/
}
