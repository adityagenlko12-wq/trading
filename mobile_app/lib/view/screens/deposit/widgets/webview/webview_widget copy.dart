//TODO: flutter_inappwebview 6+ 
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:vinance/core/utils/my_color.dart';

// import '../../../../../core/route/route.dart';
// import '../../../../../core/utils/my_strings.dart';
// import '../../../../../core/utils/url_container.dart';
// import '../../../../components/snack_bar/show_custom_snackbar.dart';

// class DepositAppWebViewWidget extends StatefulWidget {
//   const DepositAppWebViewWidget({super.key, required this.url});

//   final String url;

//   @override
//   State<DepositAppWebViewWidget> createState() => _DepositAppWebViewWidgetState();
// }

// class _DepositAppWebViewWidgetState extends State<DepositAppWebViewWidget> {
//   @override
//   void initState() {
//     url = widget.url;
//     super.initState();
//   }

//   String url = '';
//   final GlobalKey webViewKey = GlobalKey();
//   PullToRefreshController? pullToRefreshController;
//   InAppWebViewController? webViewController;
//   InAppWebViewSettings settings = InAppWebViewSettings(
//     isInspectable: kDebugMode,
//     mediaPlaybackRequiresUserGesture: false,
//     allowsInlineMediaPlayback: true,
//     iframeAllow: "camera; microphone",
//     iframeAllowFullscreen: true,
//     transparentBackground: true,
//   );

//   bool isLoading = true;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         isLoading ?  Center(child: CircularProgressIndicator(color: MyColor.getPrimaryTextColor(),)) : const SizedBox(),
//         InAppWebView(
//           key: webViewKey,
//           initialUrlRequest: URLRequest(url: WebUri(url)),
//           onWebViewCreated: (controller) {
//             webViewController = controller;
//           },
//           initialSettings: settings,
//           onLoadStart: (controller, url) {
//             if (url.toString() == '${UrlContainer.domainUrl}/user/deposit/history') {
//               Get.offAndToNamed(RouteHelper.dashboardScreen);
//               CustomSnackBar.success(successList: [MyStrings.depositSuccessful]);
//             } else if (url.toString() == '${UrlContainer.domainUrl}/user/deposit' || url.toString() == '${UrlContainer.domainUrl}/user/dashboard') {
//               Get.back();
//               CustomSnackBar.error(errorList: [MyStrings.requestFail]);
//             }
//             setState(() {
//               this.url = url.toString();
//             });
//           },
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
