import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vinance/core/utils/my_color.dart';

import '../../../core/utils/dimensions.dart';

class MyWebViewWidget extends StatefulWidget {
  const MyWebViewWidget({super.key, required this.url, this.onLoadStart, this.fromHtml = false, this.rawHtmlCode})
      : assert(
          !fromHtml || rawHtmlCode != null,
          'rawHtmlCode must be provided if fromHtml is true',
        );

  final bool fromHtml;
  final String? rawHtmlCode;
  final String url;
  final Function(InAppWebViewController, Uri?)? onLoadStart;

  @override
  State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget> {
  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  String url = '';
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //   isInspectable: kDebugMode,
  //   mediaPlaybackRequiresUserGesture: false,
  //   allowsInlineMediaPlayback: true,
  //   iframeAllow: "camera; microphone",
  //   iframeAllowFullscreen: true,
  //   transparentBackground: true,
  // );
  bool isKycPending = false;
  bool isLoading = true;
  PullToRefreshController? pullToRefreshController;
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    return Stack(
      children: [
        isLoading
            ? Center(
                child: SpinKitFadingCube(
                color: MyColor.getPrimaryColor().withOpacity(0.3),
                size: Dimensions.space20,
              ))
            : const SizedBox(),
        InAppWebView(
          initialUrlRequest: widget.fromHtml == false ? URLRequest(url: WebUri(widget.url)) : null,
          onWebViewCreated: (controller) {
            webViewController = controller;
            if (widget.fromHtml == true) {
              final html = widget.rawHtmlCode ?? '';

              webViewController!.loadData(
                data: html,
              );
            }
          },
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              transparentBackground: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
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
              if (await canLaunchUrl(WebUri(widget.url))) {
                await launchUrl(WebUri(widget.url));
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStart: (controller, url) {
            setState(() {
              isLoading = false;
              this.url = url.toString();
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
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
