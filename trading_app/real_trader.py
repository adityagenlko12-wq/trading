"""
Real Trader Module for the Upstox API.
Handles live order placement and position management.
"""

import logging
import aiohttp
import asyncio
import json
from datetime import datetime
from typing import Dict, List, Optional, Any

from config import UPSTOX_CONFIG, TRADING_CONFIG

logger = logging.getLogger(__name__)

class RealTrader:
    """Manages live trades on Upstox."""
    
    def __init__(self, access_token: str = None):
        self.access_token = access_token or UPSTOX_CONFIG.access_token
        self.base_url = "https://api.upstox.com/v2"
        self._session: Optional[aiohttp.ClientSession] = None
        
        # Risk management defaults
        self.max_lots = 1  # Safety first
        self.enabled = False # Must be explicitly enabled
    
    async def _get_session(self) -> aiohttp.ClientSession:
        if self._session is None or self._session.closed:
            self._session = aiohttp.ClientSession()
        return self._session

    def _get_headers(self) -> Dict[str, str]:
        return {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {self.access_token}",
        }

    async def place_order(
        self,
        index: str,
        symbol: str,  # Actual instrument key like NSE_FO|51059
        transaction_type: str, # BUY or SELL
        quantity: int,
        order_type: str = "MARKET",
        product: str = "I", # I for Intraday, D for Delivery
    ) -> Dict[str, Any]:
        """Place an order on Upstox."""
        if not self.enabled:
            logger.warning("⚠️ Real trading is NOT enabled in config. Order blocked.")
            return {"status": "error", "message": "Real trading disabled"}

        url = f"{self.base_url}/order/place"
        payload = {
            "quantity": quantity,
            "product": product,
            "validity": "DAY",
            "price": 0,
            "tag": "AI_BOT",
            "instrument_token": symbol,
            "order_type": order_type,
            "transaction_type": transaction_type,
            "disclosed_quantity": 0,
            "trigger_price": 0,
            "is_amo": False
        }

        try:
            session = await self._get_session()
            async with session.post(url, headers=self._get_headers(), json=payload) as response:
                result = await response.json()
                if response.status == 200 and result.get("status") == "success":
                    order_id = result.get("data", {}).get("order_id")
                    logger.info(f"✅ Real Order Placed: {transaction_type} {quantity} x {symbol} | OrderID: {order_id}")
                    return result
                else:
                    logger.error(f"❌ Order failed: {result}")
                    return result
        except Exception as e:
            logger.error(f"Error placing order: {e}")
            return {"status": "error", "message": str(e)}

    async def get_positions(self) -> List[Dict]:
        """Fetch current open positions."""
        url = f"{self.base_url}/portfolio/net-positions"
        try:
            session = await self._get_session()
            async with session.get(url, headers=self._get_headers()) as response:
                result = await response.json()
                if response.status == 200 and result.get("status") == "success":
                    return result.get("data", [])
                return []
        except Exception as e:
            logger.error(f"Error fetching positions: {e}")
            return []

    async def get_profile(self) -> Dict:
        """Fetch account balance and profile."""
        url = f"{self.base_url}/user/profile"
        try:
            session = await self._get_session()
            async with session.get(url, headers=self._get_headers()) as response:
                result = await response.json()
                return result.get("data", {})
        except Exception as e:
            logger.error(f"Error fetching profile: {e}")
            return {}

_real_trader = None

def get_real_trader() -> RealTrader:
    global _real_trader
    if _real_trader is None:
        _real_trader = RealTrader()
    return _real_trader
