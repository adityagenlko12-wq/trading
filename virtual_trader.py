"""
Virtual Trading Module for the F&O and Equity Trading System.
Tracks user trades, portfolios, and active positions in SQLite.
"""

import json
import logging
from datetime import datetime
from typing import Dict, Optional, List, Tuple
import pytz
from pathlib import Path

logger = logging.getLogger(__name__)

# Lot sizes for different indices
LOT_SIZES = {
    "NIFTY": 75,
    "BANKNIFTY": 30,
    "FINNIFTY": 40,
    "MIDCPNIFTY": 75,
    "SENSEX": 10,
}

class VirtualTrader:
    """Manages multi-user paper trading, wallet balance updates, holdings, and F&O positions."""
    
    def __init__(self):
        self.ist = pytz.timezone('Asia/Kolkata')
        self.last_hourly_update = None
        
    def get_stats(self, user_email: str = "admin@trading.ai") -> Dict:
        """Get paper trading portfolio stats for a user."""
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        from user_auth import get_wallet_manager
        wallet_mgr = get_wallet_manager()
        
        # 1. Available balance
        balance = wallet_mgr.get_balance(user_email)
        
        # 2. Holdings (invested amount)
        holdings = db_mgr.get_holdings(user_email)
        invested_amount = 0.0
        
        for h in holdings:
            invested_amount += h["quantity"] * h["average_price"]
            
        # 3. Active positions P&L
        open_positions = db_mgr.get_active_positions(user_email)
        open_pnl = sum(pos.get("current_pnl", 0.0) for pos in open_positions)
        
        # 4. Closed trades stats
        closed_trades = db_mgr.get_user_trades(user_email, limit=100)
        winning_trades = sum(1 for t in closed_trades if t.get("pnl", 0.0) > 0)
        losing_trades = sum(1 for t in closed_trades if t.get("pnl", 0.0) <= 0)
        total_pnl = sum(t.get("pnl", 0.0) for t in closed_trades)
        
        # Find today's P&L (closed today + current open P&L)
        today_str = datetime.now(self.ist).strftime('%Y-%m-%d')
        todays_closed_pnl = sum(t.get("pnl", 0.0) for t in closed_trades if t.get("exit_time", "").startswith(today_str))
        todays_pnl = todays_closed_pnl + open_pnl
        
        total_trades = winning_trades + losing_trades
        win_rate = (winning_trades / total_trades * 100) if total_trades > 0 else 0.0
        
        return {
            'available_balance': round(balance, 2),
            'invested_amount': round(invested_amount, 2),
            'open_trades': len(open_positions),
            'total_trades': len(closed_trades),
            'winning_trades': winning_trades,
            'losing_trades': losing_trades,
            'win_rate': round(win_rate, 1),
            'total_pnl': round(total_pnl, 2),
            'todays_pnl': round(todays_pnl, 2),
        }

    def get_open_positions_dict(self, user_email: str) -> List[Dict]:
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        return db_mgr.get_active_positions(user_email)

    def get_open_trades(self) -> List:
        """Returns open positions as objects for main loop logging compatibility."""
        from performance_manager import get_performance_manager
        positions = get_performance_manager().get_all_open_positions()
        class TradeWrapper:
            def __init__(self, d):
                self.index = d.get('symbol', '')
                self.symbol = d.get('symbol', '')
                self.signal_type = d.get('signal_type', '')
                self.strike = d.get('strike', 0)
        return [TradeWrapper(p) for p in positions]

    def close_position(self, trade_id: int, exit_premium: float) -> bool:
        """Alias for close_trade."""
        return self.close_trade(trade_id, exit_premium)


    def is_position_open(self, user_email: str, index: str, signal_type: str) -> bool:
        """Check if an open position already exists for this index and direction."""
        from performance_manager import get_performance_manager
        positions = get_performance_manager().get_active_positions(user_email)
        for pos in positions:
            if pos["symbol"] == index and pos["signal_type"] == signal_type:
                return True
        return False

    def open_trade(
        self,
        index: str,
        signal_type: str,
        strike: int,
        spot_price: float,
        entry_premium: float,
        target_points: int,
        stop_loss_points: int,
        reasoning: str = '',
        market_context: Dict = None,
        user_email: str = "admin@trading.ai"
    ) -> bool:
        """Compat/AI endpoint: Open trade for AI signals (defaults to admin)."""
        base_lot_size = LOT_SIZES.get(index.upper().replace(" ", "").replace("50", "").replace("BANK", "BANKNIFTY"), 75)
        from config import SYSTEM_CONFIG
        quantity = max(1, int(SYSTEM_CONFIG.max_lots))
        
        success, msg = self.place_user_order(
            user_email=user_email,
            symbol=index,
            type_str="OPTION",
            signal_type=signal_type,
            strike=strike,
            price=entry_premium,
            quantity=quantity,
            lot_size=base_lot_size,
            target_points=target_points,
            stop_loss_points=stop_loss_points,
            spot_at_entry=spot_price,
            reasoning=reasoning,
            market_context=market_context
        )
        return success

    def place_user_order(
        self,
        user_email: str,
        symbol: str,
        type_str: str, # STOCK, OPTION
        signal_type: str, # BUY, SELL, CALL, PUT
        strike: int, # Option strike or 0 for stock
        price: float, # LTP at order
        quantity: int,
        lot_size: int = 1,
        target_points: float = 0,
        stop_loss_points: float = 0,
        spot_at_entry: float = 0,
        reasoning: str = '',
        market_context: Dict = None
    ) -> Tuple[bool, str]:
        """Place virtual paper trade for a user and adjust wallet balance."""
        from user_auth import get_wallet_manager
        wallet_mgr = get_wallet_manager()
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        if type_str == "OPTION":
            required_capital = price * quantity * lot_size
        else:
            required_capital = price * quantity
            
        current_balance = wallet_mgr.get_balance(user_email)
        
        if signal_type in ["BUY", "CALL", "PUT"]:
            if current_balance < required_capital:
                return False, f"Insufficient balance! Required: ₹{required_capital:,.2f}, Available: ₹{current_balance:,.2f}"
                
            wallet_mgr.deduct_balance(user_email, required_capital, f"Buy Order: {symbol} @ ₹{price}")
            
            if type_str == "STOCK":
                company_name = symbol
                try:
                    import os
                    json_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "top_500_stocks.json")
                    if os.path.exists(json_path):
                        with open(json_path, "r") as f:
                            stocks_data = json.load(f)
                            for s in stocks_data:
                                if s["symbol"] == symbol:
                                    company_name = s["name"]
                                    break
                except Exception:
                    pass
                
                db_mgr.update_holding(user_email, symbol, company_name, quantity, price)
                
            else: # OPTION
                target_val = price + target_points if target_points > 0 else 0
                sl_val = price - stop_loss_points if stop_loss_points > 0 else 0
                
                db_mgr.add_active_position(
                    user_email=user_email,
                    symbol=symbol,
                    type_str="OPTION",
                    signal_type=signal_type,
                    strike=strike,
                    entry_price=price,
                    spot_at_entry=spot_at_entry or price,
                    quantity=quantity,
                    lot_size=lot_size,
                    target_price=target_val,
                    stop_loss_price=sl_val,
                )
            
            return True, "Order executed successfully"
            
        elif signal_type == "SELL" and type_str == "STOCK":
            holdings = db_mgr.get_holdings(user_email)
            h_item = next((h for h in holdings if h["symbol"] == symbol), None)
            if not h_item or h_item["quantity"] < quantity:
                return False, f"Not enough shares in holdings to sell! Owned: {h_item['quantity'] if h_item else 0}"
                
            avg_buy_price = h_item["average_price"]
            pnl = (price - avg_buy_price) * quantity
            roi = (pnl / (avg_buy_price * quantity) * 100) if avg_buy_price > 0 else 0
            
            db_mgr.update_holding(user_email, symbol, h_item["company_name"], -quantity, price)
            wallet_mgr.add_balance(user_email, required_capital, f"Sell Order: {symbol} @ ₹{price}")
            
            ist = pytz.timezone('Asia/Kolkata')
            now = datetime.now(ist)
            
            trade_dict = {
                'user_email': user_email,
                'id': int(now.timestamp()),
                'symbol': symbol,
                'type': 'STOCK',
                'signal_type': 'SELL',
                'strike': 0,
                'entry_premium': avg_buy_price,
                'exit_premium': price,
                'lot_size': quantity,
                'pnl': pnl,
                'roi_percentage': roi,
                'entry_time': h_item.get('created_at', now.isoformat()),
                'exit_time': now.isoformat(),
                'status': 'CLOSED',
                'reasoning': 'Manual equity sell',
                'market_context': {}
            }
            db_mgr.log_trade(trade_dict)
            
            return True, "Order executed successfully"
            
        return False, "Invalid order parameters"

    def close_trade(self, trade_id: int, exit_premium: float, status: str = 'CLOSED', user_email: str = None) -> bool:
        """Compat/Manual exit endpoint: Close open option position."""
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        from user_auth import get_wallet_manager
        wallet_mgr = get_wallet_manager()
        
        conn = db_mgr.db_path
        import sqlite3
        conn_db = sqlite3.connect(conn)
        conn_db.row_factory = sqlite3.Row
        cursor = conn_db.cursor()
        
        if user_email:
            cursor.execute("SELECT * FROM active_positions WHERE id = ? AND user_email = ? AND status = 'OPEN'", (trade_id, user_email))
        else:
            cursor.execute("SELECT * FROM active_positions WHERE id = ? AND status = 'OPEN'", (trade_id,))
            
        pos = cursor.fetchone()
        conn_db.close()
        
        if not pos:
            return False
            
        pos = dict(pos)
        pos_id = pos["id"]
        email = pos["user_email"]
        symbol = pos["symbol"]
        signal_type = pos["signal_type"]
        strike = pos["strike"]
        entry_price = pos["entry_price"]
        quantity = pos["quantity"]
        lot_size = pos["lot_size"]
        entry_time = pos["entry_time"]
        
        points_captured = exit_premium - entry_price
        pnl = points_captured * quantity * lot_size
        roi = (pnl / (entry_price * quantity * lot_size) * 100) if entry_price > 0 else 0
        
        db_mgr.close_active_position(pos_id, status)
        
        capital_used = entry_price * quantity * lot_size
        proceeds = capital_used + pnl
        wallet_mgr.add_balance(email, proceeds, f"Exit Position: {symbol} {signal_type} {strike} @ ₹{exit_premium}")
        
        ist = pytz.timezone('Asia/Kolkata')
        now = datetime.now(ist)
        
        trade_dict = {
            'user_email': email,
            'id': pos_id,
            'symbol': symbol,
            'type': 'OPTION',
            'signal_type': signal_type,
            'strike': strike,
            'entry_premium': entry_price,
            'exit_premium': exit_premium,
            'lot_size': quantity * lot_size,
            'pnl': pnl,
            'roi_percentage': roi,
            'entry_time': entry_time,
            'exit_time': now.isoformat(),
            'status': status,
            'reasoning': f"Option position exit: {status}",
            'market_context': {"points_captured": points_captured}
        }
        db_mgr.log_trade(trade_dict)
        
        logger.info(f"📊 Option trade closed: {email} | {symbol} {signal_type} | P&L: ₹{pnl:,.2f}")
        return True

    def check_and_update_trades(self, index: str, spot_price: float, option_quotes: Optional[Dict[Tuple[str, int], float]] = None) -> List[Dict]:
        """Update option trades only when actual option premiums are supplied.

        Spot-price movements are NOT valid substitutes for option LTP. Without
        verified instrument quotes, leave positions unchanged rather than create
        fictional P&L or trigger false stop-loss/target exits.
        """
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        if not option_quotes:
            logger.warning("Option MTM skipped for %s: verified option LTP feed unavailable", index)
            return []

        open_positions = db_mgr.get_all_open_positions()
        closed_trades = []
        
        for pos in open_positions:
            if pos["symbol"] != index or pos["type"] != "OPTION":
                continue
                
            pos_id = pos["id"]
            user_email = pos["user_email"]
            entry_price = pos["entry_price"]
            strike = pos["strike"]
            signal_type = pos["signal_type"]
            quantity = pos["quantity"]
            lot_size = pos["lot_size"]
            
            # Keys are (CALL|PUT, strike). Caller must fetch fresh option quotes
            # for the correct instrument AND expiry before passing them here.
            live_quote = option_quotes.get((signal_type, int(strike)))
            try:
                current_premium = float(live_quote)
            except (ValueError, TypeError):
                continue
            if current_premium <= 0:
                continue
            current_pnl = (current_premium - entry_price) * quantity * lot_size
            
            target_price = pos.get("target_price", 0.0)
            stop_loss_price = pos.get("stop_loss_price", 0.0)
            
            # Trailing Stop-Loss calculation (long option premium)
            profit_points = current_premium - entry_price
            new_sl_price = None
            
            if profit_points >= 20.0:
                trail_sl = entry_price + 12.0
                if trail_sl > stop_loss_price:
                    new_sl_price = trail_sl
            elif profit_points >= 15.0:
                trail_sl = entry_price + 8.0
                if trail_sl > stop_loss_price:
                    new_sl_price = trail_sl
            elif profit_points >= 10.0:
                trail_sl = entry_price  # Breakeven
                if trail_sl > stop_loss_price:
                    new_sl_price = trail_sl
            
            if new_sl_price is not None:
                stop_loss_price = new_sl_price
                db_mgr.update_position_price(pos_id, current_premium, current_pnl, stop_loss_price=stop_loss_price)
                logger.info(f"📈 Trailing SL updated for position {pos_id} to ₹{stop_loss_price:.2f} (Profit: {profit_points:.2f} pts)")
            else:
                db_mgr.update_position_price(pos_id, current_premium, current_pnl)
            
            if target_price > 0 and current_premium >= target_price:
                self.close_trade(pos_id, target_price, 'TARGET_HIT')
                closed_trades.append(pos)
            elif stop_loss_price > 0 and current_premium <= stop_loss_price:
                self.close_trade(pos_id, current_premium, 'SL_HIT')
                closed_trades.append(pos)
                
        return closed_trades

    def should_send_hourly_update(self) -> bool:
        """Check if hourly update should be sent."""
        ist = pytz.timezone('Asia/Kolkata')
        now = datetime.now(ist)
        
        # Only send during market hours
        if now.hour < 9 or now.hour > 15:
            return False
        
        # Check if an hour has passed since last update
        if self.last_hourly_update is None:
            self.last_hourly_update = now
            return True
        
        if (now - self.last_hourly_update).total_seconds() >= 3600:
            self.last_hourly_update = now
            return True
        
        return False

    def get_showcase_message(self, user_email: str = "admin@trading.ai") -> str:
        """Generate a showcase message for Telegram based on database stats."""
        stats = self.get_stats(user_email)
        ist = pytz.timezone('Asia/Kolkata')
        now = datetime.now(ist)
        
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        recent_trades = db_mgr.get_user_trades(user_email, limit=5)
        
        trades_list = ""
        for t in recent_trades:
            emoji = "✅" if t.get("pnl", 0.0) > 0 else "❌"
            trades_list += f"{emoji} {t.get('signal_type')} {t.get('symbol')} {t.get('strike')}: ₹{t.get('pnl', 0.0):+,.0f}\n"
        
        pnl_emoji = "🟢" if stats['total_pnl'] >= 0 else "🔴"
        today_emoji = "📈" if stats['todays_pnl'] >= 0 else "📉"
        
        message = f"""
💰 <b>AI TRADING PERFORMANCE SHOWCASE ({user_email})</b> 💰
━━━━━━━━━━━━━━━━━━━━━━━━━━━

{pnl_emoji} <b>Total P&L: ₹{stats['total_pnl']:+,.0f}</b>
{today_emoji} <b>Today's P&L: ₹{stats['todays_pnl']:+,.0f}</b>

📊 <b>STATISTICS:</b>
• Total Trades: {stats['total_trades']}
• Win Rate: {stats['win_rate']}%
• Winning: {stats['winning_trades']} | Losing: {stats['losing_trades']}
• Open Positions: {stats['open_trades']}

📋 <b>RECENT TRADES:</b>
{trades_list if trades_list else "No closed trades yet"}
━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏰ {now.strftime('%H:%M:%S')} | {now.strftime('%d-%b-%Y')}

<i>*Virtual trading based on AI signals. 
Not actual trades.</i>
"""
        return message

# Global Instance
_virtual_trader = None

def get_virtual_trader() -> VirtualTrader:
    global _virtual_trader
    if _virtual_trader is None:
        _virtual_trader = VirtualTrader()
    return _virtual_trader
