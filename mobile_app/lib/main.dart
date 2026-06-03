import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinance/core/route/route.dart';
import 'package:vinance/core/utils/messages.dart';
import 'package:vinance/data/controller/common/theme_controller.dart';
import 'package:vinance/data/controller/localization/localization_controller.dart';
import 'package:vinance/environment.dart';
import 'package:vinance/firebase_options.dart';
import 'package:vinance/push_notification_service.dart';
import 'core/di_service/di_services.dart' as di_service;
import 'core/helper/shared_preference_helper.dart';
import 'core/theme/theme.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  sharedPreferences.setBool(SharedPreferenceHelper.hasNewNotificationKey, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di_service.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_messageHandler); //NEXT VERSION
  await PushNotificationService().setupInteractedMessage(); //NEXT VERSION
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp(languages: languages));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => false;
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetBuilder<ThemeController>(
      builder: (theme) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetMaterialApp(
              title: Environment.appName,
              debugShowCheckedModeBanner: false,
              defaultTransition: Transition.native,
              transitionDuration: const Duration(milliseconds: 200),
              initialRoute: RouteHelper.splashScreen,
              navigatorKey: Get.key,
              getPages: RouteHelper().routes,
              locale: localizeController.locale,
              translations: Messages(languages: widget.languages),
              fallbackLocale: Locale(
                localizeController.locale.languageCode,
                localizeController.locale.countryCode,
              ),
              themeMode: theme.darkTheme ? ThemeMode.dark : ThemeMode.light,
              theme: AppTheme.lightThemeData,
              darkTheme: AppTheme.darkThemeData,
            );
          },
        );
      },
    );
  }
}
