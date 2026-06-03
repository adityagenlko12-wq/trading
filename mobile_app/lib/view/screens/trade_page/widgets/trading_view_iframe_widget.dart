import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/webview/webview_widget.dart';
import 'trading_view_html_data_code.dart';

class TreadingViewFrameWidget extends StatefulWidget {
  final String symbolName;
  const TreadingViewFrameWidget({super.key, required this.symbolName});

  @override
  State<TreadingViewFrameWidget> createState() => _TreadingViewFrameWidgetState();
}

class _TreadingViewFrameWidgetState extends State<TreadingViewFrameWidget> {
  @override
  Widget build(BuildContext context) {
    return MyWebViewWidget(
      url: '',
      fromHtml: true,
      rawHtmlCode: TradingViewHtmlDataCode.cryptoNameAndSource(widget.symbolName, themeDark: Get.isDarkMode, height: MediaQuery.of(context).size.height / 2),
    );
  }
}
