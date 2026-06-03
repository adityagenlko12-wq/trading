//TODO: flutter_inappwebview 6+ 
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vinance/core/utils/my_color.dart';

// import '../../../core/utils/dimensions.dart';

// class MyWebViewWidget extends StatefulWidget {
//   const MyWebViewWidget({super.key, required this.url, this.onLoadStart, this.fromHtml = false, this.rawHtmlCode})
//       : assert(
//           !fromHtml || rawHtmlCode != null,
//           'rawHtmlCode must be provided if fromHtml is true',
//         );

//   final bool fromHtml;
//   final String? rawHtmlCode;
//   final String url;
//   final Function(InAppWebViewController, WebUri?)? onLoadStart;

//   @override
//   State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
// }

// class _MyWebViewWidgetState extends State<MyWebViewWidget> {
//   @override
//   void initState() {
//     url = widget.url;
//     super.initState();
//   }

//   String url = '';
//   final GlobalKey webViewKey = GlobalKey();

//   InAppWebViewController? webViewController;
//   InAppWebViewSettings settings = InAppWebViewSettings(
//     isInspectable: kDebugMode,
//     mediaPlaybackRequiresUserGesture: false,
//     allowsInlineMediaPlayback: true,
//     iframeAllow: "camera; microphone",
//     iframeAllowFullscreen: true,
//     transparentBackground: true,
//   );
//   bool isKycPending = false;
//   bool isLoading = true;
//   PullToRefreshController? pullToRefreshController;
//   @override
//   Widget build(BuildContext context) {
//     if (Platform.isAndroid) {
//       InAppWebViewController.setWebContentsDebuggingEnabled(true);
//     }
//     return Stack(
//       children: [
//         isLoading
//             ? Center(
//                 child: SpinKitFadingCube(
//                 color: MyColor.getPrimaryColor().withOpacity(0.3),
//                 size: Dimensions.space20,
//               ))
//             : const SizedBox(),
//         InAppWebView(
//           key: webViewKey,
//           initialUrlRequest: widget.fromHtml == false ? URLRequest(url: WebUri(url)) : null,
//           onWebViewCreated: (controller) {
//             webViewController = controller;

//             if (widget.fromHtml == true) {
//               final html = widget.rawHtmlCode ?? '';

//               webViewController!.loadData(
//                 data: html,
//               );
//             }
//           },
//           gestureRecognizers: {
//             Factory<OneSequenceGestureRecognizer>(
//               () => EagerGestureRecognizer(),
//             ),
//           },
//           initialSettings: settings,
//           onLoadStart: widget.onLoadStart,
//           onPermissionRequest: (controller, request) async {
//             return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
//           },
//           shouldOverrideUrlLoading: (controller, navigationAction) async {
//             var uri = navigationAction.request.url!;

//             if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
//               if (await canLaunchUrl(uri)) {
//                 // Launch the App
//                 await launchUrl(
//                   uri,
//                 );
//                 // and cancel the request
//                 return NavigationActionPolicy.CANCEL;
//               }
//             }

//             return NavigationActionPolicy.ALLOW;
//           },
//           onLoadStop: (controller, url) async {
//             setState(() {
//               isLoading = false;
//               this.url = url.toString();
//             });
//           },
//           onReceivedError: (controller, request, error) {
//             pullToRefreshController?.endRefreshing();
//           },
//           onProgressChanged: (controller, progress) {},
//           onUpdateVisitedHistory: (controller, url, androidIsReload) {
//             setState(() {
//               this.url = url.toString();
//             });
//           },
//           onConsoleMessage: (controller, consoleMessage) {},
//         )
//       ],
//     );
//   }
// }
