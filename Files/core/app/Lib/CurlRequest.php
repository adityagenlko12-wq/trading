<?php

namespace App\Lib;

class CurlRequest
{
    const USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 VinanceTradingBot/1.0';

    /**
    * GET request using curl
    *
    * @return mixed
    */
	public static function curlContent($url,$header = null)
	{
	    $ch = curl_init();
	    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
	    if ($header) {
	    	curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
	    }
	    curl_setopt($ch, CURLOPT_URL, $url);
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	    curl_setopt($ch, CURLOPT_USERAGENT, self::USER_AGENT);
	    $result = curl_exec($ch);
	    curl_close($ch);
	    return $result;
	}


    /**
    * POST request using curl
    *
    * @return mixed
    */
	public static function curlPostContent($url, $postData = null,$header = null)
	{
	    if (is_array($postData)) {
	        $params = http_build_query($postData);
	    } else {
	        $params = $postData;
	    }
	    $ch = curl_init();
	    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
	    if ($header) {
	    	curl_setopt($ch, CURLOPT_HTTPHEADER, $header);
	    }
	    curl_setopt($ch, CURLOPT_URL, $url);
	    curl_setopt($ch, CURLOPT_POSTFIELDS, $params);
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	    curl_setopt($ch, CURLOPT_USERAGENT, self::USER_AGENT);
	    $result = curl_exec($ch);
	    curl_close($ch);
	    return $result;
	}
}
