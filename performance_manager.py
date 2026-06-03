import sqlite3
import json
import logging
from datetime import datetime
import pytz
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

import sqlite3
import json
import logging
from datetime import datetime
import pytz
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

class MarketPerformanceManager:
    """Manages SQLite storage of trades, holdings, active positions, watchlists, and settings."""
    
    def __init__(self, db_path: str = "trading_history.db"):
        self.db_path = db_path
        self._init_db()
        self.ist = pytz.timezone('Asia/Kolkata')
        
    def _init_db(self):
        """Initialize SQLite database with all paper trading tables."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # 1. Trades table (historical closed trades)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS trades (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_email TEXT,
                    trade_id INTEGER,
                    symbol TEXT,
                    type TEXT, -- STOCK, OPTION
                    signal_type TEXT, -- CALL, PUT, BUY, SELL
                    strike INTEGER,
                    entry_price REAL,
                    exit_price REAL,
                    quantity INTEGER,
                    pnl REAL,
                    roi REAL,
                    entry_time TEXT,
                    exit_time TEXT,
                    status TEXT,
                    reasoning TEXT,
                    market_context TEXT
                )
            ''')
            
            # Migration checks to add new columns to trades if it existed previously
            for col, col_type in [
                ("user_email", "TEXT"),
                ("type", "TEXT"),
                ("quantity", "INTEGER")
            ]:
                try:
                    cursor.execute(f"ALTER TABLE trades ADD COLUMN {col} {col_type}")
                except sqlite3.OperationalError:
                    pass # Column already exists
            
            # 2. Holdings table (for equity delivery/long term stocks)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS holdings (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_email TEXT,
                    symbol TEXT,
                    company_name TEXT,
                    quantity INTEGER,
                    average_price REAL,
                    created_at TEXT,
                    updated_at TEXT
                )
            ''')
            
            # 3. Active Positions table (for open trades, both stocks and options)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS active_positions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_email TEXT,
                    symbol TEXT,
                    type TEXT, -- STOCK, OPTION
                    signal_type TEXT, -- CALL, PUT, BUY, SELL
                    strike INTEGER,
                    entry_price REAL,
                    spot_at_entry REAL,
                    quantity INTEGER,
                    lot_size INTEGER,
                    target_price REAL,
                    stop_loss_price REAL,
                    entry_time TEXT,
                    status TEXT, -- OPEN
                    current_premium REAL,
                    current_pnl REAL
                )
            ''')
            
            # Migration check to add spot_at_entry if active_positions existed previously
            try:
                cursor.execute("ALTER TABLE active_positions ADD COLUMN spot_at_entry REAL")
            except sqlite3.OperationalError:
                pass # Column already exists
            
            # 4. Watchlists table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS watchlists (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_email TEXT,
                    watchlist_num INTEGER, -- 1, 2, or 3
                    symbol TEXT,
                    name TEXT,
                    type TEXT -- STOCK, INDEX
                )
            ''')
            
            # 5. Settings table (like default initial balance)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS settings (
                    key TEXT PRIMARY KEY,
                    value TEXT
                )
            ''')
            
            # 6. Daily Analysis table (AI performance learnings)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS daily_analysis (
                    date TEXT PRIMARY KEY,
                    total_trades INTEGER,
                    win_rate REAL,
                    total_pnl REAL,
                    key_learnings TEXT,
                    market_summary TEXT
                )
            ''')
            
            # Insert default settings if not exists
            cursor.execute("INSERT OR IGNORE INTO settings (key, value) VALUES ('initial_balance', '1000000.0')")
            
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error initializing database: {e}")

    # Settings Helpers
    def get_setting(self, key: str, default: Any = None) -> Any:
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT value FROM settings WHERE key = ?", (key,))
            row = cursor.fetchone()
            conn.close()
            return row[0] if row else default
        except Exception as e:
            logger.error(f"Error fetching setting {key}: {e}")
            return default

    def set_setting(self, key: str, value: Any):
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)", (key, str(value)))
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error setting {key} to {value}: {e}")

    # Watchlist Helpers
    def get_watchlist(self, user_email: str, watchlist_num: int) -> List[Dict]:
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                "SELECT * FROM watchlists WHERE user_email = ? AND watchlist_num = ?",
                (user_email, watchlist_num)
            )
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching watchlist: {e}")
            return []

    def add_to_watchlist(self, user_email: str, watchlist_num: int, symbol: str, name: str, type_str: str) -> bool:
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            # Prevent duplicates
            cursor.execute(
                "SELECT id FROM watchlists WHERE user_email = ? AND watchlist_num = ? AND symbol = ?",
                (user_email, watchlist_num, symbol)
            )
            if cursor.fetchone():
                conn.close()
                return True
            
            cursor.execute(
                "INSERT INTO watchlists (user_email, watchlist_num, symbol, name, type) VALUES (?, ?, ?, ?, ?)",
                (user_email, watchlist_num, symbol, name, type_str)
            )
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"Error adding to watchlist: {e}")
            return False

    def remove_from_watchlist(self, user_email: str, watchlist_num: int, symbol: str) -> bool:
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute(
                "DELETE FROM watchlists WHERE user_email = ? AND watchlist_num = ? AND symbol = ?",
                (user_email, watchlist_num, symbol)
            )
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"Error removing from watchlist: {e}")
            return False

    # Holdings Helpers (Stock Portfolio)
    def get_holdings(self, user_email: str) -> List[Dict]:
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM holdings WHERE user_email = ? AND quantity > 0", (user_email,))
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching holdings: {e}")
            return []

    def update_holding(self, user_email: str, symbol: str, company_name: str, qty_change: int, price: float) -> bool:
        """Add or subtract holding quantity and update average purchase price."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT id, quantity, average_price FROM holdings WHERE user_email = ? AND symbol = ?", (user_email, symbol))
            row = cursor.fetchone()
            
            now = datetime.now(self.ist).isoformat()
            
            if row:
                holding_id, current_qty, avg_price = row
                new_qty = current_qty + qty_change
                
                if new_qty < 0:
                    conn.close()
                    return False # Can't sell more than you own
                elif new_qty == 0:
                    cursor.execute("DELETE FROM holdings WHERE id = ?", (holding_id,))
                else:
                    if qty_change > 0:
                        # Re-calculate average price for buy orders
                        total_cost = (current_qty * avg_price) + (qty_change * price)
                        new_avg_price = total_cost / new_qty
                    else:
                        # Selling doesn't change average cost base of remaining shares
                        new_avg_price = avg_price
                    
                    cursor.execute(
                        "UPDATE holdings SET quantity = ?, average_price = ?, updated_at = ? WHERE id = ?",
                        (new_qty, new_avg_price, now, holding_id)
                    )
            else:
                if qty_change < 0:
                    conn.close()
                    return False # Can't sell what you don't have
                cursor.execute(
                    "INSERT INTO holdings (user_email, symbol, company_name, quantity, average_price, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    (user_email, symbol, company_name, qty_change, price, now, now)
                )
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"Error updating holding: {e}")
            return False

    # Active Positions Helpers (F&O / Short-term Trades)
    def get_active_positions(self, user_email: str) -> List[Dict]:
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM active_positions WHERE user_email = ? AND status = 'OPEN'", (user_email,))
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching active positions: {e}")
            return []

    def get_all_open_positions(self) -> List[Dict]:
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM active_positions WHERE status = 'OPEN'")
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching all open positions: {e}")
            return []

    def add_active_position(self, user_email: str, symbol: str, type_str: str, signal_type: str, strike: int, entry_price: float, spot_at_entry: float, quantity: int, lot_size: int, target_price: float = 0, stop_loss_price: float = 0) -> int:
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            now = datetime.now(self.ist).isoformat()
            cursor.execute('''
                INSERT INTO active_positions (
                    user_email, symbol, type, signal_type, strike, entry_price, spot_at_entry, quantity, lot_size,
                    target_price, stop_loss_price, entry_time, status, current_premium, current_pnl
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', ?, 0)
            ''', (user_email, symbol, type_str, signal_type, strike, entry_price, spot_at_entry, quantity, lot_size, target_price, stop_loss_price, now, entry_price))
            pos_id = cursor.lastrowid
            conn.commit()
            conn.close()
            return pos_id
        except Exception as e:
            logger.error(f"Error adding active position: {e}")
            return 0

    def update_position_price(self, position_id: int, current_premium: float, current_pnl: float, stop_loss_price: float = None):
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            if stop_loss_price is not None:
                cursor.execute(
                    "UPDATE active_positions SET current_premium = ?, current_pnl = ?, stop_loss_price = ? WHERE id = ?",
                    (current_premium, current_pnl, stop_loss_price, position_id)
                )
            else:
                cursor.execute(
                    "UPDATE active_positions SET current_premium = ?, current_pnl = ? WHERE id = ?",
                    (current_premium, current_pnl, position_id)
                )
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error updating active position price/SL: {e}")

    def close_active_position(self, position_id: int, status: str = 'CLOSED') -> bool:
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("UPDATE active_positions SET status = ? WHERE id = ?", (status, position_id))
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            logger.error(f"Error closing active position: {e}")
            return False

    # Trades Helpers (Closed historical trades)
    def log_trade(self, trade_dict: Dict[str, Any]):
        """Save a finalized trade to the database."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO trades (
                    user_email, trade_id, symbol, type, signal_type, strike, entry_price, 
                    exit_price, quantity, pnl, roi, entry_time, exit_time, 
                    status, reasoning, market_context
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                trade_dict.get('user_email', 'admin@trading.ai'),
                trade_dict.get('id'),
                trade_dict.get('index', trade_dict.get('symbol')),
                trade_dict.get('type', 'OPTION'),
                trade_dict.get('signal_type'),
                trade_dict.get('strike'),
                trade_dict.get('entry_premium', trade_dict.get('entry_price')),
                trade_dict.get('exit_premium', trade_dict.get('exit_price')),
                trade_dict.get('quantity', trade_dict.get('lot_size', 1)),
                trade_dict.get('pnl'),
                trade_dict.get('roi_percentage', trade_dict.get('roi')),
                trade_dict.get('entry_time'),
                trade_dict.get('exit_time'),
                trade_dict.get('status'),
                trade_dict.get('reasoning', ''),
                json.dumps(trade_dict.get('market_context', {}))
            ))
            
            conn.commit()
            conn.close()
            logger.info(f"✅ Trade logged to SQLite for user {trade_dict.get('user_email')}")
        except Exception as e:
            logger.error(f"Error logging trade to DB: {e}")

    def get_user_trades(self, user_email: str, limit: int = 50) -> List[Dict]:
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                "SELECT * FROM trades WHERE user_email = ? ORDER BY exit_time DESC LIMIT ?",
                (user_email, limit)
            )
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching user trades: {e}")
            return []

    def get_daily_trades(self, trade_date: str) -> List[Dict]:
        """Fetch all trades for a specific date (YYYY-MM-DD)."""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM trades WHERE entry_time LIKE ?", (f"{trade_date}%",))
            rows = cursor.fetchall()
            conn.close()
            return [dict(row) for row in rows]
        except Exception as e:
            logger.error(f"Error fetching daily trades: {e}")
            return []

    def save_daily_analysis(self, date_str: str, analysis: Dict[str, Any]):
        """Save the EOD analysis and learnings."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO daily_analysis (
                    date, total_trades, win_rate, total_pnl, key_learnings, market_summary
                ) VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                date_str,
                analysis.get('total_trades', 0),
                analysis.get('win_rate', 0.0),
                analysis.get('total_pnl', 0.0),
                analysis.get('key_learnings', ''),
                analysis.get('market_summary', '')
            ))
            
            conn.commit()
            conn.close()
        except Exception as e:
            logger.error(f"Error saving daily analysis: {e}")

    def get_recent_learnings(self, limit: int = 5) -> str:
        """Get the most recent trading lessons for AI context."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("SELECT key_learnings FROM daily_analysis ORDER BY date DESC LIMIT ?", (limit,))
            rows = cursor.fetchall()
            conn.close()
            
            if not rows:
                return "No previous learnings found. Initializing trading strategy."
            
            learnings = "\n".join([f"- {row[0]}" for row in rows if row[0]])
            return learnings
        except Exception as e:
            logger.error(f"Error fetching learnings: {e}")
            return ""

    def clear_user_portfolio(self, user_email: str):
        """Delete all active positions, holdings, and trades for a user."""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            cursor.execute("DELETE FROM active_positions WHERE user_email = ?", (user_email,))
            cursor.execute("DELETE FROM holdings WHERE user_email = ?", (user_email,))
            cursor.execute("DELETE FROM trades WHERE user_email = ?", (user_email,))
            conn.commit()
            conn.close()
            logger.info(f"Cleared virtual portfolio for {user_email}")
        except Exception as e:
            logger.error(f"Error clearing portfolio for {user_email}: {e}")

_perm_manager = None

def get_performance_manager() -> MarketPerformanceManager:
    global _perm_manager
    if _perm_manager is None:
        _perm_manager = MarketPerformanceManager()
    return _perm_manager

