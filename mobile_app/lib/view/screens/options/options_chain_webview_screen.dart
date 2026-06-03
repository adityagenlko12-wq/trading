import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';
import '../../../core/utils/url_container.dart';
import '../../components/app-bar/app_main_appbar.dart';

class OptionsChainWebviewScreen extends StatefulWidget {
  const OptionsChainWebviewScreen({super.key});

  @override
  State<OptionsChainWebviewScreen> createState() => _OptionsChainWebviewScreenState();
}

class _OptionsChainWebviewScreenState extends State<OptionsChainWebviewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    permissionServices();
  }

  Future<void> permissionServices() async {
    await [
      Permission.photos,
      Permission.microphone,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    String optionChainUrl = "${UrlContainer.domainUrl}/options/chain";

    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppMainAppBar(
        isTitleCenter: true,
        isProfileCompleted: true,
        title: "Option Chain",
        bgColor: MyColor.transparentColor,
        titleStyle: regularLarge.copyWith(
          fontSize: Dimensions.fontLarge,
          color: MyColor.getPrimaryTextColor(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(optionChainUrl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                transparentBackground: true,
                userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36 Edge/17.17134",
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: MyColor.getPrimaryColor(),
              ),
            ),
        ],
      ),
    );
  }
}
