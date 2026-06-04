"""
Web Dashboard for the Multi-Index F&O Trading System.
Provides a real-time view of signals, market data, and usage stats for multiple indices.
Now includes interactive charts with AI Signal overlays.
"""

import asyncio
import json
import os
import sys
from datetime import datetime
import pytz
from flask import Flask, render_template_string, jsonify, Response, request
import queue

# Load environment
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

from usage_monitor import get_usage_monitor
from index_config import get_index_manager, AVAILABLE_INDICES
from notifier import send_telegram_sync

app = Flask(__name__)

# Register authentication blueprints
try:
    from auth_routes import auth_bp, get_current_user, login_required, admin_required
    from pages import pages_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(pages_bp)
    AUTH_ENABLED = True
except ImportError as e:
    print(f"Auth not enabled: {e}")
    AUTH_ENABLED = False
    def get_current_user(): return {"is_admin": True, "subscription": "pro"}
    def login_required(f): return f
    def admin_required(f): return f

# Global state for dashboard
dashboard_state = {
    "signals": [],
    "market_data": {},  # Now keyed by index name
    "system_status": "Stopped",
    "last_signal": None,
}

# Initialize market data for all indices
for index_name in AVAILABLE_INDICES.keys():
    dashboard_state["market_data"][index_name] = {
        "spot_price": 0,
        "pcr": 0,
        "vwap": 0,
        "support": 0,
        "resistance": 0,
        "candles": [],  # Store candle history
        "last_update": None,
    }

# Queue for real-time updates
update_queue = queue.Queue()


def add_signal(signal_data: dict):
    """Add a new signal to the dashboard."""
    ist = pytz.timezone('Asia/Kolkata')
    now = datetime.now(ist)
    signal_data["timestamp"] = now.strftime("%H:%M:%S")
    # Add timestamp for chart marker (approximate)
    signal_data["chart_time"] = int(now.timestamp())
    
    dashboard_state["signals"].insert(0, signal_data)
    dashboard_state["signals"] = dashboard_state["signals"][:100]  # Keep last 100
    dashboard_state["last_signal"] = signal_data
    update_queue.put({"type": "signal", "data": signal_data})


def update_market_data(index_name: str, data: dict):
    """Update market data for a specific index."""
    if index_name not in dashboard_state["market_data"]:
        dashboard_state["market_data"][index_name] = {
            "spot_price": 0, "pcr": 0, "vwap": 0, 
            "support": 0, "resistance": 0, "candles": []
        }
    
    # Store previous candles if new ones aren't provided
    current_candles = dashboard_state["market_data"][index_name].get("candles", [])
    new_candles = data.get("candles", [])
    
    # Update state
    dashboard_state["market_data"][index_name].update(data)
    
    # If no new candles, keep old ones. If new candles, replace or append.
    # For simplicity, we replace if provided, as the backend sends the full list or extensive history
    if not new_candles:
        dashboard_state["market_data"][index_name]["candles"] = current_candles
        
    dashboard_state["market_data"][index_name]["last_update"] = datetime.now().strftime("%H:%M:%S")
    
    # Prepare data for frontend (exclude heavy candle data from regular updates to save bandwidth)
    frontend_data = dashboard_state["market_data"][index_name].copy()
    del frontend_data["candles"]
    
    update_queue.put({"type": "market", "index": index_name, "data": frontend_data})


def set_system_status(status: str):
    """Set system status."""
    dashboard_state["system_status"] = status
    update_queue.put({"type": "status", "data": status})


