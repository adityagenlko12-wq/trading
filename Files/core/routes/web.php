<?php

use Illuminate\Support\Facades\Route;

// Secret key for admin utility routes (change this to your own secret)
define('ADMIN_ROUTE_SECRET', 'vinance2024secret');

Route::get('/clear', function(){
    \Illuminate\Support\Facades\Artisan::call('optimize:clear');
});

Route::get('/run-migrations', function(){
    if (request()->key !== ADMIN_ROUTE_SECRET) abort(403, 'Unauthorized');
    \Illuminate\Support\Facades\Artisan::call('migrate');
    return "Migrations executed successfully!";
});

Route::get('/update-upstox-token-secure', function(){
    if (request()->key !== ADMIN_ROUTE_SECRET) abort(403, 'Unauthorized');
    // Alter the configuration column to TEXT to support long JWT tokens
    try {
        \Illuminate\Support\Facades\DB::statement("ALTER TABLE `currency_data_providers` MODIFY COLUMN `configuration` TEXT NOT NULL");
    } catch (\Exception $e) {
        // Suppress if already altered or errors
    }

    $token = request()->token ?? 'eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiI1NEMzSEgiLCJqdGkiOiI2YTFmYzNmMTk5NmRjNDYzNWI2ZjlmM2YiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc4MDQ2NjY3MywiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzgwNTI0MDAwfQ.iIXC0lSXyzNnP2kWRTT3B2AQbqQ93SOg9eRSS6N03vE';
    $config = json_encode([
        'access_token' => [
            'title' => 'Access Token',
            'value' => $token
        ]
    ]);
    
    // Deactivate existing providers
    \Illuminate\Support\Facades\DB::update("UPDATE currency_data_providers SET is_default = 0, status = 0");
    
    // Insert/Update Upstox provider
    $exists = \Illuminate\Support\Facades\DB::select("SELECT id FROM currency_data_providers WHERE alias = 'Upstox'");
    if (empty($exists)) {
        \Illuminate\Support\Facades\DB::insert("INSERT INTO currency_data_providers (id, name, alias, configuration, type, status, help, image, is_default, instruction, created_at, updated_at) 
            VALUES (3, 'Upstox', 'Upstox', ?, 1, 1, 'Configure Upstox API credentials. Visit Upstox developer center to generate access token.', 'upstox.png', 1, '<ul class=\"list-group list-group-flush\"><li class=\"list-group-item\">Go to Upstox Developer Portal</li><li class=\"list-group-item\">Register your app and authenticate to get your access token</li><li class=\"list-group-item\">Insert your Access Token here</li></ul>', NOW(), NOW())", [$config]);
    } else {
        \Illuminate\Support\Facades\DB::update("UPDATE currency_data_providers SET name = 'Upstox', alias = 'Upstox', configuration = ?, status = 1, is_default = 1 WHERE alias = 'Upstox'", [$config]);
    }
    
    return "UPSTOX_TOKEN_UPDATE_SUCCESS";
});



Route::get('/seed-nse-stocks', function() {
    if (request()->key !== ADMIN_ROUTE_SECRET) abort(403, 'Unauthorized');
    try {
        // 1. Find or create INR base currency (type = 2, status = 1, sign = '₹')
        $inr = \App\Models\Currency::where('symbol', 'INR')->first();
        if ($inr) {
            $inr->name = 'Indian Rupee';
            $inr->type = 2; // Fiat
            $inr->status = 1;
            $inr->sign = '₹';
            $inr->save();
        } else {
            $inr = new \App\Models\Currency();
            $inr->name = 'Indian Rupee';
            $inr->symbol = 'INR';
            $inr->type = 2; // Fiat
            $inr->status = 1;
            $inr->sign = '₹';
            $inr->save();
        }
        
        // 2. Find or create INR Market
        $market = \App\Models\Market::where('name', 'INR Market')->first();
        if (!$market) {
            $market = new \App\Models\Market();
            $market->name = 'INR Market';
            $market->currency_id = $inr->id;
            $market->status = 1;
            $market->save();
        } else {
            $market->currency_id = $inr->id;
            $market->status = 1;
            $market->save();
        }
        
        // 3. Define top 80 traded liquid NSE stock symbols
        $popularSymbols = [
            'RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK', 'SBIN', 'BHARTIAIRTEL', 'LT', 'ITC', 'HINDUNILVR',
            'AXISBANK', 'KOTAKBANK', 'M&M', 'BAJFINANCE', 'MARUTI', 'WIPRO', 'ULTRACEMCO', 'HCLTECH', 'SUNPHARMA', 'ADANIENT',
            'JSWSTEEL', 'TATASTEEL', 'NTPC', 'POWERGRID', 'TITAN', 'ADANIPORTS', 'GRASIM', 'COALINDIA', 'HINDALCO', 'TATAMOTORS',
            'ONGC', 'TECHM', 'CIPLA', 'APOLLOHOSP', 'HEROMOTOCO', 'DRREDDY', 'EICHERMOT', 'BPCL', 'DIVISLAB', 'INDUSINDBK',
            'NESTLEIND', 'BRITANNIA', 'UPL', 'SHREECEM', 'BAJAJFINSV', 'HDFCLIFE', 'SBILIFE', 'TATACONSUM', 'JIOFIN', 'ADANIPOWER',
            'DLF', 'HAL', 'BEL', 'IRFC', 'REC', 'PFC', 'ZOMATO', 'PAYTM', 'TRENT', 'DMART', 'VBL', 'TATAELXSI',
            'PERSISTENT', 'LTIM', 'KPIT', 'COFORGE', 'BOSCHLTD', 'MRF', 'PAGEIND', 'COLPAL', 'PIDILITIND', 'GODREJCP',
            'DABUR', 'MARICO', 'BALKRISIND', 'ASHOKLEY', 'TVSMOTOR', 'BHARATFORG', 'CEATLTD', 'APOLLOTYRE', 'EXIDEIND', 'AMARAJABAT'
        ];
        
        $popularLookup = array_flip($popularSymbols);
        
        // 4. Download and stream the Upstox complete instruments list CSV
        $url = "https://assets.upstox.com/market-quote/instruments/exchange/complete.csv.gz";
        $tempFile = storage_path('app/upstox_inst_temp.csv.gz');
        
        // Ensure directory exists
        if (!file_exists(dirname($tempFile))) {
            mkdir(dirname($tempFile), 0755, true);
        }
        
        // Set user_agent globally so copy() uses it when making the HTTP request
        ini_set('user_agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        
        copy($url, $tempFile);
        
        $file = gzopen($tempFile, "r");
        if (!$file) {
            return "ERROR: Failed to open compressed instruments file.";
        }
        
        // Skip header
        $header = fgetcsv($file);
        
        $count = 0;
        while (($row = fgetcsv($file)) !== false) {
            if (count($row) < 12) continue;
            
            $instrument_key = $row[0];
            $trading_symbol = $row[2];
            $name = $row[3];
            $instrument_type = $row[9];
            $exchange = $row[11];
            
            if ($exchange === 'NSE_EQ' && $instrument_type === 'EQUITY' && isset($popularLookup[$trading_symbol])) {
                // Seed Currency (Stock)
                $stock = \App\Models\Currency::where('symbol', $instrument_key)->first();
                if (!$stock) {
                    $stock = new \App\Models\Currency();
                    $stock->type = 1; // Crypto/Stock
                    $stock->symbol = $instrument_key;
                    $stock->name = $trading_symbol;
                    $stock->image = 'upstox.png';
                    $stock->status = 1;
                    $stock->save();
                }
                
                // Seed CoinPair
                $pairSymbol = $stock->symbol . '_' . $inr->symbol;
                $pair = \App\Models\CoinPair::where('symbol', $pairSymbol)->first();
                if (!$pair) {
                    $pair = new \App\Models\CoinPair();
                    $pair->market_id = $market->id;
                    $pair->coin_id = $stock->id;
                    $pair->symbol = $pairSymbol;
                    $pair->minimum_buy_amount = 0.0001;
                    $pair->maximum_buy_amount = -1;
                    $pair->minimum_sell_amount = 0.0001;
                    $pair->maximum_sell_amount = -1;
                    $pair->percent_charge_for_buy = 0;
                    $pair->percent_charge_for_sell = 0;
                    $pair->status = 1;
                    $pair->is_default = ($trading_symbol === 'RELIANCE') ? 1 : 0;
                    $pair->listed_market_name = 'UPSTOX';
                    $pair->save();
                }
                
                // Seed MarketData
                $marketData = \App\Models\MarketData::where('pair_id', $pair->id)->where('currency_id', 0)->first();
                if (!$marketData) {
                    $marketData = new \App\Models\MarketData();
                    $marketData->pair_id = $pair->id;
                    $marketData->currency_id = 0;
                    $marketData->symbol = $stock->symbol;
                    $marketData->save();
                }
                
                $count++;
            }
        }
        
        gzclose($file);
        @unlink($tempFile);
        
        // Make sure there is exactly one default pair
        \App\Models\CoinPair::where('symbol', '!=', 'NSE_EQ|INE002A01018_INR')->update(['is_default' => 0]);
        \App\Models\CoinPair::where('symbol', 'NSE_EQ|INE002A01018_INR')->update(['is_default' => 1]);
        
        return "SUCCESSFULLY_SEEDED_" . $count . "_NSE_STOCKS";
        
    } catch (\Exception $e) {
        return "ERROR: " . $e->getMessage() . " on line " . $e->getLine();
    }
});

Route::get('/update-nse-prices', function() {
    if (request()->key !== ADMIN_ROUTE_SECRET) abort(403, 'Unauthorized');
    try {
        $controller = new \App\Http\Controllers\CronController();
        $controller->market();
        return "SUCCESSFULLY_UPDATED_NSE_PRICES";
    } catch (\Exception $e) {
        return "ERROR: " . $e->getMessage() . " on line " . $e->getLine();
    }
});





Route::get('cron', 'CronController@cron')->name('cron');

// User Support Ticket
Route::controller('TicketController')->prefix('ticket')->name('ticket.')->group(function () {
    Route::get('/', 'supportTicket')->name('index');
    Route::get('new', 'openSupportTicket')->name('open');
    Route::post('create', 'storeSupportTicket')->name('store');
    Route::get('view/{ticket}', 'viewTicket')->name('view');
    Route::post('reply/{id}', 'replyTicket')->name('reply');
    Route::post('close/{id}', 'closeTicket')->name('close');
    Route::get('download/{attachment_id}', 'ticketDownload')->name('download');
});

Route::get('app/deposit/confirm/{hash}', 'Gateway\PaymentController@appDepositConfirm')->name('deposit.app.confirm');


Route::controller("TradeController")->prefix('trade')->group(function () {
    Route::get('/order/book/{symbol}', 'orderBook')->name('trade.order.book');
    Route::get('pairs', 'pairs')->name('trade.pairs');
    Route::get('history/{symbol}', 'history')->name('trade.history');
    Route::get('order/list/{pairSym}', 'orderList')->name('trade.order.list');
    Route::get('/{symbol?}', 'trade')->name('trade');
});


Route::namespace('P2P')->group(function () {
    Route::controller("HomeController")->prefix('p2p')->group(function () {
        Route::get("/advertiser/{username}", 'advertiser')->name('p2p.advertiser');
        Route::get("/{type?}/{coin?}/{currency?}/{paymentMethod?}/{region?}/{amount?}", 'p2p')->name('p2p');
    });
});

Route::controller('SiteController')->group(function () {
    Route::get('/pwa/configuration', 'pwaConfiguration')->name('pwa.configuration');
    Route::get('/market/list', 'marketList')->name('market.list');
    Route::get('/crypto/list', 'cryptoCurrencyList')->name('crypto_currency.list');
    Route::get('/market', 'market')->name('market');
    Route::post('/subscribe', 'subscribe')->name('subscribe');
    Route::get('/crypto-currency', 'crypto')->name('crypto_currencies');
    Route::get('/crypto/currency/{symbol}', 'cryptoCurrencyDetails')->name('crypto.details');
    Route::get('/about-us', 'about')->name('about');
    Route::post('pusher/auth/{socketId}/{channelName}', "pusherAuthentication");

    Route::get('/contact', 'contact')->name('contact');
    Route::post('/contact', 'contactSubmit');
    Route::get('/change/{lang?}', 'changeLanguage')->name('lang');
    Route::get('cookie-policy', 'cookiePolicy')->name('cookie.policy');
    Route::get('/cookie/accept', 'cookieAccept')->name('cookie.accept');
    Route::get('blog/{slug}', 'blogDetails')->name('blog.details');
    Route::get('policy/{slug}', 'policyPages')->name('policy.pages');
    Route::get('placeholder-image/{size}', 'placeholderImage')->name('placeholder.image')->withoutMiddleware('maintenance');
    Route::get('maintenance-mode','maintenance')->withoutMiddleware('maintenance')->name('maintenance');

    Route::get('/{slug}', 'pages')->name('pages');
    Route::get('/', 'index')->name('home');
});
