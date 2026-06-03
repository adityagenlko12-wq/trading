import 'dart:convert';

import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:vinance/core/utils/url_container.dart';
import 'package:vinance/data/services/api_service.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../model/market/market_data_list_model.dart';
import '../../model/market/market_order_book_model.dart';

class PusherServiceController extends GetxController {
  ApiClient apiClient;
  PusherServiceController({required this.apiClient});

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  String _apiKey = "";
  String _cluster = "";

  void initPusher(String channelName) async {
    printx("$channelName ============");

    try {
      _apiKey = apiClient.getPusherConfigData().pusherAppKey ?? '';
      _cluster = apiClient.getPusherConfigData().pusherAppCluster ?? '';
      await pusher.init(
        apiKey: _apiKey,
        cluster: _cluster,
        onConnectionStateChange: (String a, String b) async {
          update();
        },
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: (_, a) {},
        onMemberAdded: (_, a) {},
        onMemberRemoved: (_, a) {},
        onAuthorizer: onAuthorizer,
      );

      await pusher.subscribe(channelName: "private-$channelName");

      await pusher.connect();
    } catch (e) {
      printx("ERROR: $e");
    }
  }

  void onError(String message, int? code, dynamic e) {
    printx("onError: $message code: $code exception: $e");
  }

  void onSubscriptionError(String message, dynamic e) {
    printx("onSubscriptionError: $message Exception: $e");
  }

  Future<void> subscribeToChannel(String channelName, {String? eventType, required bool istrigger}) async {
    printx('inside subcribe');

    if (!istrigger) {
      await pusher.subscribe(
        channelName: channelName,
      );
    }

    printx('subscribed..... ');
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    printx("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    printx("Me: $me");
    printx('subscribed success');
  }

  String currentEventName = '';
  SideOrderBook? sideOrderBook;
  void onEvent(PusherEvent event) {
    printx("Event found ${event.channelName}");
    printx("EvenWt name ${event.eventName}");
    currentEventName = event.eventName;

    if (event.eventName == 'market-data') {
      final eventData = json.decode(event.data) as Map<String, dynamic>;
      setMarketDataFromPusherEvent(eventData);
    }
    if (event.eventName.contains("order-placed")) {
      final eventData = json.decode(event.data) as Map<String, dynamic>;
      setOrderBookData(eventData);
    }
    update();
  }

  onAuthorizer(String channelName, String socketId, options) async {
    socketId = socketId;
    update();

    var authUrl = "${UrlContainer.domainUrl}/${UrlContainer.pusherAuthApiURl}/$socketId/$channelName";
    var result = await http.post(
      Uri.parse(authUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var json = jsonDecode(result.body);
    return json;
  }

  //STORE DATA
  List<MarketData> marketData = [];
  MarketData? marketDataFromPusher;
  setMarketDataFromPusherEvent(Map<String, dynamic> data) {
    //From Market Data

    try {
      if (data["marketData"] != null) {
        marketData.clear();
        for (var element in (data["marketData"] as List)) {
          printx("price - ${jsonDecode(element)["symbol"]} ${jsonDecode(element)["id"]} -- ${jsonDecode(element)["price"]} -- ${jsonDecode(element)["html_classes"]['percent_change_1h'].toString()}");

          marketData.add(MarketData(
            id: jsonDecode(element)["id"].toString(),
            symbol: jsonDecode(element)["symbol"].toString(),
            price: jsonDecode(element)["price"].toString(),
            marketCap: jsonDecode(element)["market_cap"].toString(),
            percentChange1H: jsonDecode(element)["percent_change_1h"].toString(),
            percentChange24H: jsonDecode(element)["percent_change_24h"].toString(),
            htmlClasses: HtmlClasses(
              percentChange1H: jsonDecode(element)["html_classes"]['percent_change_1h'].toString(),
              percentChange24H: jsonDecode(element)["html_classes"]['percent_change_24h'].toString(),
            ),
          ));
        }
        update();

        printx(marketData.length);

        update();
      } else {
        printx("marketData is null");
      }
    } catch (e) {
      printx(e.toString());
    }
  }

  setOrderBookData(Map<String, dynamic> data) {
    printx((data["order"] is Map) == true);
    if ((data["order"] is Map) == true) {
      try {
        sideOrderBook = SideOrderBook(
          id: data['order']["id"],
          userId: data['order']["user_id"].toString(),
          pairId: (data['order']["pair_id"].toString()),
          coinId: (data['order']["coin_id"].toString()),
          trx: (data['order']["trx"].toString()),
          orderSide: (data['order']["order_side"].toString()),
          orderType: (data['order']["order_type"].toString()),
          rate: (data['order']["rate"].toString()),
          price: (data['order']["price"].toString()),
          amount: (data['order']["amount"].toString()),
          total: (data['order']["total"].toString()),
          filledAmount: (data['order']["filled_amount"].toString()),
          filedPercentage: (data['order']["filed_percentage"].toString()),
          charge: (data['order']["charge"].toString()),
          status: (data['order']["status"].toString()),
          createdAt: (data['order']["created_at"].toString()),
          updatedAt: (data['order']["updated_at"].toString()),
          orderSideBadge: (data['order']["order_side_badge"].toString()),
          formattedDate: (data['order']["formatted_date"].toString()),
          statusBadge: (data['order']["status_badge"].toString()),
        );
      } catch (e) {
        printx(e.toString());
      }
    }
  }
}