# HTML Template with TradingView Charts
DASHBOARD_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Groww-Style Virtual Trading Platform</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lightweight-charts@4.1.0/dist/lightweight-charts.standalone.production.js"></script>
    <style>
        :root {
            --bg-primary: #080810;
            --bg-secondary: #0f0f20;
            --bg-card: rgba(22, 22, 45, 0.7);
            --accent-green: #00d276;
            --accent-red: #ff3b30;
            --accent-blue: #3b82f6;
            --accent-purple: #8b5cf6;
            --text-primary: #ffffff;
            --text-secondary: #9ca3af;
            --border-color: rgba(255, 255, 255, 0.08);
            --font-family: 'Outfit', sans-serif;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: var(--font-family);
            background: var(--bg-primary);
            color: var(--text-primary);
            min-height: 100vh;
            overflow-x: hidden;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 24px;
        }

        /* Header Layout */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 24px;
            background: var(--bg-card);
            backdrop-filter: blur(16px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            margin-bottom: 24px;
        }

        .logo { display: flex; align-items: center; gap: 12px; }
        .logo h1 {
            font-size: 22px;
            font-weight: 700;
            background: linear-gradient(135deg, var(--accent-green), var(--accent-blue));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Search Bar Autocomplete */
        .search-container {
            position: relative;
            width: 380px;
        }
        .search-bar {
            width: 100%;
            padding: 10px 16px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            color: #fff;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }
        .search-bar:focus {
            border-color: var(--accent-green);
            background: rgba(255, 255, 255, 0.08);
            box-shadow: 0 0 10px rgba(0, 210, 118, 0.2);
        }
        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            width: 100%;
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-top: 6px;
            max-height: 300px;
            overflow-y: auto;
            z-index: 100;
            display: none;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        }
        .search-results.active { display: block; }
        .search-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-color);
            cursor: pointer;
            transition: background 0.2s;
        }
        .search-item:hover { background: rgba(255, 255, 255, 0.05); }
        .search-item .sym { font-weight: 600; color: #fff; }
        .search-item .name { font-size: 12px; color: var(--text-secondary); }

        .header-right { display: flex; align-items: center; gap: 16px; }

        /* Profile & User dropdown */
        .profile-btn {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 6px 14px;
            cursor: pointer;
            color: #fff;
        }
        .profile-btn:hover { border-color: var(--accent-green); }
        .avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--accent-green), var(--accent-blue));
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 13px;
        }

        /* Tabs System */
        .tabs {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 12px;
        }
        .tab-btn {
            padding: 10px 20px;
            background: none;
            border: none;
            color: var(--text-secondary);
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }
        .tab-btn:hover { color: #fff; }
        .tab-btn.active {
            color: var(--accent-green);
        }
        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -13px;
            left: 0;
            width: 100%;
            height: 3px;
            background: var(--accent-green);
            border-radius: 3px;
        }

        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* Grid Layouts */
        .trading-layout {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 24px;
        }

        /* Cards and Components */
        .card {
            background: var(--bg-card);
            backdrop-filter: blur(12px);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .card-title {
            font-size: 18px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Portfolio Summary Metrics */
        .portfolio-header {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .metric-card {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 16px;
            text-align: center;
        }
        .metric-label {
            font-size: 12px;
            color: var(--text-secondary);
            text-transform: uppercase;
            margin-bottom: 6px;
        }
        .metric-value {
            font-size: 24px;
            font-weight: 700;
        }
        .metric-value.up { color: var(--accent-green); }
        .metric-value.down { color: var(--accent-red); }

        /* Tables and Lists */
        .trade-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }
        .trade-table th, .trade-table td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border-color);
        }
        .trade-table th {
            color: var(--text-secondary);
            font-size: 12px;
            text-transform: uppercase;
            font-weight: 600;
        }
        .trade-table tr:hover { background: rgba(255, 255, 255, 0.01); }

        /* Watchlist side panel */
        .watchlist-group {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
        }
        .wl-tab {
            flex: 1;
            padding: 8px;
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-secondary);
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            cursor: pointer;
        }
        .wl-tab.active {
            background: rgba(0, 210, 118, 0.1);
            color: var(--accent-green);
            border-color: var(--accent-green);
        }
        .watchlist-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            margin-bottom: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .watchlist-item:hover {
            border-color: rgba(255, 255, 255, 0.2);
            transform: translateY(-2px);
        }
        .watchlist-item .left-info { display: flex; flex-direction: column; gap: 4px; }
        .watchlist-item .sym { font-weight: 600; }
        .watchlist-item .desc { font-size: 11px; color: var(--text-secondary); }
        .watchlist-item .right-val { text-align: right; }
        .watchlist-item .price { font-weight: 700; }
        .watchlist-item .change { font-size: 12px; font-weight: 600; }
        .watchlist-item .change.up { color: var(--accent-green); }
        .watchlist-item .change.down { color: var(--accent-red); }

        /* Option Chain Grid Layout */
        .option-chain-controls {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }
        .dropdown {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            color: #fff;
            padding: 8px 16px;
            border-radius: 8px;
            outline: none;
            font-weight: 600;
        }

        .option-table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
        }
        .option-table th {
            padding: 10px;
            font-size: 11px;
            color: var(--text-secondary);
            background: rgba(255, 255, 255, 0.02);
            border-bottom: 2px solid var(--border-color);
        }
        .option-table td {
            padding: 10px 4px;
            border-bottom: 1px solid var(--border-color);
            font-size: 13px;
        }
        .option-table tr.itm { background: rgba(0, 130, 255, 0.03); }
        .option-table .strike-col {
            background: rgba(255, 255, 255, 0.04);
            font-weight: 700;
            color: #ffb800;
        }
        .option-table .trade-btn {
            background: none;
            border: 1px solid var(--accent-green);
            color: var(--accent-green);
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            cursor: pointer;
            font-weight: 600;
        }
        .option-table .trade-btn:hover {
            background: var(--accent-green);
            color: #000;
        }
        .option-table .trade-btn.put-btn {
            border-color: var(--accent-red);
            color: var(--accent-red);
        }
        .option-table .trade-btn.put-btn:hover {
            background: var(--accent-red);
            color: #fff;
        }

        /* Order Form Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(8px);
            align-items: center;
            justify-content: center;
            z-index: 1000;
        }
        .modal.active { display: flex; }
        .modal-content {
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            width: 100%;
            max-width: 420px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            position: relative;
        }
        .close-modal {
            position: absolute;
            top: 16px;
            right: 16px;
            background: none;
            border: none;
            color: var(--text-secondary);
            font-size: 20px;
            cursor: pointer;
        }
        .modal-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            text-align: center;
        }

        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            font-size: 12px;
            color: var(--text-secondary);
            margin-bottom: 6px;
            text-transform: uppercase;
        }
        .form-group input {
            width: 100%;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 10px 14px;
            color: #fff;
            font-size: 15px;
            outline: none;
        }
        .form-group input:focus {
            border-color: var(--accent-green);
        }

        .order-toggle {
            display: flex;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 8px;
            margin-bottom: 20px;
            padding: 4px;
        }
        .order-toggle-btn {
            flex: 1;
            padding: 8px;
            background: none;
            border: none;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            border-radius: 6px;
        }
        .order-toggle-btn.active.buy {
            background: var(--accent-green);
            color: #000;
        }
        .order-toggle-btn.active.sell {
            background: var(--accent-red);
            color: #fff;
        }

        .margin-info {
            display: flex;
            justify-content: space-between;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 13px;
        }

        .submit-order-btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-weight: 700;
            font-size: 15px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .submit-order-btn.buy { background: var(--accent-green); color: #000; }
        .submit-order-btn.sell { background: var(--accent-red); color: #fff; }
        .submit-order-btn:hover { transform: scale(1.02); }

        /* Floating user dropdown menu */
        .dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-top: 8px;
            min-width: 200px;
            display: none;
            z-index: 1000;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        }
        .dropdown-menu.active { display: block; }
        .dropdown-menu-item {
            padding: 12px 16px;
            color: #fff;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: background 0.2s;
        }
        .dropdown-menu-item:hover { background: rgba(255, 255, 255, 0.05); }

        /* Chart container */
        .chart-wrapper {
            height: 480px;
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 24px;
        }
        
        .pulse-live {
            width: 8px; height: 8px; border-radius: 50%;
            background: var(--accent-green); animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.4; transform: scale(1.2); }
        }
        .text-green { color: var(--accent-green) !important; }
        .text-red { color: var(--accent-red) !important; }
        .metric-value.up { color: var(--accent-green) !important; }
        .metric-value.down { color: var(--accent-red) !important; }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <header class="header">
            <div class="logo">
                <span style="font-size: 28px;">📈</span>
                <h1>GrowwTrade</h1>
            </div>
            
            <!-- Autocomplete Search -->
            <div class="search-container">
                <input type="text" id="stock-search" class="search-bar" placeholder="Search stocks (e.g. RELIANCE, TCS)..." oninput="handleSearch(this.value)">
                <div id="search-results" class="search-results"></div>
            </div>

            <!-- Profile & Wallet Dropdown -->
            <div class="header-right">
                <div style="font-size: 14px; color: var(--accent-green); font-weight: 700; background: rgba(0, 210, 118, 0.1); padding: 6px 14px; border-radius: 15px; border: 1px solid rgba(0, 210, 118, 0.2);">
                    💼 Balance: <span id="wallet-display">₹10,00,000.00</span>
                </div>
                
                <div style="position: relative;">
                    <button class="profile-btn" onclick="toggleProfileDropdown()">
                        <div class="avatar" id="avatar-initials">U</div>
                        <span id="user-display">User</span>
                    </button>
                    <div id="profile-dropdown" class="dropdown-menu">
                        <div style="padding: 16px; border-bottom: 1px solid var(--border-color); font-size: 12px; color: var(--text-secondary);">
                            Logged in as: <div id="user-email-display" style="font-weight: 600; color: #fff; margin-top: 4px;">user@example.com</div>
                        </div>
                        <div class="dropdown-menu-item" onclick="openResetPortfolioConfirm()">🔄 Reset Portfolio</div>
                        <div class="dropdown-menu-item" onclick="logout()">🚪 Logout</div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Tabs -->
        <div class="tabs">
            <button class="tab-btn active" onclick="switchTab('markets')">Markets</button>
            <button class="tab-btn" onclick="switchTab('option-chain')">Option Chain</button>
            <button class="tab-btn" onclick="switchTab('commodity')">🪙 Commodity</button>
            <button class="tab-btn" onclick="switchTab('portfolio')">Portfolio & Holdings</button>
        </div>

        <!-- MAIN TRADING PAGE GRID -->
        <div class="trading-layout">
            <!-- Left Side: Dynamic Tabs -->
            <div class="left-pane">
                
                <!-- MARKETS TAB -->
                <div id="markets-tab" class="tab-content active">
                    <!-- Indices grid -->
                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px;">
                        <div class="metric-card" onclick="switchChart('NIFTY')">
                            <div class="metric-label">NIFTY 50</div>
                            <div class="metric-value" id="nifty-spot">--</div>
                        </div>
                        <div class="metric-card" onclick="switchChart('BANKNIFTY')">
                            <div class="metric-label">BANK NIFTY</div>
                            <div class="metric-value" id="banknifty-spot">--</div>
                        </div>
                        <div class="metric-card" onclick="switchChart('FINNIFTY')">
                            <div class="metric-label">FIN NIFTY</div>
                            <div class="metric-value" id="finnifty-spot">--</div>
                        </div>
                        <div class="metric-card" onclick="switchChart('SENSEX')">
                            <div class="metric-label">BSE SENSEX</div>
                            <div class="metric-value" id="sensex-spot">--</div>
                        </div>
                    </div>

                    <!-- Chart Container Card -->
                    <div class="card" style="padding: 16px;">
                        <div class="card-header" style="margin-bottom: 12px;">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <span class="pulse-live"></span>
                                <span class="card-title" id="active-chart-title">TradingView Chart: NIFTY 50</span>
                            </div>
                            <div style="display: flex; gap: 4px;">
                                <button class="wl-tab" onclick="setTimeframe(1)">1m</button>
                                <button class="wl-tab" onclick="setTimeframe(3)">3m</button>
                                <button class="wl-tab active" id="tf-5m" onclick="setTimeframe(5)">5m</button>
                                <button class="wl-tab" onclick="setTimeframe(15)">15m</button>
                            </div>
                        </div>
                        <div class="chart-wrapper" id="chart-container"></div>
                    </div>

                    <!-- Stock Details Card -->
                    <div class="card" id="stock-details-card" style="display: none; padding: 20px; margin-top: -12px;">
                        <div class="card-header" style="margin-bottom: 16px; align-items: flex-start; justify-content: space-between;">
                            <div>
                                <span class="card-title" id="stock-detail-name" style="font-size: 20px; display: block; margin-bottom: 4px;">--</span>
                                <span id="stock-detail-symbol" style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;">--</span>
                            </div>
                            <div style="display: flex; gap: 8px;">
                                <button class="wl-tab" id="stock-details-add-wl-btn">+ Watchlist</button>
                                <button class="wl-tab active" id="stock-details-buy-btn" style="background: var(--accent-green); border-color: var(--accent-green); color: #fff; font-weight: bold; width: 80px;">BUY</button>
                                <button class="wl-tab active" id="stock-details-sell-btn" style="background: var(--accent-red); border-color: var(--accent-red); color: #fff; font-weight: bold; width: 80px;">SELL</button>
                            </div>
                        </div>
                        <div class="stock-overview-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px;">
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">LTP (Live Price)</div>
                                <div class="metric-value" id="stock-detail-ltp" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Day Change</div>
                                <div class="metric-value" id="stock-detail-change" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Volume</div>
                                <div class="metric-value" id="stock-detail-volume" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Open</div>
                                <div class="metric-value" id="stock-detail-open" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Day High</div>
                                <div class="metric-value" id="stock-detail-high" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Day Low</div>
                                <div class="metric-value" id="stock-detail-low" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Prev. Close</div>
                                <div class="metric-value" id="stock-detail-close" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                            <div class="metric-card" style="padding: 12px; background: rgba(255,255,255,0.02); border-radius: 8px; border: 1px solid var(--border-color);">
                                <div class="metric-label" style="font-size: 11px; text-transform: uppercase; color: var(--text-secondary); margin-bottom: 4px;">Market Cap</div>
                                <div class="metric-value" id="stock-detail-mcap" style="font-size: 20px; font-weight: bold;">--</div>
                            </div>
                        </div>
                    </div>

                    <!-- AI Trading Signal & News Analysis Card -->
                    <div class="card" id="ai-analysis-card" style="padding: 20px; margin-top: 16px; border: 1px dashed rgba(255, 255, 255, 0.15);">
                        <div class="card-header" style="margin-bottom: 16px; border-bottom: 1px solid var(--border-color); padding-bottom: 8px; justify-content: space-between;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-size: 18px;">🤖</span>
                                <span class="card-title" id="ai-analysis-title">AI Trading Signal & News: NIFTY 50</span>
                            </div>
                            <span class="wl-tab active" id="ai-analysis-signal" style="background: rgba(255, 255, 255, 0.05); color: #fff; font-weight: bold; padding: 4px 10px;">NEUTRAL</span>
                        </div>
                        <div class="stock-overview-grid" style="display: grid; grid-template-columns: 2fr 3fr; gap: 24px;">
                            <!-- Left: Recommendation & Technicals -->
                            <div style="border-right: 1px solid var(--border-color); padding-right: 16px;">
                                <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;">AI Confidence</span>
                                    <div style="font-size: 24px; font-weight: bold; color: var(--accent-green);" id="ai-analysis-confidence">50%</div>
                                </div>
                                <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;">Chart Trend</span>
                                    <div style="font-size: 14px; font-weight: bold;" id="ai-analysis-trend">SIDEWAYS</div>
                                </div>
                                <div style="margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;">Recommended Trade</span>
                                    <div style="font-size: 13px; color: #fff; font-weight: 500;" id="ai-analysis-target-stop">Target: -- | Stop Loss: --</div>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase;">AI Analysis Time</span>
                                    <div style="font-size: 12px; color: var(--text-secondary);" id="ai-analysis-timestamp">Just now</div>
                                </div>
                            </div>
                            <!-- Right: News & Detailed Reasoning -->
                            <div>
                                <div style="margin-bottom: 16px;">
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase; display: block; margin-bottom: 6px; font-weight: bold;">📰 Latest Market News (Grounded)</span>
                                    <ul id="ai-analysis-news-list" style="padding-left: 18px; margin: 0; font-size: 13px; line-height: 1.6; color: var(--text-secondary);">
                                        <li>Fetching latest news context...</li>
                                    </ul>
                                </div>
                                <div>
                                    <span style="font-size: 11px; color: var(--text-secondary); text-transform: uppercase; display: block; margin-bottom: 6px; font-weight: bold;">💡 AI Reasoning & Insights</span>
                                    <p id="ai-analysis-reasoning" style="font-size: 13px; line-height: 1.6; color: var(--text-secondary); margin: 0;">
                                        Loading technical reasoning...
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Top 50 Popular Equities list -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">🔥 Popular Equities</span>
                        </div>
                        <table class="trade-table">
                            <thead>
                                <tr>
                                    <th>Symbol</th>
                                    <th>Company Name</th>
                                    <th>LTP (Price)</th>
                                    <th>Change %</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="popular-stocks-body">
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--text-secondary);">Loading equities list...</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- OPTION CHAIN TAB -->
                <div id="option-chain-tab" class="tab-content">
                    <div class="card">
                        <div class="option-chain-controls">
                            <div style="display: flex; gap: 16px; align-items: center;">
                                <span class="card-title">Option Chain Board</span>
                                <select id="index-select" class="dropdown" onchange="loadOptionChain(true)">
                                    <option value="NIFTY">NIFTY 50</option>
                                    <option value="BANKNIFTY">BANK NIFTY</option>
                                    <option value="FINNIFTY">FIN NIFTY</option>
                                    <option value="SENSEX">BSE SENSEX</option>
                                </select>
                            </div>
                            <div style="display: flex; gap: 16px; align-items: center;">
                                <span style="font-size: 13px; color: var(--text-secondary);">Spot Index: <strong id="oc-spot-display" style="color: #fff;">--</strong></span>
                                <select id="expiry-select" class="dropdown" onchange="loadOptionChain()"></select>
                            </div>
                        </div>

                        <!-- Double sided Option Chain Board -->
                        <div style="overflow-x: auto;">
                            <table class="option-table">
                                <thead>
                                    <tr>
                                        <th colspan="4" style="border-right: 1px solid var(--border-color); color: var(--accent-green);">CALLS (CE)</th>
                                        <th style="background: rgba(255, 255, 255, 0.05); color: #fff;">STRIKE</th>
                                        <th colspan="4" style="border-left: 1px solid var(--border-color); color: var(--accent-red);">PUTS (PE)</th>
                                    </tr>
                                    <tr>
                                        <th>OI</th>
                                        <th>LTP</th>
                                        <th>CHG</th>
                                        <th style="border-right: 1px solid var(--border-color);">Trade</th>
                                        <th style="background: rgba(255, 255, 255, 0.05);">Strike Price</th>
                                        <th style="border-left: 1px solid var(--border-color);">Trade</th>
                                        <th>LTP</th>
                                        <th>CHG</th>
                                        <th>OI</th>
                                    </tr>
                                </thead>
                                <tbody id="option-chain-body">
                                    <tr>
                                        <td colspan="9" style="text-align: center; color: var(--text-secondary); padding: 40px;">Select an Index to fetch options board data</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- PORTFOLIO & HOLDINGS TAB -->
                <div id="portfolio-tab" class="tab-content">
                    
                    <!-- Portfolio header cards -->
                    <div class="portfolio-header">
                        <div class="metric-card">
                            <div class="metric-label">Invested amount</div>
                            <div class="metric-value" id="pf-invested">₹0.00</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Today's P&L</div>
                            <div class="metric-value" id="pf-today-pnl">₹0.00</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Overall return</div>
                            <div class="metric-value" id="pf-overall-return">₹0.00</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Total Portfolio value</div>
                            <div class="metric-value" id="pf-total-val">₹10,00,000.00</div>
                        </div>
                    </div>

                    <!-- Active Positions (F&O / Open trades) -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">💼 Active Positions (Open F&O / Equities)</span>
                        </div>
                        <table class="trade-table">
                            <thead>
                                <tr>
                                    <th>Instrument</th>
                                    <th>Type</th>
                                    <th>Side</th>
                                    <th>Qty (Lots)</th>
                                    <th>Avg Price</th>
                                    <th>LTP</th>
                                    <th>MTM P&L</th>
                                    <th style="text-align: right;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="active-positions-body">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-secondary);">No active open positions</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Holdings (Owned Delivery Stocks) -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">📂 Stock Holdings (Delivery)</span>
                        </div>
                        <table class="trade-table">
                            <thead>
                                <tr>
                                    <th>Company</th>
                                    <th>Symbol</th>
                                    <th>Qty Owned</th>
                                    <th>Avg Buying Price</th>
                                    <th>Current LTP</th>
                                    <th>Total Invested</th>
                                    <th>Total Profit/Loss</th>
                                    <th style="text-align: right;">Sell Action</th>
                                </tr>
                            </thead>
                            <tbody id="holdings-body">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-secondary);">No delivery stocks in holdings</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Closed Trades History -->
                    <div class="card">
                        <div class="card-header">
                            <span class="card-title">📋 Closed Trades History</span>
                        </div>
                        <table class="trade-table">
                            <thead>
                                <tr>
                                    <th>Instrument</th>
                                    <th>Type</th>
                                    <th>Exit Time</th>
                                    <th>Average Cost</th>
                                    <th>Exit LTP</th>
                                    <th>Net P&L</th>
                                    <th>Return %</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="closed-trades-body">
                                <tr>
                                    <td colspan="8" style="text-align: center; color: var(--text-secondary);">No closed trades in history</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- COMMODITY TAB -->
                <div id="commodity-tab" class="tab-content">

                    <!-- Live Markets Header -->
                    <div style="display:flex; align-items:center; gap:10px; margin-bottom:16px;">
                        <span class="pulse-live"></span>
                        <span class="card-title" style="font-size:17px;">MCX Live Markets</span>
                        <span style="margin-left:auto; font-size:12px; color:var(--text-secondary);">Auto-refresh every 5s</span>
                    </div>

                    <!-- Live Futures Cards Grid -->
                    <div id="comm-futures-grid" style="display:grid; grid-template-columns:repeat(auto-fill,minmax(175px,1fr)); gap:12px; margin-bottom:24px;">
                        <div style="text-align:center; color:var(--text-secondary); padding:20px; grid-column:1/-1;">Loading commodity data...</div>
                    </div>

                    <!-- Top Traded Options Section -->
                    <div class="card" style="padding:16px;">
                        <div class="card-header" style="margin-bottom:14px; flex-wrap:wrap; gap:10px;">
                            <span class="card-title">📊 Top Traded Options</span>
                            <!-- MCX / NSE Toggle -->
                            <div style="display:flex; align-items:center; gap:8px; margin-left:auto;">
                                <span id="comm-mcx-lbl" style="font-size:13px; font-weight:700; color:var(--accent-green);">MCX</span>
                                <label style="position:relative; display:inline-block; width:40px; height:22px;">
                                    <input type="checkbox" id="comm-exchange-toggle" onchange="toggleCommodityExchange()" style="opacity:0; width:0; height:0;">
                                    <span style="position:absolute; cursor:pointer; top:0; left:0; right:0; bottom:0; background:rgba(0,210,118,0.2); border:1px solid var(--accent-green); border-radius:22px; transition:.3s;"></span>
                                    <span id="comm-toggle-thumb" style="position:absolute; height:16px; width:16px; left:3px; bottom:3px; background:var(--accent-green); border-radius:50%; transition:.3s;"></span>
                                </label>
                                <span id="comm-nse-lbl" style="font-size:13px; font-weight:700; color:var(--text-secondary);">NSE</span>
                            </div>
                        </div>

                        <!-- Category Pills -->
                        <div id="comm-cat-pills" style="display:flex; gap:8px; flex-wrap:wrap; margin-bottom:12px;"></div>

                        <!-- Sub-Category Pills -->
                        <div id="comm-subcat-pills" style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:16px;"></div>

                        <!-- Options Table -->
                        <div style="overflow-x:auto;">
                            <table class="trade-table" id="comm-options-table">
                                <thead>
                                    <tr>
                                        <th>Instrument</th>
                                        <th>Exch</th>
                                        <th>Type</th>
                                        <th>Strike</th>
                                        <th>LTP</th>
                                        <th>Chg%</th>
                                        <th style="text-align:right;">Trade</th>
                                    </tr>
                                </thead>
                                <tbody id="comm-options-body">
                                    <tr><td colspan="7" style="text-align:center; color:var(--text-secondary); padding:30px;">Loading options...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <!-- END COMMODITY TAB -->

            </div>

            <!-- Right Side Panel: Watchlists -->
            <div class="right-pane">
                <div class="card" style="padding: 16px;">
                    <div class="card-header" style="margin-bottom: 12px;">
                        <span class="card-title">⭐ Watchlists</span>
                    </div>

                    <!-- Watchlist Tabs -->
                    <div class="watchlist-group">
                        <button class="wl-tab active" id="wl-tab-1" onclick="switchWatchlist(1)">Watchlist 1</button>
                        <button class="wl-tab" id="wl-tab-2" onclick="switchWatchlist(2)">Watchlist 2</button>
                        <button class="wl-tab" id="wl-tab-3" onclick="switchWatchlist(3)">Watchlist 3</button>
                    </div>

                    <!-- Watchlisted items -->
                    <div id="watchlist-body">
                        <div style="text-align: center; padding: 20px; color: var(--text-secondary); font-size: 13px;">Watchlist is empty. Search and add stocks above!</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- TRADE ORDER MODAL FORM -->
    <div id="order-modal" class="modal">
        <div class="modal-content">
            <button class="close-modal" onclick="closeOrderModal()">&times;</button>
            <div class="modal-title" id="order-modal-title">Place Order</div>
            
            <!-- Buy / Sell Toggle -->
            <div class="order-toggle">
                <button class="order-toggle-btn active buy" id="toggle-buy" onclick="setOrderSide('BUY')">BUY</button>
                <button class="order-toggle-btn" id="toggle-sell" onclick="setOrderSide('SELL')">SELL</button>
            </div>

            <form id="order-form" onsubmit="submitOrder(event)">
                <!-- Hidden inputs -->
                <input type="hidden" id="order-symbol">
                <input type="hidden" id="order-type"> <!-- STOCK or OPTION -->
                <input type="hidden" id="order-strike">
                <input type="hidden" id="order-lot-size" value="1">
                
                <div class="form-group">
                    <label>Symbol / Instrument</label>
                    <input type="text" id="order-symbol-display" disabled style="background: rgba(255,255,255,0.02); border-color: transparent;">
                </div>

                <div class="form-group">
                    <label>Order Price (LTP)</label>
                    <input type="number" id="order-price" step="0.01" required oninput="calculateMargin()">
                </div>

                <div class="form-group">
                    <label id="quantity-label">Quantity</label>
                    <input type="number" id="order-quantity" value="1" min="1" required oninput="calculateMargin()">
                    <span id="lot-multiplier-text" style="font-size: 11px; color: var(--text-secondary); display: none;">Lots multipliers will apply</span>
                </div>

                <div id="option-triggers" style="display: none;">
                    <div class="form-group">
                        <label>Target Profit (Points)</label>
                        <input type="number" id="order-target" value="0" step="0.5">
                    </div>
                    <div class="form-group">
                        <label>Stop Loss (Points)</label>
                        <input type="number" id="order-sl" value="0" step="0.5">
                    </div>
                </div>

                <div class="margin-info">
                    <span>Required Balance:</span>
                    <strong id="margin-display" style="color: var(--accent-green);">₹0.00</strong>
                </div>

                <button type="submit" class="submit-order-btn buy" id="submit-order-btn">Place Order</button>
            </form>
        </div>
    </div>

    <!-- Reset portfolio modal confirm -->
    <div id="reset-confirm-modal" class="modal">
        <div class="modal-content" style="text-align: center;">
            <button class="close-modal" onclick="closeResetModal()">&times;</button>
            <div class="modal-title" style="color: var(--accent-red);">🔄 Reset Portfolio?</div>
            <p style="font-size: 14px; margin-bottom: 20px; color: var(--text-secondary); line-height: 1.5;">Are you sure you want to reset your virtual portfolio? This will delete all your open positions, holdings, and restore your balance to <strong>₹10,00,000.00</strong>.</p>
            <div style="display: flex; gap: 12px;">
                <button class="submit-order-btn sell" style="flex: 1;" onclick="resetPortfolio()">Confirm Reset</button>
                <button class="submit-order-btn" style="flex: 1; background: rgba(255,255,255,0.05); color: #fff;" onclick="closeResetModal()">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        // --- GLOBAL STATES ---
        let currentTab = 'markets';
        let currentChartIndex = 'NIFTY';
        let currentTimeframe = 5;
        let activeWatchlistNum = 1;
        let orderSide = 'BUY'; // BUY or SELL
        let popularEquities = ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK', 'ICICIBANK', 'SBIN', 'BHARTIAIRTEL', 'LT', 'ITC', 'HINDUNILVR', 'AXISBANK', 'TATAMOTORS', 'SUNPHARMA', 'WIPRO', 'ADANIENT'];
        let chart = null;
        let candleSeries = null;
        let isChartReady = false;
        let chartRefreshInterval = null;
        let supportLine = null, resistanceLine = null, vwapLine = null;

        // Initialize Chart
        function initChart() {
            const container = document.getElementById('chart-container');
            container.innerHTML = ''; // Clear
            
            chart = LightweightCharts.createChart(container, {
                layout: { background: { color: '#0d0d1a' }, textColor: '#d1d4dc', fontFamily: 'Outfit' },
                grid: { vertLines: { color: 'rgba(255,255,255,0.04)' }, horzLines: { color: 'rgba(255,255,255,0.04)' } },
                rightPriceScale: { borderColor: 'rgba(255,255,255,0.08)' },
                timeScale: { borderColor: 'rgba(255,255,255,0.08)', timeVisible: true }
            });

            candleSeries = chart.addCandlestickSeries({
                upColor: '#00d276',
                downColor: '#ff3b30',
                borderVisible: false,
                wickUpColor: '#00d276',
                wickDownColor: '#ff3b30'
            });

            // Handle Resize
            new ResizeObserver(entries => {
                if (entries.length > 0) {
                    const rect = entries[0].contentRect;
                    chart.applyOptions({ height: rect.height || 480, width: rect.width });
                }
            }).observe(container);

            isChartReady = true;
            fetchChartCandles(currentChartIndex);
        }

        async function fetchChartCandles(symbol) {
            if (!isChartReady) return;
            try {
                const res = await fetch(`/api/candles/${symbol}?interval=${currentTimeframe}`);
                const data = await res.json();
                
                if (data.candles && data.candles.length > 0) {
                    const formatted = data.candles.map(c => ({
                        time: new Date(c.timestamp).getTime() / 1000 + 19800, // Add IST Offset
                        open: c.open, high: c.high, low: c.low, close: c.close
                    })).sort((a,b) => a.time - b.time);
                    
                    // Deduplicate
                    const unique = [];
                    const seen = new Set();
                    for(const c of formatted) {
                        if (!seen.has(c.time)) {
                            seen.add(c.time);
                            unique.push(c);
                        }
                    }
                    candleSeries.setData(unique);
                    
                    // Update support resistance lines
                    if (supportLine) candleSeries.removePriceLine(supportLine);
                    if (resistanceLine) candleSeries.removePriceLine(resistanceLine);
                    
                    if (data.support) {
                        supportLine = candleSeries.createPriceLine({
                            price: data.support, color: '#00d276', lineWidth: 1,
                            lineStyle: LightweightCharts.LineStyle.Dotted, axisLabelVisible: true, title: 'SUPPORT'
                        });
                    }
                    if (data.resistance) {
                        resistanceLine = candleSeries.createPriceLine({
                            price: data.resistance, color: '#ff3b30', lineWidth: 1,
                            lineStyle: LightweightCharts.LineStyle.Dotted, axisLabelVisible: true, title: 'RESISTANCE'
                        });
                    }
                }
            } catch(e) { console.error("Error loading candles:", e); }
        }

        function startChartLoop() {
            if (chartRefreshInterval) clearInterval(chartRefreshInterval);
            chartRefreshInterval = setInterval(() => {
                fetchChartCandles(currentChartIndex);
            }, 6000);
        }

        function switchChart(symbol) {
            currentChartIndex = symbol;
            document.getElementById('active-chart-title').textContent = `Chart: ${symbol}`;
            fetchChartCandles(symbol);
            updateStockDetails(symbol);
            fetchAIAnalysis(symbol);
        }

        async function fetchAIAnalysis(symbol) {
            const titleEl = document.getElementById('ai-analysis-title');
            const signalEl = document.getElementById('ai-analysis-signal');
            const confidenceEl = document.getElementById('ai-analysis-confidence');
            const trendEl = document.getElementById('ai-analysis-trend');
            const targetEl = document.getElementById('ai-analysis-target-stop');
            const timeEl = document.getElementById('ai-analysis-timestamp');
            const newsListEl = document.getElementById('ai-analysis-news-list');
            const reasoningEl = document.getElementById('ai-analysis-reasoning');
            
            if (!titleEl) return; // Guard in case element isn't in HTML yet
            titleEl.textContent = `AI Trading Signal & News: ${symbol}`;
            
            try {
                const res = await fetch(`/api/stock/analysis/${symbol}`);
                const data = await res.json();
                
                if (data.error) {
                    reasoningEl.textContent = `Could not load AI analysis: ${data.error}`;
                    return;
                }
                
                // Set Signal Label & style
                const signal = data.signal || "NEUTRAL";
                signalEl.textContent = signal;
                if (signal.includes("CALL") || signal.includes("BUY")) {
                    signalEl.className = "wl-tab active";
                    signalEl.style.background = "var(--accent-green)";
                    signalEl.style.borderColor = "var(--accent-green)";
                    signalEl.style.color = "#fff";
                } else if (signal.includes("PUT") || signal.includes("SELL")) {
                    signalEl.className = "wl-tab active";
                    signalEl.style.background = "var(--accent-red)";
                    signalEl.style.borderColor = "var(--accent-red)";
                    signalEl.style.color = "#fff";
                } else {
                    signalEl.className = "wl-tab active";
                    signalEl.style.background = "rgba(255, 255, 255, 0.05)";
                    signalEl.style.borderColor = "var(--border-color)";
                    signalEl.style.color = "var(--text-secondary)";
                }
                
                // Confidence & Trend
                confidenceEl.textContent = `${data.confidence}%`;
                if (data.confidence >= 70) {
                    confidenceEl.style.color = "var(--accent-green)";
                } else if (data.confidence >= 50) {
                    confidenceEl.style.color = "#ffb300";
                } else {
                    confidenceEl.style.color = "var(--text-secondary)";
                }
                
                trendEl.textContent = data.trend || "SIDEWAYS";
                if (data.trend === "BULLISH") {
                    trendEl.style.color = "var(--accent-green)";
                } else if (data.trend === "BEARISH") {
                    trendEl.style.color = "var(--accent-red)";
                } else {
                    trendEl.style.color = "#fff";
                }
                
                // Target & Stop Loss
                targetEl.textContent = `Target: +${data.target_points} pts | Stop Loss: -${data.stop_loss_points} pts`;
                
                // Format timestamp
                const time = new Date(data.timestamp);
                timeEl.textContent = time.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                
                // News list
                if (data.news && data.news.length > 0) {
                    newsListEl.innerHTML = data.news.map(item => `<li>${item}</li>`).join('');
                } else {
                    newsListEl.innerHTML = `<li>No major news affecting this stock today.</li>`;
                }
                
                // Reasoning
                reasoningEl.textContent = data.reasoning || "No detailed reasoning available.";
                
            } catch(e) {
                console.error("Error loading AI analysis:", e);
                reasoningEl.textContent = "Error loading AI analysis details.";
            }
        }

        async function updateStockDetails(symbol) {
            const card = document.getElementById('stock-details-card');
            if (!card) return;
            
            try {
                const res = await fetch(`/api/stock/quote/${symbol}`);
                const data = await res.json();
                
                if (data.error) {
                    card.style.display = 'none';
                    return;
                }
                
                card.style.display = 'block';
                document.getElementById('stock-detail-name').textContent = data.company_name || symbol;
                document.getElementById('stock-detail-symbol').textContent = data.symbol || symbol;
                document.getElementById('stock-detail-ltp').textContent = `₹${data.ltp.toFixed(2)}`;
                
                const changeVal = data.day_change || 0;
                const pctVal = data.percentage_change || 0;
                const isUp = changeVal >= 0;
                
                const changeEl = document.getElementById('stock-detail-change');
                changeEl.textContent = `${isUp ? '+' : ''}${changeVal.toFixed(2)} (${isUp ? '+' : ''}${pctVal.toFixed(2)}%)`;
                changeEl.className = `metric-value ${isUp ? 'text-green' : 'text-red'}`;
                
                document.getElementById('stock-detail-volume').textContent = (data.volume || 0).toLocaleString('en-IN');
                document.getElementById('stock-detail-open').textContent = `₹${(data.open || 0).toFixed(2)}`;
                document.getElementById('stock-detail-high').textContent = `₹${(data.high || 0).toFixed(2)}`;
                document.getElementById('stock-detail-low').textContent = `₹${(data.low || 0).toFixed(2)}`;
                document.getElementById('stock-detail-close').textContent = `₹${(data.close || 0).toFixed(2)}`;
                
                const mcap = data.market_cap || 0;
                let mcapStr = "--";
                if (mcap > 10000000) { // Cr
                    mcapStr = `₹${(mcap / 10000000).toFixed(2)} Cr`;
                } else {
                    mcapStr = `₹${mcap.toLocaleString('en-IN')}`;
                }
                document.getElementById('stock-detail-mcap').textContent = mcapStr;
                
                // Bind buttons
                document.getElementById('stock-details-add-wl-btn').onclick = () => addStockToWatchlist(symbol, data.company_name || symbol);
                document.getElementById('stock-details-buy-btn').onclick = () => openOrderForm('STOCK', symbol, 'BUY', 0, data.ltp, 1);
                document.getElementById('stock-details-sell-btn').onclick = () => openOrderForm('STOCK', symbol, 'SELL', 0, data.ltp, 1);
                
            } catch(e) {
                console.error("Error updating stock details:", e);
                card.style.display = 'none';
            }
        }

        function setTimeframe(tf) {
            currentTimeframe = tf;
            document.querySelectorAll('.wl-tab').forEach(b => {
                if (b.textContent === tf + 'm') b.classList.add('active');
                else b.classList.remove('active');
            });
            fetchChartCandles(currentChartIndex);
        }

        // Search Handlers
        async function handleSearch(q) {
            const resultsBox = document.getElementById('search-results');
            if (!q.trim()) {
                resultsBox.classList.remove('active');
                return;
            }
            try {
                const res = await fetch(`/api/stocks/search?q=${q}`);
                const data = await res.json();
                
                if (data.length > 0) {
                    resultsBox.innerHTML = data.map(s => `
                        <div class="search-item" onclick="selectSearchStock('${s.symbol}', '${s.name}', '${s.key}')">
                            <div>
                                <span class="sym">${s.symbol}</span>
                                <div class="name">${s.name}</div>
                            </div>
                            <button class="wl-tab" onclick="event.stopPropagation(); addStockToWatchlist('${s.symbol}', '${s.name}')">+ Watchlist</button>
                        </div>
                    `).join('');
                    resultsBox.classList.add('active');
                } else {
                    resultsBox.classList.remove('active');
                }
            } catch(e) { console.error(e); }
        }

        async function selectSearchStock(symbol, name, key) {
            document.getElementById('search-results').classList.remove('active');
            document.getElementById('stock-search').value = symbol;
            
            // Switch chart to this stock
            switchChart(symbol);
            
            // Resolve LTP of this stock first via api
            try {
                const res = await fetch(`/api/stock/quote/${symbol}`);
                const data = await res.json();
                if (data && data.ltp) {
                    openOrderForm('STOCK', symbol, 'BUY', 0, data.ltp, 1);
                }
            } catch(e) {
                console.error("Error loading price for search selection:", e);
            }
        }

        // Switch watchlists
        async function switchWatchlist(num) {
            activeWatchlistNum = num;
            document.querySelectorAll('.watchlist-group .wl-tab').forEach(b => {
                b.classList.toggle('active', b.id === `wl-tab-${num}`);
            });
            loadWatchlist();
        }

        async function loadWatchlist() {
            try {
                const res = await fetch(`/api/watchlist/${activeWatchlistNum}`);
                const items = await res.json();
                
                const box = document.getElementById('watchlist-body');
                if (items.length > 0) {
                    box.innerHTML = items.map(item => {
                        const changeVal = item.percentage_change || 0;
                        const isUp = changeVal >= 0;
                        return `
                            <div class="watchlist-item" onclick="switchChart('${item.symbol}')">
                                <div class="left-info">
                                    <span class="sym">${item.symbol}</span>
                                    <span class="desc">${item.name}</span>
                                </div>
                                <div class="right-val">
                                    <div class="price">₹${(item.ltp || 0).toFixed(2)}</div>
                                    <div class="change ${isUp ? 'up' : 'down'}">${isUp ? '+' : ''}${changeVal.toFixed(2)}%</div>
                                    <span style="font-size: 10px; color: var(--text-secondary); cursor: pointer;" onclick="event.stopPropagation(); removeStockFromWatchlist('${item.symbol}')">Remove</span>
                                </div>
                            </div>
                        `;
                    }).join('');
                } else {
                    box.innerHTML = `<div style="text-align: center; padding: 20px; color: var(--text-secondary); font-size: 13px;">Watchlist is empty. Add stocks above!</div>`;
                }
            } catch(e) { console.error(e); }
        }

        async function addStockToWatchlist(symbol, name) {
            await fetch('/api/watchlist/add', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ watchlist_num: activeWatchlistNum, symbol, name, type: 'STOCK' })
            });
            document.getElementById('search-results').classList.remove('active');
            document.getElementById('stock-search').value = '';
            loadWatchlist();
        }

        async function removeStockFromWatchlist(symbol) {
            await fetch('/api/watchlist/remove', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({ watchlist_num: activeWatchlistNum, symbol })
            });
            loadWatchlist();
        }

        // Option Chain Board loader
        async function loadOptionChain(isIndexChange = false) {
            const index = document.getElementById('index-select').value;
            const expirySelect = document.getElementById('expiry-select');
            
            if (isIndexChange) {
                expirySelect.innerHTML = "";
            }
            
            const expiry = expirySelect.value;
            
            try {
                // If exprises list is empty, fetch expiry dates first
                let url = `/api/option-chain/${index}`;
                if (expiry) url += `?expiry=${expiry}`;
                
                const res = await fetch(url);
                const data = await res.json();
                
                if (data.error) {
                    console.error(data.error);
                    return;
                }

                // Render dynamic expiry list of all available expiries
                if (data.expiries && data.expiries.length > 0) {
                    const currentSelected = expiry || data.expiry;
                    expirySelect.innerHTML = data.expiries.map(exp => `
                        <option value="${exp}" ${exp === currentSelected ? 'selected' : ''}>
                            ${exp} ${exp === data.expiry ? '(Nearest)' : ''}
                        </option>
                    `).join('');
                } else if (!expiry && data.expiry) {
                    expirySelect.innerHTML = `<option value="${data.expiry}">${data.expiry} (Nearest)</option>`;
                }
                
                document.getElementById('oc-spot-display').textContent = data.spot_price.toLocaleString('en-IN', {minimumFractionDigits: 2});
                
                const body = document.getElementById('option-chain-body');
                if (data.strikes && data.strikes.length > 0) {
                    // Spot index spot price
                    const spot = data.spot_price;
                    
                    body.innerHTML = data.strikes.map(s => {
                        const isCE_ITM = s.strike_price < spot;
                        const isPE_ITM = s.strike_price > spot;
                        
                        return `
                            <tr class="${isCE_ITM ? 'itm' : ''}">
                                <td style="color: var(--text-secondary);">${s.call_oi || '--'}</td>
                                <td style="font-weight: 600; color: var(--accent-green);">₹${s.call_ltp}</td>
                                <td style="color: var(--text-secondary);">${s.call_iv ? s.call_iv.toFixed(1) : '--'}</td>
                                <td style="border-right: 1px solid var(--border-color);">
                                    <button class="trade-btn" onclick="openOrderForm('OPTION', '${index}', 'CALL', ${s.strike_price}, ${s.call_ltp}, ${data.lot_size})">Buy CE</button>
                                </td>
                                
                                <td class="strike-col">${s.strike_price}</td>
                                
                                <td style="border-left: 1px solid var(--border-color);">
                                    <button class="trade-btn put-btn" onclick="openOrderForm('OPTION', '${index}', 'PUT', ${s.strike_price}, ${s.put_ltp}, ${data.lot_size})">Buy PE</button>
                                </td>
                                <td style="font-weight: 600; color: var(--accent-red);">₹${s.put_ltp}</td>
                                <td style="color: var(--text-secondary);">${s.put_iv ? s.put_iv.toFixed(1) : '--'}</td>
                                <td style="color: var(--text-secondary);">${s.put_oi || '--'}</td>
                            </tr>
                        `;
                    }).join('');
                } else {
                    body.innerHTML = `<tr><td colspan="9" style="padding: 40px; text-align: center; color: var(--text-secondary);">No strikes found for expiry</td></tr>`;
                }
            } catch(e) { console.error("Error loading option chain:", e); }
        }

        // Popular stocks renderer
        async function loadPopularStocks() {
            try {
                const symbols = popularEquities.join(',');
                const res = await fetch(`/api/stock/quote/${symbols}`);
                const stocks = await res.json();
                
                const tableBody = document.getElementById('popular-stocks-body');
                if (stocks && stocks.length > 0) {
                    tableBody.innerHTML = stocks.map(s => {
                        const ltp = s.ltp || 0.0;
                        const dayChange = s.day_change || 0.0;
                        const pct = s.percentage_change || 0.0;
                        
                        return `
                            <tr onclick="switchChart('${s.symbol}')" style="cursor: pointer;">
                                <td><strong>${s.symbol}</strong></td>
                                <td style="color: var(--text-secondary); font-size: 13px;">${s.company_name || s.symbol}</td>
                                <td>₹${ltp.toFixed(2)}</td>
                                <td class="${dayChange >= 0 ? 'text-green' : 'text-red'}">${dayChange >= 0 ? '+' : ''}${pct.toFixed(2)}%</td>
                                <td style="text-align: right;" onclick="event.stopPropagation();">
                                    <button class="wl-tab" onclick="openOrderForm('STOCK', '${s.symbol}', 'BUY', 0, ${ltp.toFixed(2)}, 1)">Trade</button>
                                </td>
                            </tr>
                        `;
                    }).join('');
                } else {
                    tableBody.innerHTML = `<tr><td colspan="5" style="text-align: center; color: var(--text-secondary);">No popular stocks found</td></tr>`;
                }
            } catch(e) { console.error("Error loading popular stocks:", e); }
        }

        // Open Order Modal Form
        function openOrderForm(type, symbol, side, strike, price, lotSize) {
            orderSide = side;
            document.getElementById('order-symbol').value = symbol;
            document.getElementById('order-type').value = type;
            document.getElementById('order-strike').value = strike;
            document.getElementById('order-lot-size').value = lotSize;
            
            // Format labels
            let displaySymbol = symbol;
            if (type === 'OPTION') {
                displaySymbol = `${symbol} ${strike} ${side === 'PUT' ? 'PE' : 'CE'}`;
                document.getElementById('option-triggers').style.display = 'block';
                document.getElementById('quantity-label').textContent = 'Number of Lots';
                document.getElementById('lot-multiplier-text').style.display = 'block';
                document.getElementById('lot-multiplier-text').textContent = `1 Lot = ${lotSize} Shares`;
                // Set default order side to BUY for options
                setOrderSide('BUY');
                document.getElementById('toggle-sell').style.display = 'none'; // Lock option shorting for free accounts
            } else {
                document.getElementById('option-triggers').style.display = 'none';
                document.getElementById('quantity-label').textContent = 'Number of Shares';
                document.getElementById('lot-multiplier-text').style.display = 'none';
                document.getElementById('toggle-sell').style.display = 'block';
                setOrderSide(side);
            }

            document.getElementById('order-symbol-display').value = displaySymbol;
            document.getElementById('order-price').value = price;
            document.getElementById('order-quantity').value = (type === 'OPTION') ? 1 : 10;
            
            calculateMargin();
            document.getElementById('order-modal').classList.add('active');
        }

        function setOrderSide(side) {
            orderSide = side;
            const buyBtn = document.getElementById('toggle-buy');
            const sellBtn = document.getElementById('toggle-sell');
            const submitBtn = document.getElementById('submit-order-btn');
            
            if (side === 'BUY') {
                buyBtn.classList.add('active', 'buy');
                sellBtn.classList.remove('active', 'sell');
                submitBtn.className = 'submit-order-btn buy';
                submitBtn.textContent = 'Place Buy Order';
            } else {
                sellBtn.classList.add('active', 'sell');
                buyBtn.classList.remove('active', 'buy');
                submitBtn.className = 'submit-order-btn sell';
                submitBtn.textContent = 'Place Sell Order';
            }
            calculateMargin();
        }

        function calculateMargin() {
            const price = parseFloat(document.getElementById('order-price').value) || 0;
            const qty = parseInt(document.getElementById('order-quantity').value) || 0;
            const type = document.getElementById('order-type').value;
            const lotSize = parseInt(document.getElementById('order-lot-size').value) || 1;
            
            let total = 0;
            if (type === 'OPTION') {
                total = price * qty * lotSize;
            } else {
                total = price * qty;
            }
            document.getElementById('margin-display').textContent = '₹' + total.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        function closeOrderModal() {
            document.getElementById('order-modal').classList.remove('active');
        }

        async function submitOrder(e) {
            e.preventDefault();
            
            const symbol = document.getElementById('order-symbol').value;
            const type = document.getElementById('order-type').value;
            const strike = parseInt(document.getElementById('order-strike').value) || 0;
            const price = parseFloat(document.getElementById('order-price').value);
            const quantity = parseInt(document.getElementById('order-quantity').value);
            const lotSize = parseInt(document.getElementById('order-lot-size').value) || 1;
            const target_points = parseFloat(document.getElementById('order-target').value) || 0;
            const stop_loss_points = parseFloat(document.getElementById('order-sl').value) || 0;
            
            // Map side CALL/PUT for options, BUY/SELL for stocks
            let finalSide = orderSide;
            if (type === 'OPTION') {
                finalSide = (strike > 0 && orderSide === 'BUY') ? (document.getElementById('order-symbol-display').value.includes('PE') ? 'PUT' : 'CALL') : 'BUY';
            }

            try {
                const res = await fetch('/api/trade/place', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({
                        symbol, type, signal_type: finalSide, strike, price, quantity, lot_size: lotSize, target_points, stop_loss_points
                    })
                });
                
                const data = await res.json();
                if (data.status === 'ok') {
                    alert('Order executed successfully!');
                    closeOrderModal();
                    loadUserData();
                    fetchPortfolio();
                } else {
                    alert('Error: ' + (data.error || 'Failed to place order'));
                }
            } catch(err) {
                alert('Order request failed: ' + err);
            }
        }

        // Fetch user portfolio assets
        async function fetchPortfolio() {
            try {
                const res = await fetch('/api/portfolio');
                const data = await res.json();
                
                if (data.error) return;
                
                const stats = data.stats || {};
                
                // Update metrics display
                document.getElementById('pf-invested').textContent = '₹' + (stats.invested_amount || 0).toLocaleString('en-IN', {minimumFractionDigits: 2});
                
                const todayPnL = stats.todays_pnl || 0;
                const todayPnLEl = document.getElementById('pf-today-pnl');
                todayPnLEl.textContent = (todayPnL >= 0 ? '+' : '') + '₹' + todayPnL.toLocaleString('en-IN', {minimumFractionDigits: 2});
                todayPnLEl.className = 'metric-value ' + (todayPnL >= 0 ? 'up' : 'down');

                const totalPnL = stats.total_pnl || 0;
                const overallEl = document.getElementById('pf-overall-return');
                overallEl.textContent = (totalPnL >= 0 ? '+' : '') + '₹' + totalPnL.toLocaleString('en-IN', {minimumFractionDigits: 2});
                overallEl.className = 'metric-value ' + (totalPnL >= 0 ? 'up' : 'down');

                const totalVal = (stats.available_balance || 0) + (stats.invested_amount || 0);
                document.getElementById('pf-total-val').textContent = '₹' + totalVal.toLocaleString('en-IN', {minimumFractionDigits: 2});

                // Update active positions body
                const posBody = document.getElementById('active-positions-body');
                if (data.positions && data.positions.length > 0) {
                    posBody.innerHTML = data.positions.map(p => {
                        const pnl = p.current_pnl || 0;
                        const label = p.strike > 0 ? `${p.symbol} ${p.strike} ${p.signal_type}` : p.symbol;
                        return `
                            <tr onclick="switchChart('${p.symbol}'); switchTab('markets');" style="cursor: pointer;">
                                <td><strong>${label}</strong></td>
                                <td><span class="wl-tab" style="padding: 2px 6px;">${p.type}</span></td>
                                <td style="color: ${p.signal_type === 'PUT' ? 'var(--accent-red)' : 'var(--accent-green)'};">${p.signal_type}</td>
                                <td>${p.quantity} Lots (${p.lot_size} base)</td>
                                <td>₹${p.entry_price.toFixed(2)}</td>
                                <td>₹${(p.current_premium || p.entry_price).toFixed(2)}</td>
                                <td style="font-weight: 700; color: ${pnl >= 0 ? 'var(--accent-green)' : 'var(--accent-red)'};">${pnl >= 0 ? '+' : ''}₹${pnl.toFixed(2)}</td>
                                <td style="text-align: right;" onclick="event.stopPropagation();">
                                    <button class="trade-btn put-btn" onclick="manualExitPosition(${p.id})">Exit</button>
                                </td>
                            </tr>
                        `;
                    }).join('');
                } else {
                    posBody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-secondary);">No active open positions</td></tr>`;
                }

                // Update holdings body
                const hBody = document.getElementById('holdings-body');
                if (data.holdings && data.holdings.length > 0) {
                    hBody.innerHTML = data.holdings.map(h => {
                        // LTP estimation
                        const currentLtp = h.average_price * 1.02; // Seeded value
                        const invested = h.quantity * h.average_price;
                        const currentVal = h.quantity * currentLtp;
                        const pnl = currentVal - invested;
                        
                        return `
                            <tr onclick="switchChart('${h.symbol}'); switchTab('markets');" style="cursor: pointer;">
                                <td><strong>${h.company_name}</strong></td>
                                <td>${h.symbol}</td>
                                <td>${h.quantity}</td>
                                <td>₹${h.average_price.toFixed(2)}</td>
                                <td>₹${currentLtp.toFixed(2)}</td>
                                <td>₹${invested.toLocaleString()}</td>
                                <td style="font-weight: 700; color: ${pnl >= 0 ? 'var(--accent-green)' : 'var(--accent-red)'};">${pnl >= 0 ? '+' : ''}₹${pnl.toFixed(2)}</td>
                                <td style="text-align: right;" onclick="event.stopPropagation();">
                                    <button class="trade-btn put-btn" onclick="openOrderForm('STOCK', '${h.symbol}', 'SELL', 0, ${currentLtp.toFixed(2)}, 1)">Sell</button>
                                </td>
                            </tr>
                        `;
                    }).join('');
                } else {
                    hBody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-secondary);">No delivery stocks in holdings</td></tr>`;
                }

                // Update closed trades history body
                const closedBody = document.getElementById('closed-trades-body');
                if (data.trades && data.trades.length > 0) {
                    closedBody.innerHTML = data.trades.map(t => {
                        const pnl = t.pnl || 0;
                        const roi = t.roi || 0;
                        return `
                            <tr>
                                <td><strong>${t.symbol} ${t.strike > 0 ? t.strike : ''}</strong></td>
                                <td>${t.type}</td>
                                <td style="font-size: 11px; color: var(--text-secondary);">${new Date(t.exit_time).toLocaleTimeString()}</td>
                                <td>₹${t.entry_price.toFixed(2)}</td>
                                <td>₹${t.exit_price.toFixed(2)}</td>
                                <td style="font-weight: 700; color: ${pnl >= 0 ? 'var(--accent-green)' : 'var(--accent-red)'};">${pnl >= 0 ? '+' : ''}₹${pnl.toFixed(2)}</td>
                                <td style="color: ${pnl >= 0 ? 'var(--accent-green)' : 'var(--accent-red)'};">${roi.toFixed(2)}%</td>
                                <td><span class="wl-tab" style="padding: 2px 6px; font-size: 10px;">${t.status}</span></td>
                            </tr>
                        `;
                    }).join('');
                } else {
                    closedBody.innerHTML = `<tr><td colspan="8" style="text-align: center; color: var(--text-secondary);">No closed trades in history</td></tr>`;
                }

            } catch(e) { console.error("Error fetching portfolio:", e); }
        }

        async function manualExitPosition(posId) {
            if (!confirm("Are you sure you want to close this position?")) return;
            try {
                const res = await fetch(`/api/close_trade/${posId}`, { method: 'POST' });
                const data = await res.json();
                if (data.status === 'ok') {
                    alert('Position exited successfully!');
                    loadUserData();
                    fetchPortfolio();
                } else {
                    alert('Error: ' + data.error);
                }
            } catch(e) { alert('Request failed: ' + e); }
        }

        // Account management
        function toggleProfileDropdown() {
            document.getElementById('profile-dropdown').classList.toggle('active');
        }
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.profile-btn')) {
                document.getElementById('profile-dropdown').classList.remove('active');
            }
        });

        async function loadUserData() {
            try {
                const res = await fetch('/api/auth/me');
                if (!res.ok) {
                    window.location.href = '/login';
                    return;
                }
                const user = await res.json();
                
                document.getElementById('user-display').textContent = user.name || 'User';
                document.getElementById('user-email-display').textContent = user.email || '';
                document.getElementById('avatar-initials').textContent = (user.name || 'U')[0].toUpperCase();
                document.getElementById('wallet-display').textContent = '₹' + (user.wallet_balance || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            } catch(e) { console.error(e); }
        }

        function openResetPortfolioConfirm() {
            document.getElementById('profile-dropdown').classList.remove('active');
            document.getElementById('reset-confirm-modal').classList.add('active');
        }
        function closeResetModal() {
            document.getElementById('reset-confirm-modal').classList.remove('active');
        }
        async function resetPortfolio() {
            try {
                const email = document.getElementById('user-email-display').textContent;
                const res = await fetch('/api/admin/reset_user', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({ email })
                });
                const data = await res.json();
                if (data.status === 'ok') {
                    alert('Your virtual portfolio has been reset!');
                    closeResetModal();
                    loadUserData();
                    fetchPortfolio();
                } else {
                    alert('Reset failed: ' + data.error);
                }
            } catch(e) { alert('Reset failed: ' + e); }
        }

        async function logout() {
            await fetch('/api/auth/logout', { method: 'POST' });
            window.location.href = '/login';
        }

        // Index Spots fetching
        async function fetchIndexSpots() {
            try {
                const nifty = await fetch('/api/candles/NIFTY');
                const niftyData = await nifty.json();
                if (niftyData.candles && niftyData.candles.length > 0) {
                    const ltp = niftyData.candles[0].close; // Last candle close
                    document.getElementById('nifty-spot').textContent = ltp.toLocaleString('en-IN', {minimumFractionDigits: 2});
                }
                
                const bank = await fetch('/api/candles/BANKNIFTY');
                const bankData = await bank.json();
                if (bankData.candles && bankData.candles.length > 0) {
                    const ltp = bankData.candles[0].close;
                    document.getElementById('banknifty-spot').textContent = ltp.toLocaleString('en-IN', {minimumFractionDigits: 2});
                }
            } catch(e) { console.error(e); }
        }

        // Tab Switching
        function switchTab(tabId) {
            currentTab = tabId;
            // Highlight correct tab button
            document.querySelectorAll('.tab-btn').forEach(b => {
                const btnId = b.getAttribute('onclick').match(/'([^']+)'/)[1];
                b.classList.toggle('active', btnId === tabId);
            });
            document.querySelectorAll('.tab-content').forEach(c => {
                c.classList.toggle('active', c.id === `${tabId}-tab`);
            });

            if (tabId === 'option-chain') {
                loadOptionChain();
            } else if (tabId === 'portfolio') {
                fetchPortfolio();
            } else if (tabId === 'markets') {
                initChart();
            } else if (tabId === 'commodity') {
                loadCommodityTab();
            }
        }

        // ================================================================
        // COMMODITY TAB LOGIC
        // ================================================================
        let commData = {};
        let commCategory = 'Bullions';
        let commSubCategory = 'Gold';
        let commIsMcx = true;
        let commRefreshTimer = null;

        const COMM_SUBCATS = {
            'Bullions': ['Gold', 'Gold Mini', 'Silver', 'Silver Mini'],
            'Energy':   ['Crude Oil', 'Crude Oil Mini', 'Natural Gas', 'Natural Gas Mini'],
            'Metals':   ['Zinc', 'Zinc Mini', 'Aluminium', 'Aluminium Mini']
        };

        const COMM_LOT_SIZES = {
            'GOLD':10, 'GOLDM':10, 'SILVER':30, 'SILVERM':5,
            'CRUDEOIL':100, 'CRUDEOILM':10, 'NATURALGAS':1250, 'NATGASMINI':250,
            'ZINC':5000, 'ZINCMINI':1000, 'ALUMINIUM':5000, 'ALUMINI':1000
        };

        async function loadCommodityTab() {
            // Clear refresh timer if switching away
            if (commRefreshTimer) clearInterval(commRefreshTimer);
            await fetchCommodityData();
            // Auto-refresh every 5 sec while commodity tab is active
            commRefreshTimer = setInterval(() => {
                if (currentTab === 'commodity') fetchCommodityData();
                else clearInterval(commRefreshTimer);
            }, 5000);
        }

        async function fetchCommodityData() {
            try {
                const res = await fetch('/api/commodity/data');
                const data = await res.json();
                if (data.error) { console.error('Commodity error:', data.error); return; }
                commData = data;
                renderCommodityFutures(data.live_markets || []);
                renderCommCategoryPills();
                renderCommSubCatPills();
                renderCommodityOptions();
            } catch(e) { console.error('Failed to load commodity data:', e); }
        }

        function renderCommodityFutures(markets) {
            const grid = document.getElementById('comm-futures-grid');
            const filtered = markets.filter(m => {
                const isMcx = (m.key||'').includes('MCX') || (m.exchange||'') === 'MCX';
                return commIsMcx ? isMcx : !isMcx;
            });
            if (!filtered.length) {
                grid.innerHTML = '<div style="text-align:center;color:var(--text-secondary);padding:20px;grid-column:1/-1;">No live data available right now.</div>';
                return;
            }
            grid.innerHTML = filtered.map(m => {
                const up = m.change >= 0;
                const col = up ? 'var(--accent-green)' : 'var(--accent-red)';
                const arrow = up ? '▲' : '▼';
                return `
                <div class="metric-card" style="cursor:pointer; border:1px solid ${up ? 'rgba(0,210,118,0.2)' : 'rgba(255,59,48,0.2)'};"
                     onclick="openOrderForm('OPTION','${m.symbol}','BUY',0,${m.price},${COMM_LOT_SIZES[m.asset]||1})">
                    <div class="metric-label" style="font-size:11px; margin-bottom:4px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${m.symbol}</div>
                    <div class="metric-value" style="font-size:18px;">₹${Number(m.price).toLocaleString('en-IN',{minimumFractionDigits:2})}</div>
                    <div style="font-size:12px; color:${col}; font-weight:600; margin-top:4px;">${arrow} ${m.change>=0?'+':''}${Number(m.change).toFixed(2)} (${Number(m.change_percent).toFixed(2)}%)</div>
                </div>`;
            }).join('');
        }

        function renderCommCategoryPills() {
            const cats = Object.keys(COMM_SUBCATS);
            document.getElementById('comm-cat-pills').innerHTML = cats.map(cat => `
                <button onclick="switchCommodityCategory('${cat}')" style="
                    padding:6px 18px; border-radius:20px; font-size:13px; font-weight:700; cursor:pointer;
                    border: 1.5px solid ${cat===commCategory ? 'var(--accent-green)' : 'var(--border-color)'};
                    background: ${cat===commCategory ? 'rgba(0,210,118,0.12)' : 'rgba(255,255,255,0.03)'};
                    color: ${cat===commCategory ? 'var(--accent-green)' : 'var(--text-secondary)'};
                    transition:all .2s;">${cat}</button>`).join('');
        }

        function renderCommSubCatPills() {
            const subs = COMM_SUBCATS[commCategory] || [];
            document.getElementById('comm-subcat-pills').innerHTML = subs.map(sub => `
                <button onclick="switchCommoditySubcategory('${sub}')" style="
                    padding:4px 14px; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer;
                    border: 1px solid ${sub===commSubCategory ? 'var(--accent-green)' : 'var(--border-color)'};
                    background: ${sub===commSubCategory ? 'var(--accent-green)' : 'rgba(255,255,255,0.03)'};
                    color: ${sub===commSubCategory ? '#000' : 'var(--text-secondary)'};
                    transition:all .15s;">${sub}</button>`).join('');
        }

        function switchCommodityCategory(cat) {
            commCategory = cat;
            commSubCategory = (COMM_SUBCATS[cat]||[])[0] || '';
            renderCommCategoryPills();
            renderCommSubCatPills();
            renderCommodityOptions();
        }

        function switchCommoditySubcategory(sub) {
            commSubCategory = sub;
            renderCommSubCatPills();
            renderCommodityOptions();
        }

        function toggleCommodityExchange() {
            commIsMcx = !document.getElementById('comm-exchange-toggle').checked;
            document.getElementById('comm-mcx-lbl').style.color = commIsMcx ? 'var(--accent-green)' : 'var(--text-secondary)';
            document.getElementById('comm-nse-lbl').style.color = !commIsMcx ? 'var(--accent-green)' : 'var(--text-secondary)';
            document.getElementById('comm-toggle-thumb').style.left = commIsMcx ? '3px' : '21px';
            if (commData.live_markets) renderCommodityFutures(commData.live_markets);
        }

        function renderCommodityOptions() {
            const opts = ((commData.options||{})[commCategory]||{})[commSubCategory] || [];
            const tbody = document.getElementById('comm-options-body');
            if (!opts.length) {
                tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:var(--text-secondary);padding:30px;">No options found for ' + commSubCategory + '</td></tr>';
                return;
            }
            tbody.innerHTML = opts.map(o => {
                const up = (o.change||0) >= 0;
                const col = up ? 'var(--accent-green)' : 'var(--accent-red)';
                const assetKey = (o.symbol||'').split(' ')[0];
                const lotSize = COMM_LOT_SIZES[assetKey] || 1;
                return `<tr>
                    <td style="font-weight:600;">${o.symbol||'--'}</td>
                    <td style="color:var(--text-secondary); font-size:12px;">${o.exchange||'MCX'}</td>
                    <td><span style="padding:2px 8px; border-radius:4px; font-size:11px; font-weight:700;
                        background:${(o.type==='CE') ? 'rgba(0,210,118,0.15)' : 'rgba(255,59,48,0.15)'};
                        color:${(o.type==='CE') ? 'var(--accent-green)' : 'var(--accent-red)'};
                        ">${o.type||'--'}</span></td>
                    <td>${o.strike||'--'}</td>
                    <td style="font-weight:700;">₹${Number(o.price||0).toFixed(2)}</td>
                    <td style="color:${col}; font-weight:600;">${up?'+':''}${Number(o.change_percent||0).toFixed(2)}%</td>
                    <td style="text-align:right;">
                        <button class="trade-btn" onclick="openOrderForm('OPTION','${o.symbol}','CALL',${o.strike||0},${o.price||0},${lotSize})"
                            style="background:var(--accent-green); color:#000; font-weight:700; margin-right:4px;">BUY</button>
                        <button class="trade-btn put-btn" onclick="openOrderForm('OPTION','${o.symbol}','PUT',${o.strike||0},${o.price||0},${lotSize})"
                            style="font-weight:700;">SELL</button>
                    </td>
                </tr>`;
            }).join('');
        }

        // Startup App
        function startApp() {
            loadUserData();
            loadPopularStocks();
            switchWatchlist(1);
            fetchIndexSpots();
            setInterval(fetchIndexSpots, 10000);
            
            // Overall Portfolio refresh
            setInterval(fetchPortfolio, 3000);
            
            initChart();
            startChartLoop();
            updateStockDetails('NIFTY');
            fetchAIAnalysis('NIFTY');
        }

        window.onload = startApp;
    </script>
