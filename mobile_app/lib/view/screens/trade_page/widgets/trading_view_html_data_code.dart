class TradingViewHtmlDataCode {
  static String cryptoNameAndSource(String name, {required double height, required bool themeDark}) {
    return """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$name</title>

  <!-- Other head elements go here -->

</head>
<body>
 <!-- TradingView Widget BEGIN -->


  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
  new TradingView.widget(
  {
  "width": "100%",
  "height": $height,
  "symbol": "$name",
  "interval": "D",
  "timezone": "Etc/UTC",
  "theme": "${themeDark == true ? 'dark' : 'light'}",
  "style": "1",
  "locale": "en",
  "enable_publishing": false,
  "allow_symbol_change": true,
  "container_id": "tradingview_92622"
}
  );
  </script>

<!-- TradingView Widget END -->

</body>
</html>

""";
  }
}
