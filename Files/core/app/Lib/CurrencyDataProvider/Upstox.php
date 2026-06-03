<?php

namespace App\Lib\CurrencyDataProvider;

use App\Constants\Status;
use App\Events\MarketDataEvent;
use App\Lib\CurlRequest;
use App\Models\Currency;
use App\Models\CurrencyDataProvider as CurrencyDataProviderModel;
use App\Models\MarketData;
use Exception;

class Upstox extends CurrencyDataProvider
{
    /**
     * Maximum number of symbols per Upstox API batch request.
     */
    const BATCH_SIZE = 25;

    /**
     * Update stock prices and market data.
     *
     * @return void
     * @throws Exception if there is an error with the API call or data processing.
     *
     */
    public function updateCryptoPrice()
    {
        $cryptoCurrencyList = $this->cryptoCurrencyList();
        $allSymbols         = $cryptoCurrencyList->pluck('symbol')->toArray();

        if (empty($allSymbols)) {
            return;
        }

        $updatedMarketData = [];
        $convertTo = $this->fetchCryptoConvertTo();

        // Batch symbols to avoid Upstox API limits
        $batches = array_chunk($allSymbols, self::BATCH_SIZE);

        foreach ($batches as $batchSymbols) {
            $symbol = implode(',', $batchSymbols);
            $parameters = ['symbol' => $symbol];

            try {
                $data = $this->apiCall($parameters);
            } catch (Exception $e) {
                continue; // Skip this batch on error
            }

            if (!isset($data->status) || $data->status != 'success') {
                continue; // Skip failed batches instead of throwing
            }

            foreach ($data->data ?? [] as $key => $item) {
                $symbolKey = isset($item->instrument_token) ? strtoupper($item->instrument_token) : strtoupper($key);
                $cryptoCurrency = $cryptoCurrencyList->filter(function($c) use ($symbolKey) {
                    return strtoupper($c->symbol) === $symbolKey;
                })->first();

                if (!$cryptoCurrency) {
                    continue;
                }

                $marketData = $cryptoCurrency->marketData;
                $lastPrice = $item->last_price ?? 0;

                if (!$marketData || !$lastPrice) {
                    continue;
                }

                $cryptoCurrency->rate = $lastPrice;
                $cryptoCurrency->last_update = time();
                $cryptoCurrency->save();

                // Net change could be positive or negative
                $netChange = $item->net_change ?? 0;
                $ohlc = $item->ohlc ?? null;
                $openPrice = $ohlc->open ?? $lastPrice;
                $percentChange = $openPrice > 0 ? ($netChange / $openPrice) * 100 : 0;

                $itemData = (object)[
                    'price' => $lastPrice,
                    'percent_change_1h' => $percentChange,
                    'percent_change_24h' => $percentChange,
                    'percent_change_7d' => $percentChange,
                    'market_cap' => ($item->volume ?? 0) * $lastPrice,
                    'volume_change_24h' => $item->volume ?? 0
                ];

                $updatedMarketData[] = $this->updateMarketData($marketData, $itemData, $convertTo);
            }
        }

        try {
            event(new MarketDataEvent($updatedMarketData));
        } catch (Exception $ex) {
            // Silence Pusher broadcasting errors
        }
        echo 'STOCK PRICE UPDATE <br/>  ' . date("h:m:s") . ' ';
    }

