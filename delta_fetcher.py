"""
Delta Exchange Data Fetcher Module for the F&O Trading System.
Fetches crypto spot, futures, options chain, and candlestick data from Delta Exchange API.
"""

import logging
import aiohttp
import asyncio
import time
import pytz
from datetime import datetime
from typing import List, Dict, Optional, Tuple, Any

from indicators import StrikeData, CandleData

logger = logging.getLogger(__name__)

class DeltaDataFetcher:
    """Fetcher for Delta Exchange crypto derivatives and spot data."""
    
    def __init__(self):
        self.base_url = "https://api.delta.exchange/v2"
        self._session = None
        self.ist = pytz.timezone('Asia/Kolkata')
        
    async def _get_session(self) -> aiohttp.ClientSession:
        if self._session is None or self._session.closed:
            self._session = aiohttp.ClientSession()
        return self._session

    async def close(self):
        if self._session and not self._session.closed:
            await self._session.close()
            
    async def _make_request(self, url: str, params: Dict = None) -> Optional[Dict]:
        try:
            session = await self._get_session()
            async with session.get(url, params=params, timeout=10) as response:
                if response.status == 200:
                    return await response.json()
                else:
                    text = await response.text()
                    logger.error(f"Delta API error: {response.status} - {text}")
                    return None
        except Exception as e:
            logger.error(f"Delta API exception: {e}")
            return None

    async def get_expiry_dates(self, asset: str = "BTC") -> Tuple[Optional[str], List[str]]:
        """Get sorted list of expiry dates for Call/Put options of a given asset."""
        url = f"{self.base_url}/tickers"
        params = {
            "contract_types": "call_options,put_options",
            "underlying_asset_symbols": asset.upper()
        }
        res = await self._make_request(url, params)
        if not res or not res.get("success"):
            return None, []
            
        exp_dates = set()
        for item in res.get("result", []):
            symbol = item.get("symbol", "")
            # e.g., P-BTC-65400-150626
            parts = symbol.split("-")
            if len(parts) >= 4:
                exp_str = parts[3]
                try:
                    # Expiry is DDMMYY
                    dt = datetime.strptime(exp_str, "%d%m%y")
                    exp_dates.add(dt.strftime("%Y-%m-%d"))
                except ValueError:
                    continue
                    
        sorted_expiries = sorted(list(exp_dates))
        nearest = sorted_expiries[0] if sorted_expiries else None
        return nearest, sorted_expiries

    async def get_option_chain(self, expiry_date: str, asset: str = "BTC") -> Tuple[List[StrikeData], float]:
        """Fetch option chain for a specific asset and expiry date."""
        # Convert YYYY-MM-DD expiry back to DDMMYY format for filtering Delta symbols
        try:
            dt = datetime.strptime(expiry_date, "%Y-%m-%d")
            delta_exp_str = dt.strftime("%d%m%y")
        except ValueError:
            logger.error(f"Invalid expiry_date format: {expiry_date}")
            return [], 0.0
            
        url = f"{self.base_url}/tickers"
        params = {
            "contract_types": "call_options,put_options",
            "underlying_asset_symbols": asset.upper()
        }
        res = await self._make_request(url, params)
        if not res or not res.get("success"):
            return [], 0.0
            
        strikes_map = {}
        spot_price = 0.0
        
        for item in res.get("result", []):
            symbol = item.get("symbol", "")
            parts = symbol.split("-")
            if len(parts) < 4:
                continue
                
            opt_type, und_asset, strike_str, exp_str = parts[0], parts[1], parts[2], parts[3]
            if exp_str != delta_exp_str or und_asset.upper() != asset.upper():
                continue
                
            try:
                strike_price = int(float(strike_str))
            except ValueError:
                continue
                
            if spot_price == 0.0:
                spot_price = float(item.get("spot_price") or item.get("greeks", {}).get("spot") or 0.0)
                
            if strike_price not in strikes_map:
                strikes_map[strike_price] = {"CE": None, "PE": None}
                
            if opt_type == "C":
                strikes_map[strike_price]["CE"] = item
            elif opt_type == "P":
                strikes_map[strike_price]["PE"] = item
                
        # If spot price is still 0, try to fetch it separately or fallback
        if spot_price == 0.0:
            spot_price = await self.get_spot_price(asset)
            
        strikes_data = []
        for strike, type_map in strikes_map.items():
            ce = type_map["CE"]
            pe = type_map["PE"]
            
            call_ltp = float(ce.get("close") or ce.get("mark_price") or 0.0) if ce else 0.0
            call_oi = int(float(ce.get("oi_contracts") or ce.get("oi") or 0.0)) if ce else 0
            call_volume = int(float(ce.get("volume") or 0.0)) if ce else 0
            call_iv = float(ce.get("quotes", {}).get("mark_iv") or 0.0) * 100 if ce else None
            
            put_ltp = float(pe.get("close") or pe.get("mark_price") or 0.0) if pe else 0.0
            put_oi = int(float(pe.get("oi_contracts") or pe.get("oi") or 0.0)) if pe else 0
            put_volume = int(float(pe.get("volume") or 0.0)) if pe else 0
            put_iv = float(pe.get("quotes", {}).get("mark_iv") or 0.0) * 100 if pe else None
            
            strike_data = StrikeData(
                strike_price=strike,
                call_oi=call_oi,
                put_oi=put_oi,
                call_volume=call_volume,
                put_volume=put_volume,
                call_ltp=call_ltp,
                put_ltp=put_ltp,
                call_key=ce.get("symbol", "") if ce else f"C-{asset.upper()}-{strike}-{delta_exp_str}",
                put_key=pe.get("symbol", "") if pe else f"P-{asset.upper()}-{strike}-{delta_exp_str}",
                call_iv=call_iv,
                put_iv=put_iv
            )
            strikes_data.append(strike_data)
            
        # Sort strikes ascending
        strikes_data.sort(key=lambda x: x.strike_price)
        return strikes_data, spot_price

    async def get_spot_price(self, asset: str) -> float:
        """Get live spot price for a given asset (BTC or ETH)."""
        symbol = f"{asset.upper()}USDT"
        url = f"{self.base_url}/tickers/{symbol}"
        res = await self._make_request(url)
        if res and res.get("success"):
            result = res.get("result", {})
            return float(result.get("spot_price") or result.get("close") or result.get("mark_price") or 0.0)
        # Fallbacks
        return 65000.0 if asset.upper() == "BTC" else 3500.0

    async def get_candles(self, symbol: str, interval: str = "5", unit: str = "minutes") -> List[CandleData]:
        """Fetch candle data for a symbol (e.g. BTCUSDT, ETHUSDT or option symbols)."""
        resolution = "5m"
        if unit == "minutes":
            if interval == "1": resolution = "1m"
            elif interval == "3": resolution = "3m"
            elif interval == "5": resolution = "5m"
            elif interval == "15": resolution = "15m"
            elif interval == "30": resolution = "30m"
        elif unit == "hours":
            if interval == "1": resolution = "1h"
            elif interval == "2": resolution = "2h"
            elif interval == "4": resolution = "4h"
        elif unit == "days" or interval == "1d" or unit == "1d":
            resolution = "1d"
            
        # Normalize symbol
        sym = symbol.upper()
        if sym in ["BTC", "ETH"]:
            sym = f"{sym}USDT"
            
        end_time = int(time.time())
        seconds_back = 300 * 5 * 60
        if resolution == "1m": seconds_back = 300 * 60
        elif resolution == "3m": seconds_back = 300 * 3 * 60
        elif resolution == "5m": seconds_back = 300 * 5 * 60
        elif resolution == "15m": seconds_back = 300 * 15 * 60
        elif resolution == "30m": seconds_back = 300 * 30 * 60
        elif resolution == "1h": seconds_back = 300 * 3600
        elif resolution == "2h": seconds_back = 300 * 2 * 3600
        elif resolution == "4h": seconds_back = 300 * 4 * 3600
        elif resolution == "1d": seconds_back = 300 * 86400
        
        start_time = end_time - seconds_back
        
        url = f"{self.base_url}/history/candles"
        params = {
            "symbol": sym,
            "resolution": resolution,
            "start": start_time,
            "end": end_time
        }
        res = await self._make_request(url, params)
        if not res or not res.get("success"):
            return []
            
        candles = []
        for c in res.get("result", []):
            try:
                dt = datetime.fromtimestamp(c["time"], self.ist)
                timestamp_str = dt.strftime("%Y-%m-%dT%H:%M:%S+05:30")
                candles.append(CandleData(
                    timestamp=timestamp_str,
                    open=float(c["open"]),
                    high=float(c["high"]),
                    low=float(c["low"]),
                    close=float(c["close"]),
                    volume=int(float(c["volume"]))
                ))
            except Exception:
                continue
        return candles

def fetch_delta_candles_sync(symbol: str, interval: str = "5", unit: str = "minutes") -> List[CandleData]:
    """Synchronous wrapper to fetch Delta Exchange candle data."""
    import concurrent.futures
    import logging
    
    logger = logging.getLogger(__name__)
    
    def run_async():
        async def fetch():
            fetcher = DeltaDataFetcher()
            try:
                candles = await fetcher.get_candles(symbol, interval, unit)
                await fetcher.close()
                return candles
            except Exception as e:
                logger.error(f"Error in fetch_delta_candles_sync: {e}")
                await fetcher.close()
                return []
        
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(fetch())
        finally:
            loop.close()
            
    try:
        with concurrent.futures.ThreadPoolExecutor() as executor:
            future = executor.submit(run_async)
            return future.result(timeout=15)
    except Exception as e:
        logger.error(f"fetch_delta_candles_sync timeout or error: {e}")
        return []