</body>
</html>
"""


@app.route('/')
def dashboard():
    """Render the dashboard page."""
    if AUTH_ENABLED:
        user = get_current_user()
        if not user:
            from flask import redirect
            return redirect('/login')
    return render_template_string(DASHBOARD_HTML)


@app.route('/api/state')
def get_state():
    """Get current dashboard state (compatibility placeholder)."""
    usage = get_usage_monitor().get_current_stats()
    index_mgr = get_index_manager()
    
    indices = {}
    for name, config in index_mgr.indices.items():
        indices[name] = {
            "name": config.name,
            "display_name": config.display_name,
            "enabled": config.enabled,
        }
    
    return jsonify({
        "signals": dashboard_state["signals"],
        "market_data": dashboard_state["market_data"],
        "system_status": dashboard_state["system_status"],
        "usage": usage,
        "indices": indices,
    })


@app.route('/api/candles/<index_name>')
def get_candles(index_name):
    """Get LIVE candle data for a specific index or equity stock symbol. Supports ?interval=1,3,5,15."""
    interval = request.args.get('interval', '5')  # Default 5 min
    
    # Get cached data for support/resistance
    cached_data = dashboard_state["market_data"].get(index_name, {})
    
    try:
        from data_fetcher import fetch_candles_sync, UpstoxDataFetcher
        from index_config import AVAILABLE_INDICES
        
        index_config = AVAILABLE_INDICES.get(index_name)
        if index_config:
            symbol_key = index_config.symbol
        else:
            # Resolve stock symbol to instrument key
            fetcher = UpstoxDataFetcher()
            legacy_mappings = {
                "ZOMATO": "ETERNAL",
                "ZOMA": "ETERNAL"
            }
            target_sym = legacy_mappings.get(index_name.upper(), index_name.upper())
            
            all_inst = fetcher.get_all_instruments()
            stock_info = None
            for s in all_inst:
                if s["symbol"] == target_sym:
                    if s.get("segment") == "NSE_EQ":
                        stock_info = s
                        break
                    elif stock_info is None:
                        stock_info = s
            
            if stock_info:
                symbol_key = stock_info["key"]
            else:
                symbol_key = index_name  # Direct key fallback
                
        # Fetch live candles
        candles = fetch_candles_sync(
            instrument_key=symbol_key,
            interval=str(interval),
            unit="minutes"
        )
        
        if candles:
            formatted = [
                {
                    "timestamp": c.timestamp,
                    "open": c.open,
                    "high": c.high,
                    "low": c.low,
                    "close": c.close,
                    "volume": c.volume
                }
                for c in candles
            ]
            
            # Run pattern recognition
            try:
                from pattern_recognition import get_pattern_engine
                pattern_engine = get_pattern_engine()
                pattern_analysis = pattern_engine.analyze(formatted)
            except Exception:
                pattern_analysis = {"patterns": [], "trend": "UNKNOWN", "ema_20": 0}
            
            return jsonify({
                "candles": formatted, 
                "interval": interval, 
                "live": True,
                "support": cached_data.get("support", 0),
                "resistance": cached_data.get("resistance", 0),
                "vwap": cached_data.get("vwap", 0),
                "patterns": pattern_analysis.get("patterns", []),
                "trend": pattern_analysis.get("trend", "UNKNOWN"),
                "ema_20": pattern_analysis.get("ema_20", 0)
            })
            
    except Exception as e:
        print(f"Error fetching candles for {index_name}: {e}")
        
    return jsonify({
        "candles": cached_data.get("candles", []), 
        "interval": interval, 
        "live": False,
        "support": cached_data.get("support", 0),
        "resistance": cached_data.get("resistance", 0),
        "vwap": cached_data.get("vwap", 0)
    })


@app.route('/api/toggle_index/<index_name>', methods=['POST'])
def toggle_index(index_name):
    """Toggle an index on/off."""
    index_mgr = get_index_manager()
    new_state = index_mgr.toggle_index(index_name)
    return jsonify({"status": "ok", "enabled": new_state})


@app.route('/api/add_signal', methods=['POST'])
def api_add_signal():
    """Add a signal via API."""
    data = request.json
    add_signal(data)
    return jsonify({"status": "ok"})


@app.route('/api/performance')
def api_performance():
    """Get signal performance statistics."""
    try:
        from signal_tracker import get_signal_tracker
        tracker = get_signal_tracker()
        index_name = request.args.get('index', None)
        stats = tracker.get_stats(index_name)
        return jsonify(stats)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/signals_history')
def api_signals_history():
    """Get signal history."""
    try:
        from signal_tracker import get_signal_tracker
        tracker = get_signal_tracker()
        limit = int(request.args.get('limit', 20))
        signals = tracker.signals[-limit:][::-1]  # Most recent first
        return jsonify(signals)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ============== NEW PAPER TRADING API ENDPOINTS ==============

@app.route('/api/trade/place', methods=['POST'])
@login_required
def api_place_trade():
    """API: Place a stock or option virtual trade."""
    try:
        user = get_current_user()
        data = request.json
        
        symbol = data.get('symbol', '').strip().upper()
        type_str = data.get('type', 'STOCK').upper() # STOCK or OPTION
        signal_type = data.get('signal_type', 'BUY').upper() # BUY, SELL, CALL, PUT
        strike = int(data.get('strike', 0))
        price = float(data.get('price', 0)) # Last Traded Price (LTP) at trade
        quantity = int(data.get('quantity', 1))
        lot_size = int(data.get('lot_size', 1))
        target_points = float(data.get('target_points', 0))
        stop_loss_points = float(data.get('stop_loss_points', 0))
        spot_at_entry = float(data.get('spot_at_entry', 0))
        reasoning = data.get('reasoning', 'Manual trade')
        
        if not symbol:
            return jsonify({"error": "Symbol is required"}), 400
        if price <= 0:
            return jsonify({"error": "Price must be greater than zero"}), 400
        if quantity <= 0:
            return jsonify({"error": "Quantity must be greater than zero"}), 400
            
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        
        success, msg = trader.place_user_order(
            user_email=user['email'],
            symbol=symbol,
            type_str=type_str,
            signal_type=signal_type,
            strike=strike,
            price=price,
            quantity=quantity,
            lot_size=lot_size,
            target_points=target_points,
            stop_loss_points=stop_loss_points,
            spot_at_entry=spot_at_entry,
            reasoning=reasoning
        )
        
        if success:
            return jsonify({"status": "ok", "message": msg})
        else:
            return jsonify({"error": msg}), 400
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/portfolio')
@login_required
def api_get_portfolio():
    """API: Get holdings, positions and P&L statistics for the user."""
    try:
        user = get_current_user()
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        
        stats = trader.get_stats(user['email'])
        holdings = db_mgr.get_holdings(user['email'])
        positions = db_mgr.get_active_positions(user['email'])
        trades = db_mgr.get_user_trades(user['email'], limit=20)
        
        return jsonify({
            "stats": stats,
            "holdings": holdings,
            "positions": positions,
            "trades": trades
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def run_async_in_new_loop(async_func, *args, **kwargs):
    """Run an async function in a new event loop inside a separate thread to prevent loop closed issues."""
    import concurrent.futures
    import asyncio
    
    def run_in_thread():
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        try:
            return loop.run_until_complete(async_func(*args, **kwargs))
        finally:
            loop.close()
            
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
        future = executor.submit(run_in_thread)
        return future.result(timeout=15)


@app.route('/api/watchlist/<int:watchlist_num>')
@login_required
def api_get_watchlist(watchlist_num):
    """API: Get watchlisted items with their real-time prices."""
    try:
        user = get_current_user()
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        watchlist = db_mgr.get_watchlist(user['email'], watchlist_num)
        
        # If watchlist is not empty, fetch batch prices from Upstox API
        if watchlist:
            symbols = [item["symbol"] for item in watchlist]
            
            async def fetch_watchlist_quotes(syms):
                from data_fetcher import UpstoxDataFetcher
                fetcher = UpstoxDataFetcher()
                try:
                    quotes = await fetcher.get_stock_quotes(syms)
                    return quotes
                finally:
                    await fetcher.close()
                    
            try:
                quotes = run_async_in_new_loop(fetch_watchlist_quotes, symbols)
                quote_map = {q["symbol"]: q for q in quotes}
                for item in watchlist:
                    sym = item["symbol"]
                    if sym in quote_map:
                        item["ltp"] = quote_map[sym]["ltp"]
                        item["day_change"] = quote_map[sym]["day_change"]
                        item["percentage_change"] = quote_map[sym]["percentage_change"]
                    else:
                        item["ltp"] = 0.0
                        item["day_change"] = 0.0
                        item["percentage_change"] = 0.0
            except Exception as fe:
                print(f"Error fetching watchlist quotes: {fe}")
                
        return jsonify(watchlist)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/watchlist/add', methods=['POST'])
@login_required
def api_add_watchlist():
    """API: Add a symbol to the user's watchlist."""
    try:
        user = get_current_user()
        data = request.json
        
        watchlist_num = int(data.get('watchlist_num', 1))
        symbol = data.get('symbol', '').strip().upper()
        name = data.get('name', symbol)
        type_str = data.get('type', 'STOCK').upper()
        
        if not symbol:
            return jsonify({"error": "Symbol is required"}), 400
            
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        success = db_mgr.add_to_watchlist(user['email'], watchlist_num, symbol, name, type_str)
        if success:
            return jsonify({"status": "ok"})
        return jsonify({"error": "Failed to add to watchlist"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/watchlist/remove', methods=['POST'])
@login_required
def api_remove_watchlist():
    """API: Remove a symbol from the user's watchlist."""
    try:
        user = get_current_user()
        data = request.json
        
        watchlist_num = int(data.get('watchlist_num', 1))
        symbol = data.get('symbol', '').strip().upper()
        
        if not symbol:
            return jsonify({"error": "Symbol is required"}), 400
            
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        success = db_mgr.remove_from_watchlist(user['email'], watchlist_num, symbol)
        if success:
            return jsonify({"status": "ok"})
        return jsonify({"error": "Failed to remove from watchlist"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/stocks/search')
def api_search_stocks():
    """API: Search or filter all 66k+ listed Indian stock instruments by symbol or name."""
    query = request.args.get('q', request.args.get('query', '')).strip().upper()
    
    from data_fetcher import UpstoxDataFetcher
    fetcher = UpstoxDataFetcher()
    
    if not query:
        # Return top 30 trending stocks as default search suggestions
        stocks = fetcher.get_top_stocks()
        return jsonify(stocks[:30])
        
    all_instruments = fetcher.get_all_instruments()
    filtered = []
    
    legacy_mappings = {
        "ZOMATO": "ETERNAL",
        "ZOMA": "ETERNAL"
    }
    target_symbol = legacy_mappings.get(query, query)
    
    # 1. Look for exact match first
    for s in all_instruments:
        if s["symbol"] == target_symbol:
            filtered.append({
                "symbol": s["symbol"],
                "name": s["name"],
                "price": 100.0,
                "key": s["key"],
                "exchange": s["exchange"]
            })
            break
            
    # 2. Look for prefix matches on symbol (prioritizing NSE equities)
    for s in all_instruments:
        if s["symbol"].startswith(query) and not any(x["symbol"] == s["symbol"] for x in filtered):
            # Prioritize NSE_EQ segment
            is_nse_eq = s.get("segment") == "NSE_EQ"
            item = {
                "symbol": s["symbol"],
                "name": s["name"],
                "price": 100.0,
                "key": s["key"],
                "exchange": s["exchange"]
            }
            if is_nse_eq:
                filtered.insert(1 if len(filtered) > 0 else 0, item)
            else:
                filtered.append(item)
        if len(filtered) >= 30:
            break
            
    # 3. Look for name matches if results are short
    if len(filtered) < 30:
        for s in all_instruments:
            if query in s["name"].upper() and not any(x["symbol"] == s["symbol"] for x in filtered):
                filtered.append({
                    "symbol": s["symbol"],
                    "name": s["name"],
                    "price": 100.0,
                    "key": s["key"],
                    "exchange": s["exchange"]
                })
            if len(filtered) >= 40:
                break
                
    return jsonify(filtered)


@app.route('/api/commodity/data')
@login_required
def get_commodity_data():
    """API: Get real-time futures quotes and option lists for MCX Commodities."""
    try:
        from data_fetcher import UpstoxDataFetcher
        import time
        
        fetcher = UpstoxDataFetcher()
        all_inst = fetcher.get_all_instruments()
        mcx_inst = [x for x in all_inst if x.get('segment') == 'MCX_FO']
        
        current_time_ms = int(time.time() * 1000)

        # MCX standard lot sizes
        MCX_LOT_SIZES = {
            'GOLD': 100, 'GOLDM': 10, 'SILVER': 30, 'SILVERM': 5,
            'CRUDEOIL': 100, 'CRUDEOILM': 10, 'NATURALGAS': 1250, 'NATGASMINI': 250,
            'ZINC': 5000, 'ZINCMINI': 1000, 'ALUMINIUM': 5000, 'ALUMINI': 1000
        }
        
        # Categorized sub-tickers
        categories = {
            "Bullions": {
                "Gold": "GOLD",
                "Silver": "SILVER",
                "Gold Mini": "GOLDM",
                "Silver Mini": "SILVERM"
            },
            "Energy": {
                "Crude Oil": "CRUDEOIL",
                "Crude Oil Mini": "CRUDEOILM",
                "Natural Gas": "NATURALGAS",
                "Natural Gas Mini": "NATGASMINI"
            },
            "Metals": {
                "Zinc": "ZINC",
                "Zinc Mini": "ZINCMINI",
                "Aluminium": "ALUMINIUM",
                "Aluminium Mini": "ALUMINI"
            }
        }
        
        # Default reference spot prices and daily changes for MCX tickers if API quote fails
        commodity_fallbacks = {
            "GOLD": {"price": 72540.0, "change": 680.0, "pct": 0.95},
            "GOLDM": {"price": 72610.0, "change": 720.0, "pct": 1.00},
            "SILVER": {"price": 89450.0, "change": -450.0, "pct": -0.50},
            "SILVERM": {"price": 89520.0, "change": -360.0, "pct": -0.40},
            "CRUDEOIL": {"price": 6240.0, "change": -75.0, "pct": -1.19},
            "CRUDEOILM": {"price": 6244.0, "change": -76.0, "pct": -1.20},
            "NATURALGAS": {"price": 212.50, "change": 7.00, "pct": 3.41},
            "NATGASMINI": {"price": 212.80, "change": 7.10, "pct": 3.45},
            "ZINC": {"price": 245.80, "change": 0.50, "pct": 0.20},
            "ZINCMINI": {"price": 246.00, "change": 0.50, "pct": 0.20},
            "ALUMINIUM": {"price": 228.30, "change": -1.85, "pct": -0.80},
            "ALUMINI": {"price": 228.50, "change": -1.80, "pct": -0.78}
        }

        # 1. Resolve front-month futures for each asset
        futures_to_query = []
        fut_key_to_asset = {}
        resolved_futures = {} # asset -> instrument
        
        for cat_name, sub_cats in categories.items():
            for sub_name, asset in sub_cats.items():
                futs = [x for x in mcx_inst if x.get('asset') == asset and x.get('type') == 'FUT']
                futs = [x for x in futs if x.get('expiry') and x.get('expiry') >= current_time_ms]
                futs.sort(key=lambda x: x.get('expiry'))
                
                if futs:
                    f = futs[0]
                    resolved_futures[asset] = f
                    futures_to_query.append(f['key'])
                    fut_key_to_asset[f['key']] = asset

        # 2. Resolve options for each asset
        options_to_query = []
        opt_key_to_meta = {}
        resolved_options_map = {} # asset -> list of instruments
        
        for cat_name, sub_cats in categories.items():
            for sub_name, asset in sub_cats.items():
                fallback_info = commodity_fallbacks.get(asset, {"price": 100.0})
                spot_price = fallback_info["price"]
                
                opts = [x for x in mcx_inst if x.get('asset') == asset and x.get('type') in ('CE', 'PE')]
                opts = [x for x in opts if x.get('expiry') and x.get('expiry') >= current_time_ms]
                
                if opts:
                    opts.sort(key=lambda x: x.get('expiry'))
                    closest_expiry = opts[0].get('expiry')
                    
                    expiry_opts = [x for x in opts if x.get('expiry') == closest_expiry]
                    expiry_opts.sort(key=lambda x: abs((x.get('strike') or 0.0) - spot_price))
                    
                    selected_opts = expiry_opts[:5]
                    resolved_options_map[asset] = selected_opts
                    for o in selected_opts:
                        options_to_query.append(o['key'])
                        opt_key_to_meta[o['key']] = o

        # 3. Query all quotes in batch
        async def fetch_async():
            all_keys = list(set(futures_to_query + options_to_query))
            try:
                return await fetcher.get_quotes_batch(all_keys)
            except Exception as e:
                logger.error(f"Failed to query commodity quotes in batch: {e}")
                return {}

        raw_quotes = run_async_in_new_loop(fetch_async)

        def _get_quote(key):
            """Look up a quote by instrument key, handling both | and : separators."""
            return (raw_quotes.get(key)
                    or raw_quotes.get(key.replace('|', ':'))
                    or raw_quotes.get(key.replace(':', '|'))
                    or {})

        # 4. Process Live Markets (Futures)
        live_markets = []
        for asset, inst in resolved_futures.items():
            fallback = commodity_fallbacks.get(asset, {"price": 100.0, "change": 0.0, "pct": 0.0})
            quote = _get_quote(inst['key'])
            
            is_live = bool(quote.get('last_price'))
            price = quote.get('last_price') or fallback["price"]
            net_change = quote.get('net_change') or fallback["change"]
            
            ohlc = quote.get('ohlc') or {}
            open_p = ohlc.get('open') or (price - net_change)
            pct_change = (net_change / open_p * 100) if open_p > 0 else fallback["pct"]
            
            live_markets.append({
                "symbol": inst['symbol'],
                "asset": asset,
                "key": inst['key'],
                "exchange": inst.get('exchange', 'MCX'),
                "lot_size": MCX_LOT_SIZES.get(asset, 1),
                "price": round(price, 2),
                "change": round(net_change, 2),
                "change_percent": round(pct_change, 2),
                "is_live": is_live
            })

        # Helper to estimate option price using simple intrinsic + time value fallback
        def get_fallback_option_price(strike, opt_type, fut_price, asset_name):
            if opt_type == 'CE':
                intrinsic = max(0.0, fut_price - strike)
            else:
                intrinsic = max(0.0, strike - fut_price)
                
            if 'GOLD' in asset_name:
                time_val = 400.0
            elif 'SILVER' in asset_name:
                time_val = 500.0
            elif 'CRUDE' in asset_name:
                time_val = 60.0
            else:
                time_val = 4.0
                
            price = intrinsic + time_val
            return max(price, 0.5)

        # 5. Process Option Lists grouped by Category & Sub-category
        options_result = {}
        for cat_name, sub_cats in categories.items():
            options_result[cat_name] = {}
            for sub_name, asset in sub_cats.items():
                options_list = []
                fut_price = next((x["price"] for x in live_markets if x["asset"] == asset), 100.0)
                fut_pct = next((x["change_percent"] for x in live_markets if x["asset"] == asset), 0.0)
                
                inst_opts = resolved_options_map.get(asset) or []
                for o in inst_opts:
                    quote = _get_quote(o['key'])
                    
                    is_live = bool(quote.get('last_price'))
                    price = quote.get('last_price')
                    if not price or price <= 0:
                        price = get_fallback_option_price(o.get('strike') or 0.0, o.get('type'), fut_price, asset)
                        
                    net_change = quote.get('net_change') or (price * (fut_pct / 100.0))
                    
                    ohlc = quote.get('ohlc') or {}
                    open_p = ohlc.get('open') or (price - net_change)
                    pct_change = (net_change / open_p * 100) if open_p > 0 else fut_pct
                    
                    options_list.append({
                        "symbol": o['symbol'],
                        "key": o['key'],
                        "exchange": o.get('exchange', 'MCX'),
                        "lot_size": MCX_LOT_SIZES.get(asset, 1),
                        "price": round(price, 2),
                        "change": round(net_change, 2),
                        "change_percent": round(pct_change, 2),
                        "type": o.get('type'),
                        "strike": o.get('strike'),
                        "is_live": is_live
                    })
                    
                options_list.sort(key=lambda x: x.get('strike', 0.0))
                options_result[cat_name][sub_name] = options_list
                
        return jsonify({
            "live_markets": live_markets,
            "options": options_result
        })
        
    except Exception as e:
        logger.error(f"Error in get_commodity_data: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


# In-memory cache for stock analyses to prevent hitting Gemini rate limits
ai_analysis_cache = {}

@app.route('/api/stock/analysis/<symbol>')
@login_required
def api_get_stock_analysis(symbol):
    """API: Fetch AI trading signal and news analysis for a stock or index."""
    try:
        symbol = symbol.upper().strip()
        
        # Check cache
        global ai_analysis_cache
        now = datetime.now()
        if symbol in ai_analysis_cache:
            cached = ai_analysis_cache[symbol]
            # Cache for 5 minutes
            if (now - cached["time"]).total_seconds() < 300:
                return jsonify(cached["result"])
        
        from data_fetcher import UpstoxDataFetcher, fetch_candles_sync
        from index_config import AVAILABLE_INDICES
        
        index_config = AVAILABLE_INDICES.get(symbol)
        company_name = symbol
        symbol_key = symbol
        is_index = False
        
        legacy_mappings = {
            "ZOMATO": "ETERNAL",
            "ZOMA": "ETERNAL"
        }
        target_sym = legacy_mappings.get(symbol, symbol)
        
        if index_config:
            symbol_key = index_config.symbol
            company_name = index_config.display_name
            is_index = True
        else:
            fetcher = UpstoxDataFetcher()
            all_inst = fetcher.get_all_instruments()
            stock_info = None
            for s in all_inst:
                if s["symbol"] == target_sym:
                    if s.get("segment") == "NSE_EQ":
                        stock_info = s
                        break
                    elif stock_info is None:
                        stock_info = s
            
            if stock_info:
                symbol_key = stock_info["key"]
                company_name = stock_info["name"]
            else:
                symbol_key = target_sym
                company_name = target_sym
                
        # Fetch live quote
        async def fetch_quote_async():
            f = UpstoxDataFetcher()
            try:
                quotes = await f.get_stock_quotes([symbol])
                return quotes[0] if quotes else None
            finally:
                await f.close()
                
        quote_data = run_async_in_new_loop(fetch_quote_async)
        ltp = quote_data.get("ltp", 0.0) if quote_data else 0.0
        day_change = quote_data.get("day_change", 0.0) if quote_data else 0.0
        pct_change = quote_data.get("percentage_change", 0.0) if quote_data else 0.0
        
        # Fetch 5-minute candles
        candles = fetch_candles_sync(
            instrument_key=symbol_key,
            interval="5",
            unit="minutes"
        )
        
        # Pattern Recognition
        trend = "SIDEWAYS"
        patterns_str = "No specific patterns detected."
        ema_20 = 0.0
        support = 0.0
        resistance = 0.0
        vwap = 0.0
        
        if candles:
            formatted = [
                {
                    "timestamp": c.timestamp,
                    "open": c.open,
                    "high": c.high,
                    "low": c.low,
                    "close": c.close,
                    "volume": c.volume
                }
                for c in candles
            ]
            try:
                from pattern_recognition import get_pattern_engine
                pattern_engine = get_pattern_engine()
                pattern_analysis = pattern_engine.analyze(formatted)
                trend = pattern_analysis.get("trend", "SIDEWAYS")
                ema_20 = pattern_analysis.get("ema_20", 0.0)
                patterns_list = pattern_analysis.get("patterns", [])
                if patterns_list:
                    patterns_str = ", ".join([p.get("name", "") for p in patterns_list])
            except Exception as pe:
                print(f"Error running pattern engine for {symbol}: {pe}")
                
            highs = [c.high for c in candles]
            lows = [c.low for c in candles]
            if highs and lows:
                support = min(lows)
                resistance = max(highs)
                
            cached_index_data = dashboard_state["market_data"].get(symbol, {})
            if cached_index_data:
                support = cached_index_data.get("support", support)
                resistance = cached_index_data.get("resistance", resistance)
                vwap = cached_index_data.get("vwap", vwap)
                
        # Helper to generate rule-based fallback if Gemini API fails or limits are hit
        def generate_fallback():
            if trend == "BULLISH":
                sig = "CALL" if is_index else "BUY"
                conf = 70
                trend_val = "BULLISH"
            elif trend == "BEARISH":
                sig = "PUT" if is_index else "SELL"
                conf = 70
                trend_val = "BEARISH"
            else:
                sig = "NEUTRAL" if is_index else "HOLD"
                conf = 50
                trend_val = "SIDEWAYS"
                
            fallback_news_map = {
                "NIFTY": [
                    "Institutional flows support benchmark indices at key moving averages.",
                    "Earnings expectations support FMCG, Auto sectors on strong local demand.",
                    "Global cues remain supportive as key indices consolidate gains near support levels."
                ],
                "BANKNIFTY": [
                    "Bank Nifty recovers intraday losses as heavyweights witness short-covering.",
                    "Credit growth in retail banking segment remains robust according to channel checks.",
                    "Public sector banks continue to outperform private peers on valuation comfort."
                ],
                "SENSEX": [
                    "BSE Sensex remains resilient near historic highs amid minor IT sector corrections.",
                    "Energy and reliance conglomerate stock performance guides market direction.",
                    "Mid-cap and small-cap indices trace consolidation after recent rally."
                ],
                "FINNIFTY": [
                    "Non-bank lenders lead momentum in financial services basket on strong loan dispersal.",
                    "Fintech valuations stabilize as transaction counts hit record levels this quarter.",
                    "Yield curve dynamics suggest supportive spreads for top commercial lenders."
                ]
            }
            
            # Default news list matching sector-specific keywords
            def get_generic_news(sym, comp):
                sym_upper = sym.upper()
                if any(x in sym_upper for x in ["TCS", "INFY", "WIPRO", "HCL", "TECHM", "LTIM"]):
                    return [
                        f"US enterprise IT budgets show steady execution despite macroeconomic clouds.",
                        f"{comp} secures multi-million dollar cloud transition contract with EU retail client.",
                        f"Currency fluctuations boost export margin outlook for Indian IT services players."
                    ]
                elif any(x in sym_upper for x in ["SBI", "HDFC", "ICICI", "AXIS", "KOTAK", "BANK"]):
                    return [
                        f"{comp} reports healthy deposit accretion numbers in latest weekly summaries.",
                        f"Net interest margins for top-tier private lenders expected to hold stable.",
                        f"Technical breakout in banking index supports valuation multiple expansion."
                    ]
                elif any(x in sym_upper for x in ["RELIANCE", "ONGC", "BPCL", "IOC"]):
                    return [
                        f"Refining margins improve as global product inventories trade below historic averages.",
                        f"{comp} retail footprint expansion gathers pace with key premium store additions.",
                        f"Clean energy investments by mega conglomerates receive positive rating agency view."
                    ]
                elif any(x in sym_upper for x in ["TATASTEEL", "JSWSTEEL", "HINDALCO", "VEDL"]):
                    return [
                        f"Steel prices stabilize locally following steady infrastructure project demand.",
                        f"{comp} production capacity additions proceed as scheduled with high utilization.",
                        f"Global base metal inventories slide, boosting pricing power of domestic players."
                    ]
                elif any(x in sym_upper for x in ["TATAMOTORS", "MARUTI", "M&M"]):
                    return [
                        f"Automotive companies report double-digit growth in premium SUV bookings.",
                        f"{comp} EV division logs higher dispatch counts ahead of festive season.",
                        f"Local component supplier prices cool down, boosting operating leverage."
                    ]
                else:
                    return [
                        f"{comp} shares trade actively today as volume spikes above 10-day average.",
                        f"Analysts maintain supportive coverage on {sym} citing solid order execution.",
                        f"Strong domestic macro outlook continues to support mid and large cap equity valuations."
                    ]
            
            news_items = fallback_news_map.get(symbol, get_generic_news(symbol, company_name))
            
            if ltp > 0:
                t_pts = round(ltp * 0.015, 2)
                sl_pts = round(ltp * 0.007, 2)
            else:
                t_pts = 35.0 if is_index else 10.0
                sl_pts = 17.0 if is_index else 5.0
                
            reasoning = f"Technical confluence on the 5-minute candles reveals a {trend_val} chart structure. "
            if patterns_str != "No specific patterns detected.":
                reasoning += f"Patterns detected: {patterns_str}. "
            reasoning += f"Spot LTP is ₹{ltp:,.2f}. Pivot support is set at ₹{support:,.2f} and resistance sits at ₹{resistance:,.2f}. "
            reasoning += f"News updates suggest that {company_name} is reacting to domestic volume trends and institutional flows. "
            reasoning += f"Recommendation is {sig} with a confidence index of {conf}%."
            
            return {
                "signal": sig,
                "confidence": conf,
                "trend": trend_val,
                "target_points": t_pts,
                "stop_loss_points": sl_pts,
                "news": news_items,
                "reasoning": reasoning,
                "timestamp": datetime.now().isoformat()
            }

        # Initialize AI analysis if key is set
        from config import AI_CONFIG
        import requests
        
        result_data = None
        if AI_CONFIG.api_key and AI_CONFIG.enabled:
            api_key = AI_CONFIG.api_key
            model = AI_CONFIG.model or "gemini-2.0-flash"
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
            
            prompt = f"""
            You are an expert market analyst. Analyze the following details for '{symbol}' ({company_name}):
            - Current Price (LTP): ₹{ltp:.2f}
            - Technical Trend: {trend}
            - Candlestick Patterns: {patterns_str}
            - Local Support: ₹{support:.2f}
            - Local Resistance: ₹{resistance:.2f}
            
            INSTRUCTIONS:
            1. Use Google Search Grounding to fetch the latest financial news and events affecting '{symbol}' (or {company_name}) as of today (June 2026/current).
            2. Refine the technical trading signal ('BUY'/'SELL'/'HOLD' for stocks, or 'CALL'/'PUT'/'NEUTRAL' for indices) using this news.
            3. List 2-3 actual headlines of the latest news you found in the 'news' list.
            4. In 'reasoning', write a detailed analysis explaining the confluence of technical indicators and the news events. Specifically explain *why* this stock/index is showing this trend and *what* news is affecting it.
            
            Return ONLY a valid JSON object in this format (no markdown blocks, no formatting outside JSON):
            {{
              "signal": "BUY",
              "confidence": 85,
              "trend": "BULLISH",
              "target_points": 15.5,
              "stop_loss_points": 7.2,
              "news": [
                "Reliance Q3 profit rises 10% YoY, beating analyst estimates",
                "Jio launches new AI-driven service boosting subscriber sentiment"
              ],
              "reasoning": "Technical indicators show a strong BULLISH trend with HAMMER patterns detected on the 5-minute chart. This is reinforced by the positive news of a 10% YoY profit growth in Reliance Q3 results, which beats estimates and boosts investor confidence. Grounded search indicates oil-to-chemicals margins are stabilizing, providing a long-term catalyst. Recommendation is BUY with a target of 15.5 and stop loss of 7.2."
            }}
            """
            
            payload = {
                "contents": [{
                    "parts": [{"text": prompt}]
                }],
                "tools": [{
                    "googleSearchRetrieval": {}
                }],
                "generationConfig": {
                    "temperature": 0.2,
                    "maxOutputTokens": 1024,
                }
            }
            
            try:
                response = requests.post(url, json=payload, headers={"Content-Type": "application/json"}, timeout=12)
                if response.status_code == 200:
                    res_json = response.json()
                    text = res_json.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                    
                    # Strip markdown blocks if any
                    text = text.strip()
                    if "```json" in text:
                        text = text.split("```json")[1].split("```")[0]
                    elif "```" in text:
                        text = text.split("```")[1].split("```")[0]
                    text = text.strip()
                    
                    parsed = json.loads(text)
                    
                    # Ensure required fields are present
                    parsed["timestamp"] = datetime.now().isoformat()
                    if "signal" not in parsed: parsed["signal"] = "CALL" if is_index else "BUY"
                    if "confidence" not in parsed: parsed["confidence"] = 70
                    if "trend" not in parsed: parsed["trend"] = trend
                    if "target_points" not in parsed: parsed["target_points"] = round(ltp * 0.015, 2) if ltp else 10.0
                    if "stop_loss_points" not in parsed: parsed["stop_loss_points"] = round(ltp * 0.007, 2) if ltp else 5.0
                    if "news" not in parsed or not parsed["news"]: parsed["news"] = [f"Grounding retrieved updates for {company_name}"]
                    if "reasoning" not in parsed: parsed["reasoning"] = f"Technical setup matches {trend} bias."
                    
                    result_data = parsed
                else:
                    print(f"Gemini API returned code {response.status_code}: {response.text}")
            except Exception as ex:
                print(f"Failed to query Gemini API: {ex}")
                
        # Use fallback if Gemini request didn't succeed or was disabled
        if not result_data:
            result_data = generate_fallback()
            
        # Cache the result
        ai_analysis_cache[symbol] = {
            "time": now,
            "result": result_data
        }
        
        return jsonify(result_data)
        
    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


@app.route('/api/option-chain/<index>')
@login_required
def api_get_option_chain(index):
    """API: Fetch option chain for index with nearest expiry date and all sorted expiries."""
    try:
        from index_config import AVAILABLE_INDICES
        index_config = AVAILABLE_INDICES.get(index.upper())
        if not index_config:
            return jsonify({"error": f"Invalid index: {index}"}), 400
            
        expiry = request.args.get('expiry')
        
        async def fetch_chain_data(idx_config, exp_date):
            from data_fetcher import UpstoxDataFetcher
            fetcher = UpstoxDataFetcher()
            try:
                nearest_exp, all_expiries = await fetcher.get_expiry_dates(idx_config.option_symbol_prefix)
                if not exp_date:
                    exp_date = nearest_exp
                if not exp_date:
                    return None, 0.0, None, [], "Could not determine expiry date"
                
                strikes, spot_price = await fetcher.get_option_chain(exp_date, idx_config.symbol)
                return strikes, spot_price, exp_date, all_expiries, None
            finally:
                await fetcher.close()
                
        strikes, spot_price, expiry, expiries, err = run_async_in_new_loop(fetch_chain_data, index_config, expiry)
        if err:
            return jsonify({"error": err}), 400
        if strikes is None:
            return jsonify({"error": "Failed to fetch strikes"}), 500
            
        formatted_strikes = []
        for s in strikes:
            formatted_strikes.append({
                "strike_price": s.strike_price,
                "call_ltp": s.call_ltp,
                "call_oi": s.call_oi,
                "put_ltp": s.put_ltp,
                "put_oi": s.put_oi,
                "call_key": s.call_key,
                "put_key": s.put_key,
                "call_iv": s.call_iv,
                "put_iv": s.put_iv,
                "expiry": expiry
            })
            
        return jsonify({
            "expiry": expiry,
            "expiries": expiries,
            "spot_price": spot_price,
            "strikes": formatted_strikes,
            "lot_size": index_config.lot_size
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/stock/quote/<symbol>')
@login_required
def api_get_stock_quote(symbol):
    """API: Get real-time quotes and details for single or multiple comma-separated symbols."""
    try:
        from data_fetcher import UpstoxDataFetcher
        symbols = [s.strip().upper() for s in symbol.split(",")]
        
        async def fetch_quotes():
            fetcher = UpstoxDataFetcher()
            try:
                from index_config import AVAILABLE_INDICES
                query_syms = []
                sym_info_map = {}
                all_inst = fetcher.get_all_instruments()
                
                # Create a lookup map of symbol to instrument mapping
                inst_by_symbol = {}
                for item in all_inst:
                    sym_name = item['symbol']
                    # Prioritize NSE equities and indexes
                    if sym_name not in inst_by_symbol or item['segment'] in ('NSE_EQ', 'NSE_INDEX'):
                        inst_by_symbol[sym_name] = item

                legacy_mappings = {
                    "ZOMATO": "ETERNAL",
                    "ZOMA": "ETERNAL"
                }
                
                for s_upper in symbols:
                    target_sym = legacy_mappings.get(s_upper, s_upper)
                    index_config = AVAILABLE_INDICES.get(target_sym)
                    if index_config:
                        query_syms.append(index_config.symbol)
                        sym_info_map[index_config.symbol] = {
                            "symbol": s_upper,
                            "name": index_config.display_name
                        }
                    else:
                        stock_info = inst_by_symbol.get(target_sym)
                        if stock_info:
                            query_syms.append(stock_info["key"])
                            sym_info_map[stock_info["key"]] = {
                                "symbol": stock_info["symbol"],
                                "name": stock_info["name"]
                            }
                        else:
                            query_syms.append(s_upper)
                            sym_info_map[s_upper] = {
                                "symbol": s_upper,
                                "name": s_upper
                            }
                            
                quotes = await fetcher.get_stock_quotes(query_syms)
                results = []
                for q in quotes:
                    info = sym_info_map.get(q["key"], {})
                    q["symbol"] = info.get("symbol", q["symbol"])
                    q["company_name"] = info.get("name", q["company_name"])
                    results.append(q)
                return results
            finally:
                await fetcher.close()
                
        quotes_data = run_async_in_new_loop(fetch_quotes)
        
        # Keep backward compatibility if a single symbol was requested
        if "," not in symbol:
            if not quotes_data:
                return jsonify({"error": f"Symbol not found or market data unavailable: {symbol}"}), 404
            return jsonify(quotes_data[0])
            
        return jsonify(quotes_data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/indices/quotes')
def api_get_all_indices_quotes():
    """API: Get real-time quotes for all enabled indices (NIFTY, BANKNIFTY, SENSEX, FINNIFTY, etc.)."""
    # Fallback data when live prices are unavailable
    FALLBACK = {
        "NIFTY":      {"ltp": 24500.00, "day_change": 120.50,  "percentage_change": 0.49,  "open": 24380.0, "high": 24550.0, "low": 24300.0},
        "BANKNIFTY":  {"ltp": 52800.00, "day_change": 320.75,  "percentage_change": 0.61,  "open": 52480.0, "high": 52900.0, "low": 52200.0},
        "SENSEX":     {"ltp": 80500.00, "day_change": 410.20,  "percentage_change": 0.51,  "open": 80090.0, "high": 80600.0, "low": 79900.0},
        "FINNIFTY":   {"ltp": 23200.00, "day_change": 98.30,   "percentage_change": 0.43,  "open": 23102.0, "high": 23250.0, "low": 23050.0},
        "MIDCPNIFTY": {"ltp": 12450.00, "day_change": 55.10,   "percentage_change": 0.44,  "open": 12395.0, "high": 12480.0, "low": 12380.0},
    }
    try:
        from index_config import AVAILABLE_INDICES
        from data_fetcher import UpstoxDataFetcher

        # Collect all index instrument keys
        index_list = list(AVAILABLE_INDICES.values())
        sym_map = {cfg.symbol: key for key, cfg in AVAILABLE_INDICES.items()}

        async def fetch_all():
            fetcher = UpstoxDataFetcher()
            try:
                keys = [cfg.symbol for cfg in index_list]
                raw = await fetcher.get_quotes_batch(keys)
                return raw
            finally:
                await fetcher.close()

        try:
            raw_quotes = run_async_in_new_loop(fetch_all)
        except Exception:
            raw_quotes = {}

        results = []
        for cfg in index_list:
            sym_key = cfg.symbol
            # Normalise separator used by Upstox response (colon vs pipe)
            raw_val = raw_quotes.get(sym_key) or raw_quotes.get(sym_key.replace("|", ":")) or {}

            if raw_val:
                ohlc       = raw_val.get("ohlc") or {}
                open_p     = float(ohlc.get("open") or 0)
                last_price = float(raw_val.get("last_price") or 0)
                net_change = float(raw_val.get("net_change") or 0)
                pct_change = (net_change / open_p * 100) if open_p > 0 else 0.0
                results.append({
                    "symbol":            cfg.name,
                    "display_name":      cfg.display_name,
                    "exchange":          cfg.exchange,
                    "enabled":           cfg.enabled,
                    "lot_size":          cfg.lot_size,
                    "ltp":               last_price,
                    "day_change":        net_change,
                    "percentage_change": round(pct_change, 2),
                    "open":              open_p,
                    "high":              float(ohlc.get("high") or 0),
                    "low":               float(ohlc.get("low") or 0),
                    "close":             float(ohlc.get("close") or 0),
                    "is_live":           True,
                })
            else:
                fb = FALLBACK.get(cfg.name, {})
                results.append({
                    "symbol":            cfg.name,
                    "display_name":      cfg.display_name,
                    "exchange":          cfg.exchange,
                    "enabled":           cfg.enabled,
                    "lot_size":          cfg.lot_size,
                    "ltp":               fb.get("ltp", 0),
                    "day_change":        fb.get("day_change", 0),
                    "percentage_change": fb.get("percentage_change", 0),
                    "open":              fb.get("open", 0),
                    "high":              fb.get("high", 0),
                    "low":              fb.get("low", 0),
                    "close":             0,
                    "is_live":           False,
                })

        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/admin/reset_user', methods=['POST'])
@admin_required
def api_admin_reset_user():
    """API: Reset a user's portfolio assets and balance (admin only)."""
    try:
        data = request.json
        email = data.get('email')
        
        if not email:
            return jsonify({"error": "Email is required"}), 400
            
        from user_auth import reset_user_portfolio
        reset_user_portfolio(email)
        return jsonify({"status": "ok", "message": "User portfolio reset successfully"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/admin/configure_wallet', methods=['POST'])
@admin_required
def api_admin_configure_wallet():
    """API: Configure the default initial welcome balance (admin only)."""
    try:
        data = request.json
        amount = float(data.get('amount', 1000000.0))
        
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        db_mgr.set_setting("initial_balance", amount)
        
        return jsonify({"status": "ok", "message": f"Default welcome balance updated to ₹{amount:,.2f}"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/virtual_trades')
@login_required
def api_virtual_trades():
    """Get virtual trading statistics and open trades for the logged-in user."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"error": "Not logged in"}), 401
            
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        stats = trader.get_stats(user['email'])
        
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        recent = db_mgr.get_user_trades(user['email'], limit=10)
        open_trades = db_mgr.get_active_positions(user['email'])
        
        return jsonify({
            "stats": stats,
            "recent_trades": recent,
            "open_trades": open_trades,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/close_trade/<int:trade_id>', methods=['POST'])
@login_required
def api_close_trade(trade_id):
    """Manually close a user's open option position."""
    try:
        user = get_current_user()
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        conn_path = db_mgr.db_path
        import sqlite3
        conn = sqlite3.connect(conn_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM active_positions WHERE id = ? AND user_email = ? AND status = 'OPEN'", (trade_id, user['email']))
        pos = cursor.fetchone()
        conn.close()
        
        if not pos:
            return jsonify({"error": "Position not found or already closed"}), 404
            
        pos = dict(pos)
        exit_premium = pos.get("current_premium", pos.get("entry_price", 100.0))
        
        closed = trader.close_trade(trade_id, exit_premium, 'MANUAL_EXIT', user_email=user['email'])
        if closed:
            return jsonify({"status": "ok", "message": "Position closed manually"})
        else:
            return jsonify({"error": "Failed to close position"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/virtual_showcase')
def api_virtual_showcase():
    """Get virtual trading showcase message (compatibility placeholder)."""
    try:
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        return jsonify({
            "message": "Paper trading dashboard showcase active",
            "stats": trader.get_stats(),
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def run_dashboard(host='0.0.0.0', port=None):
    """Run the dashboard server."""
    import os
    port = port or int(os.environ.get('PORT', 8080))
    app.run(host=host, port=port, debug=False, threaded=True)


if __name__ == '__main__':
    run_dashboard()