    /**
     * Update market data for all active markets.
     *
     * @return void
     * @throws Exception if there is an error with the API call or data processing.
     *
     */
    public function updateMarkets()
    {
        $conflagration = $this->configuration();
        $markets       = $this->marketList();
        $updatedMarketData = [];

        foreach ($markets as $market) {
            $pairs     = $market->pairs;
            $allSymbols = $pairs->pluck('coin.symbol')->filter()->toArray();
            $convertTo = $market->currency->symbol;

            if (empty($allSymbols)) {
                continue;
            }

            // Batch symbols to avoid Upstox API limits
            $batches = array_chunk($allSymbols, self::BATCH_SIZE);

            foreach ($batches as $batchSymbols) {
                $symbol = implode(',', $batchSymbols);
                $parameters = ['symbol' => $symbol];

                try {
                    $data = $this->apiCall($parameters, $conflagration);
                } catch (Exception $e) {
                    continue; // Skip this batch on error
                }

                if (!isset($data->status) || $data->status != 'success') {
                    continue; // Skip failed batches
                }

                foreach ($data->data ?? [] as $key => $item) {
                    $symbolKey = isset($item->instrument_token) ? strtoupper($item->instrument_token) : strtoupper($key);
                    $pair = $pairs->filter(function($p) use ($symbolKey) {
                        return strtoupper($p->coin->symbol) === $symbolKey;
                    })->first();

                    $marketData = @$pair->marketData;
                    $lastPrice = @$item->last_price;

                    if (!$pair || !$marketData || !$lastPrice) {
                        continue;
                    }

                    $netChange = $item->net_change ?? 0;
                    $ohlc = $item->ohlc ?? null;
                    $openPrice = $ohlc->open ?? $lastPrice;
                    $percentChange = $openPrice > 0 ? ($netChange / $openPrice) * 100 : 0;

                    $itemData = (object)[
                        'price' => $lastPrice,
                        'percent_change_1h' => $percentChange,
                        'percent_change_24h' => $percentChange,
                        'percent_change_7d' => $percentChange,
                        'market_cap' => ($item->volume ?? 0) * $lastPrice,
                        'volume_change_24h' => $item->volume ?? 0
                    ];

                    $updatedMarketData[] = $this->updateMarketData($marketData, $itemData, $convertTo);
                }
            }
        }

        try {
            event(new MarketDataEvent($updatedMarketData));
        } catch (Exception $ex) {
            // Silence Pusher broadcasting errors
        }

        echo 'STOCK PRICE UPDATE <br/> ' . date("h:m:s");
    }

    /**
     * Make an API call to the Upstox API.
     *
     * @param array $parameters
     * @param array|null $conflagration
     * @param string $endPoint
     * @return object
     *
     */
    public function apiCall($parameters = null, $conflagration = null, $endPoint = "v2/market-quote/quotes")
    {
        if (!$conflagration) $conflagration = $this->configuration();
        $url           = $conflagration['base_url'] . $endPoint;
        $accessToken   = $conflagration['access_token'];
        $headers       = [
            'Accept: application/json',
            'Authorization: Bearer ' . $accessToken
        ];
        $qs       = $parameters ?  http_build_query($parameters) : "";
        $response = CurlRequest::curlContent("{$url}?{$qs}", $headers);
        return json_decode($response);
    }

    /**
     * Update the market data for a specific market with the provided data.
     *
     * @param \App\Models\MarketData $systemMarketData
     * @param mixed $providerMarketData
     * @param string $convertTo
     * @return string
     *
     */
    protected function updateMarketData($systemMarketData, $providerMarketData, $convertTo)
    {
        $systemMarketData->last_price              = $systemMarketData->price;
        $systemMarketData->last_percent_change_1h  = $systemMarketData->percent_change_1h;
        $systemMarketData->last_percent_change_24h = $systemMarketData->percent_change_24h;
        $systemMarketData->last_percent_change_7d  = $systemMarketData->percent_change_7d;

        $htmlClasses = [
            'price_change'       => upOrDown($providerMarketData->price, $systemMarketData->price),
            'percent_change_1h'  => upOrDown($providerMarketData->percent_change_1h, $systemMarketData->percent_change_1h),
            'percent_change_24h' => upOrDown($providerMarketData->percent_change_24h, $systemMarketData->percent_change_24h),
            'percent_change_7d'  => upOrDown($providerMarketData->percent_change_7d, $systemMarketData->percent_change_7d),
        ];

        $systemMarketData->price              = abs($providerMarketData->price);
        $systemMarketData->percent_change_1h  = abs($providerMarketData->percent_change_1h);
        $systemMarketData->percent_change_24h = abs($providerMarketData->percent_change_24h);
        $systemMarketData->percent_change_7d  = abs($providerMarketData->percent_change_7d);
        $systemMarketData->market_cap         = abs($providerMarketData->market_cap);
        $systemMarketData->volume_24h         = abs($providerMarketData->volume_change_24h);
        $systemMarketData->html_classes       = $htmlClasses;
        $systemMarketData->save();

        return json_encode([
            'symbol'             => $systemMarketData->symbol,
            'price'              => $systemMarketData->price,
            'percent_change_1h'  => $systemMarketData->percent_change_1h,
            'percent_change_24h' => $systemMarketData->percent_change_24h,
            'html_classes'       => $systemMarketData->html_classes,
            'id'                 => $systemMarketData->id,
            'market_cap'         => $systemMarketData->market_cap,
            'last_price'         => $systemMarketData->last_price,
        ]);
    }

