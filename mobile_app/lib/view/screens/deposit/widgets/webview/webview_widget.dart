import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vinance/core/utils/my_color.dart';

import '../../../../../core/route/route.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../../core/utils/url_container.dart';
import '../../../../components/snack_bar/show_custom_snackbar.dart';

class DepositAppWebViewWidget extends StatefulWidget {
  const DepositAppWebViewWidget({super.key, required this.url});

  final String url;

  @override
  State<DepositAppWebViewWidget> createState() => _DepositAppWebViewWidgetState();
}

class _DepositAppWebViewWidgetState extends State<DepositAppWebViewWidget> {
  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  String url = '';
  final GlobalKey webViewKey = GlobalKey();
  // PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;


  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    return Stack(
      children: [
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: MyColor.getPrimaryColor(),
              ))
            : const SizedBox(),
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
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
            return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
              if (await canLaunchUrl(Uri.parse(widget.url))) {
                await launchUrl(Uri.parse(widget.url));
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStart: (controller, url) {
            if (url.toString() == '${UrlContainer.domainUrl}/user/deposit/history') {
              Get.offAndToNamed(RouteHelper.depositHistoryScreen);
              CustomSnackBar.success(successList: [MyStrings.depositSuccessful]);
            } else if (url.toString() == '${UrlContainer.domainUrl}/user/deposit' || url.toString() == '${UrlContainer.domainUrl}/user/dashboard') {
              Get.back();
              CustomSnackBar.error(errorList: [MyStrings.requestFail]);
            }
            setState(() {
              this.url = url.toString();
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
              isLoading = false;
              this.url = url.toString();
            });
          },
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onLoadError: (controller, url, code, message) {},
          onProgressChanged: (controller, progress) {},
          onUpdateVisitedHistory: (controller, url, androidIsReload) {},
          onReceivedServerTrustAuthRequest: (controller, challenge) async {
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
          onConsoleMessage: (controller, consoleMessage) {},
        ),
      ],
    );
  }
}