    /**
     * Get the configuration parameters for the Upstox API.
     *
     * @return array
     *
     */
    public function configuration()
    {
        $provider = $this->provider ? $this->provider : CurrencyDataProviderModel::where('alias', "Upstox")->first();
        return [
            'access_token'  => @$provider->configuration->access_token->value,
            'base_url'      => "https://api.upstox.com/"
        ];
    }

    /**
     * Fetch option chain for a given underlying symbol and expiry date from Upstox.
     * Returns data grouped by strike price for the blade template.
     *
     * @param string $underlyingKey
     * @param string|null $expiryDate
     * @return array [strikePrice => {strike_price, expiry, lot_size, call_options, put_options}]
     *
     */
    public function getOptionChain($underlyingKey, $expiryDate = null)
    {
        if (!$expiryDate) {
            return [];
        }

        $parameters = [
            'instrument_key' => $underlyingKey,
            'expiry_date'    => $expiryDate
        ];

        try {
            $data = $this->apiCall($parameters, null, "v2/option/chain");
            if (isset($data->status) && $data->status == 'success' && !empty($data->data)) {
                return $this->transformOptionChain($data->data);
            }
        } catch (Exception $e) {
            // Silence
        }
        return [];
    }

    /**
     * Transform raw Upstox option chain API response into a structure
     * grouped by strike price that the blade template can iterate.
     *
     * Upstox returns a flat array of objects like:
     *   [ { expiry, strike_price, call_options: {...}, put_options: {...} }, ... ]
     *
     * This method groups them by strike_price and normalizes the
     * market_data fields (ltp, net_change) for template access.
     *
     * @param array $rawData
     * @return array
     */
    private function transformOptionChain($rawData)
    {
        $grouped = [];

        foreach ($rawData as $item) {
            $strike = $item->strike_price ?? 0;
            if ($strike <= 0) continue;

            // Initialize group if not exists
            if (!isset($grouped[$strike])) {
                $grouped[$strike] = (object)[
                    'strike_price'  => $strike,
                    'expiry'        => $item->expiry ?? null,
                    'call_options'  => null,
                    'put_options'   => null,
                ];
            }

            // Store expiry at the group level
            if (isset($item->expiry)) {
                $grouped[$strike]->expiry = $item->expiry;
            }

            // Map call_options
            if (isset($item->call_options) && $item->call_options) {
                $ce = $item->call_options;
                $grouped[$strike]->call_options = (object)[
                    'instrument_key' => $ce->instrument_key ?? '',
                    'market_data'    => (object)[
                        'ltp'        => $ce->market_data->ltp ?? 0,
                        'net_change' => $ce->market_data->net_change ?? 0,
                    ],
                    'expiry'   => $item->expiry ?? null,
                    'lot_size' => $item->lot_size ?? $ce->lot_size ?? 50,
                ];
            }

            // Map put_options
            if (isset($item->put_options) && $item->put_options) {
                $pe = $item->put_options;
                $grouped[$strike]->put_options = (object)[
                    'instrument_key' => $pe->instrument_key ?? '',
                    'market_data'    => (object)[
                        'ltp'        => $pe->market_data->ltp ?? 0,
                        'net_change' => $pe->market_data->net_change ?? 0,
                    ],
                    'expiry'   => $item->expiry ?? null,
                    'lot_size' => $item->lot_size ?? $pe->lot_size ?? 50,
                ];
            }
        }

        // Sort by strike price ascending
        ksort($grouped);

        return $grouped;
    }
}
