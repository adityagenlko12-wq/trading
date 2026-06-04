"""
Authentication Routes for Trading AI Platform.
Handles login, signup, admin panel, and subscription pages.
"""

from flask import Blueprint, request, jsonify, redirect, make_response, Response
from functools import wraps
from user_auth import (
    get_user_manager, get_wallet_manager, get_payment_manager,
    SUBSCRIPTION_PLANS, init_admin
)

auth_bp = Blueprint('auth', __name__)

# Initialize admin on import
init_admin()


def get_current_user():
    """Get current user from cookie or Authorization Bearer header."""
    token = request.cookies.get('session_token')
    if not token:
        # Check for Bearer token from mobile app
        auth_header = request.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header[7:].strip()
        elif auth_header.startswith('bearer '):
            token = auth_header[7:].strip()
    if not token:
        return None
    return get_user_manager().get_user_from_token(token)


def login_required(f):
    """Decorator to require login."""
    @wraps(f)
    def decorated(*args, **kwargs):
        user = get_current_user()
        if not user:
            if request.headers.get('Accept', '').startswith('application/json'):
                return jsonify({"error": "Login required"}), 401
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    """Decorator to require admin access."""
    @wraps(f)
    def decorated(*args, **kwargs):
        user = get_current_user()
        if not user or not user.get('is_admin'):
            if request.headers.get('Accept', '').startswith('application/json'):
                return jsonify({"error": "Admin access required"}), 403
            return redirect('/login')
        return f(*args, **kwargs)
    return decorated


def subscription_required(min_plan='free'):
    """Decorator to require minimum subscription level."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            user = get_current_user()
            if not user:
                return redirect('/login')
            
            plan_levels = {'free': 0, 'premium': 1, 'pro': 2}
            user_level = plan_levels.get(user.get('subscription', 'free'), 0)
            required_level = plan_levels.get(min_plan, 0)
            
            if user_level < required_level:
                return redirect('/subscribe')
            return f(*args, **kwargs)
        return decorated
    return decorator


# ============== AUTH PAGES ==============

@auth_bp.route('/login')
def login_page():
    """Login page."""
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - AI Trading System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f0f1a 0%, #1a1a2e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
        }
        .login-card {
            background: rgba(30, 30, 50, 0.9);
            padding: 40px;
            border-radius: 20px;
            width: 100%;
            max-width: 400px;
            border: 1px solid rgba(139, 92, 246, 0.3);
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo h1 {
            font-size: 28px;
            background: linear-gradient(135deg, #a855f7, #6366f1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .logo p { color: rgba(255,255,255,0.6); margin-top: 8px; }
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: rgba(255,255,255,0.8);
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 14px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 10px;
            color: #fff;
            font-size: 16px;
            outline: none;
            transition: all 0.3s;
        }
        .form-group input:focus {
            border-color: #a855f7;
            box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.2);
        }
        .btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #a855f7, #6366f1);
            border: none;
            border-radius: 10px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(168, 85, 247, 0.4);
        }
        .error {
            background: rgba(255, 71, 87, 0.1);
            border: 1px solid #ff4757;
            color: #ff4757;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            display: none;
        }
        .links {
            text-align: center;
            margin-top: 20px;
            color: rgba(255,255,255,0.6);
        }
        .links a {
            color: #a855f7;
            text-decoration: none;
        }
        .links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="logo">
            <h1>🤖 AI Trading System</h1>
            <p>Login to access your dashboard</p>
        </div>
        
        <div id="error" class="error"></div>
        
        <form id="loginForm">
            <div class="form-group">
                <label>Email</label>
                <input type="email" id="email" placeholder="Enter your email" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" id="password" placeholder="Enter your password" required>
            </div>
            <button type="submit" class="btn">Login</button>
        </form>
        
        <div class="links">
            Don't have an account? <a href="/signup">Sign up</a>
        </div>
    </div>
    
    <script>
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const errorDiv = document.getElementById('error');
            errorDiv.style.display = 'none';
            
            const res = await fetch('/api/auth/login', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    email: document.getElementById('email').value,
                    password: document.getElementById('password').value,
                })
            });
            
            const data = await res.json();
            if (data.success) {
                window.location.href = '/';
            } else {
                errorDiv.textContent = data.error;
                errorDiv.style.display = 'block';
            }
        });
    </script>
</body>
</html>
'''


@auth_bp.route('/signup')
def signup_page():
    """Signup page."""
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - AI Trading System</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #0f0f1a 0%, #1a1a2e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
        }
        .signup-card {
            background: rgba(30, 30, 50, 0.9);
            padding: 40px;
            border-radius: 20px;
            width: 100%;
            max-width: 420px;
            border: 1px solid rgba(139, 92, 246, 0.3);
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        .logo { text-align: center; margin-bottom: 30px; }
        .logo h1 {
            font-size: 28px;
            background: linear-gradient(135deg, #a855f7, #6366f1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block; margin-bottom: 8px;
            color: rgba(255,255,255,0.8); font-size: 14px;
        }
        .form-group input {
            width: 100%; padding: 14px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 10px; color: #fff; font-size: 16px;
            outline: none; transition: all 0.3s;
        }
        .form-group input:focus {
            border-color: #a855f7;
            box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.2);
        }
        .btn {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, #a855f7, #6366f1);
            border: none; border-radius: 10px; color: #fff;
            font-size: 16px; font-weight: 600; cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(168, 85, 247, 0.4);
        }
        .error, .success {
            padding: 12px; border-radius: 8px;
            margin-bottom: 20px; font-size: 14px; display: none;
        }
        .error { background: rgba(255, 71, 87, 0.1); border: 1px solid #ff4757; color: #ff4757; }
        .success { background: rgba(0, 210, 106, 0.1); border: 1px solid #00d26a; color: #00d26a; }
        .links { text-align: center; margin-top: 20px; color: rgba(255,255,255,0.6); }
        .links a { color: #a855f7; text-decoration: none; }
    </style>
</head>
<body>
    <div class="signup-card">
        <div class="logo">
            <h1>🤖 AI Trading System</h1>
            <p>Create your account</p>
        </div>
        
        <div id="error" class="error"></div>
        <div id="success" class="success"></div>
        
        <form id="signupForm">
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" id="name" placeholder="Enter your full name" required>
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" id="email" placeholder="Enter your email" required>
            </div>
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" id="phone" placeholder="Enter phone number" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" id="password" placeholder="Create a password" required minlength="6">
            </div>
            <button type="submit" class="btn">Create Account</button>
        </form>
        
        <div class="links">
            Already have an account? <a href="/login">Login</a>
        </div>
    </div>
    
    <script>
        document.getElementById('signupForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const errorDiv = document.getElementById('error');
            const successDiv = document.getElementById('success');
            errorDiv.style.display = 'none';
            successDiv.style.display = 'none';
            
            const res = await fetch('/api/auth/signup', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    name: document.getElementById('name').value,
                    email: document.getElementById('email').value,
                    phone: document.getElementById('phone').value,
                    password: document.getElementById('password').value,
                })
            });
            
            const data = await res.json();
            if (data.success) {
                successDiv.textContent = 'Account created! Please wait for admin approval.';
                successDiv.style.display = 'block';
                document.getElementById('signupForm').reset();
            } else {
                errorDiv.textContent = data.error;
                errorDiv.style.display = 'block';
            }
        });
    </script>
</body>
</html>
'''


# ============== AUTH API ==============

@auth_bp.route('/api/auth/signup', methods=['POST'])
def api_signup():
    """API: Create new user account."""
    data = request.json
    user_mgr = get_user_manager()
    
    result = user_mgr.create_user(
        email=data.get('email', ''),
        password=data.get('password', ''),
        name=data.get('name', ''),
        phone=data.get('phone', ''),
    )
    
    return jsonify(result)


@auth_bp.route('/api/auth/login', methods=['POST'])
def api_login():
    """API: Login user."""
    data = request.json
    user_mgr = get_user_manager()
    
    result = user_mgr.login(
        email=data.get('email', ''),
        password=data.get('password', ''),
    )
    
    if result['success']:
        resp = make_response(jsonify(result))
        resp.set_cookie('session_token', result['token'], httponly=True, samesite='Lax', max_age=7*24*60*60)
        return resp
    
    return jsonify(result)


@auth_bp.route('/api/auth/logout', methods=['POST'])
def api_logout():
    """API: Logout user."""
    token = request.cookies.get('session_token')
    if token:
        get_user_manager().logout(token)
    
    resp = make_response(jsonify({"success": True}))
    resp.delete_cookie('session_token')
    return resp


@auth_bp.route('/api/auth/me')
def api_me():
    """API: Get current user."""
    user = get_current_user()
    if not user:
        return jsonify({"error": "Not logged in"}), 401
    
    # Add wallet balance
    wallet = get_wallet_manager()
    user_data = {k: v for k, v in user.items() if k != 'password'}
    user_data['wallet_balance'] = wallet.get_balance(user['email'])
    
    return jsonify(user_data)


# ============== SUBSCRIPTION API ==============

@auth_bp.route('/api/subscription/plans')
def api_plans():
    """Get available subscription plans."""
    return jsonify(SUBSCRIPTION_PLANS)


@auth_bp.route('/api/wallet/balance')
@login_required
def api_wallet_balance():
    """Get user wallet balance."""
    user = get_current_user()
    wallet = get_wallet_manager()
    
    return jsonify({
        "balance": wallet.get_balance(user['email']),
        "transactions": wallet.get_transactions(user['email']),
    })


@auth_bp.route('/api/payment/create', methods=['POST'])
@login_required
def api_create_payment():
    """Create a payment request."""
    user = get_current_user()
    data = request.json
    
    payment_mgr = get_payment_manager()
    payment = payment_mgr.create_payment_request(
        email=user['email'],
        amount=float(data.get('amount', 0)),
        name=data.get('name', user['name']),
        phone=data.get('phone', user.get('phone', '')),
    )
    
    upi_link = payment_mgr.get_upi_link(payment['amount'], payment['id'])
    
    return jsonify({
        "payment": payment,
        "upi_link": upi_link,
        "upi_id": payment_mgr.upi_id,
        "upi_name": payment_mgr.upi_name,
    })


@auth_bp.route('/api/subscription/purchase', methods=['POST'])
@login_required
def api_purchase_subscription():
    """Purchase subscription using wallet balance."""
    user = get_current_user()
    data = request.json
    plan = data.get('plan', 'premium')
    
    if plan not in SUBSCRIPTION_PLANS:
        return jsonify({"error": "Invalid plan"}), 400
    
    price = SUBSCRIPTION_PLANS[plan]['price']
    wallet = get_wallet_manager()
    
    if wallet.get_balance(user['email']) < price:
        return jsonify({"error": "Insufficient wallet balance"}), 400
    
    # Deduct from wallet
    wallet.deduct_balance(user['email'], price, f"Subscription: {plan}")
    
    # Activate subscription
    user_mgr = get_user_manager()
    user_mgr.update_subscription(user['email'], plan)
    
    return jsonify({"success": True, "plan": plan})


# ============== ADMIN API ==============

@auth_bp.route('/api/admin/users')
@admin_required
def api_admin_users():
    """Get all users (admin only)."""
    user_mgr = get_user_manager()
    wallet_mgr = get_wallet_manager()
    
    users = user_mgr.get_all_users()
    for user in users:
        user['wallet_balance'] = wallet_mgr.get_balance(user['email'])
    
    return jsonify(users)


@auth_bp.route('/api/admin/approve/<email>', methods=['POST'])
@admin_required
def api_admin_approve(email):
    """Approve a user (admin only)."""
    user_mgr = get_user_manager()
    if user_mgr.approve_user(email):
        return jsonify({"success": True})
    return jsonify({"error": "User not found"}), 404


@auth_bp.route('/api/admin/pending_payments')
@admin_required
def api_admin_pending_payments():
    """Get pending payments (admin only)."""
    payment_mgr = get_payment_manager()
    return jsonify(payment_mgr.get_pending_payments())


@auth_bp.route('/api/admin/approve_payment/<payment_id>', methods=['POST'])
@admin_required
def api_admin_approve_payment(payment_id):
    """Approve a payment (admin only)."""
    user = get_current_user()
    payment_mgr = get_payment_manager()
    
    if payment_mgr.approve_payment(payment_id, user['email']):
        return jsonify({"success": True})
    return jsonify({"error": "Payment not found or already processed"}), 404


@auth_bp.route('/api/admin/assign_subscription', methods=['POST'])
@admin_required
def api_admin_assign_subscription():
    """Manually assign subscription to user (admin only)."""
    data = request.json
    email = data.get('email')
    plan = data.get('plan', 'premium')
    days = data.get('days', 30)
    
    user_mgr = get_user_manager()
    if user_mgr.update_subscription(email, plan, days):
        return jsonify({"success": True})
    return jsonify({"error": "User not found"}), 404


@auth_bp.route('/api/admin/add_wallet_balance', methods=['POST'])
@admin_required
def api_admin_add_balance():
    """Manually add wallet balance (admin only)."""
    data = request.json
    email = data.get('email')
    amount = float(data.get('amount', 0))
    
    wallet_mgr = get_wallet_manager()
    wallet_mgr.add_balance(email, amount, "Admin manual credit")
    
    return jsonify({"success": True, "new_balance": wallet_mgr.get_balance(email)})


@auth_bp.route('/api/admin/settings')
@admin_required
def api_admin_get_settings():
    """Get admin settings (admin only)."""
    payment_mgr = get_payment_manager()
    return jsonify(payment_mgr.get_settings())


@auth_bp.route('/api/admin/settings', methods=['POST'])
@admin_required
def api_admin_update_settings():
    """Update admin settings (admin only)."""
    data = request.json
    payment_mgr = get_payment_manager()
    
    upi_id = data.get('upi_id', payment_mgr.upi_id)
    upi_name = data.get('upi_name', payment_mgr.upi_name)
    
    payment_mgr.update_upi_settings(upi_id, upi_name)
    
    return jsonify({"success": True, "settings": payment_mgr.get_settings()})


@auth_bp.route('/api/login', methods=['POST'])
def api_mobile_login():
    """API endpoint for mobile login (Laravel compat mode)"""
    if request.is_json:
        data = request.json
    else:
        data = request.values
        
    username = data.get('username') or data.get('email', '')
    password = data.get('password', '')
    
    user_mgr = get_user_manager()
    result = user_mgr.login(email=username, password=password)
    
    if result['success']:
        user = result['user']
        token = result['token']
        
        # Build the exact JSON response expected by the mobile app's LoginResponseModel
        response_data = {
            "status": "success",
            "remark": "login_success",
            "message": {
                "success": ["Login successful"]
            },
            "data": {
                "user": {
                    "id": 1, # Mock unique ID
                    "username": user.get('name', 'User'),
                    "email": user.get('email', ''),
                    "mobile": user.get('phone', '1234567890'),
                    "ev": "1", # email verified
                    "sv": "1", # sms verified
                    "tv": "1", # 2FA verified
                    "profile_complete": "1",
                    "profileComplete": "1"
                },
                "access_token": token,
                "token_type": "Bearer"
            }
        }
        
        resp = make_response(jsonify(response_data))
        resp.set_cookie('session_token', token, httponly=True, samesite='Lax', max_age=7*24*60*60)
        return resp
        
    else:
        # Build the error response expected by the mobile app
        error_msg = result.get('error', 'Invalid credentials')
        response_data = {
            "status": "error",
            "remark": "auth_error",
            "message": {
                "error": [error_msg]
            }
        }
        return jsonify(response_data), 400


@auth_bp.route('/api/register', methods=['POST'])
def api_mobile_register():
    """API endpoint for mobile registration (Laravel compat mode)"""
    if request.is_json:
        data = request.json
    else:
        data = request.values
        
    firstname = data.get('firstname', '')
    lastname = data.get('lastname', '')
    email = data.get('email', '')
    password = data.get('password', '')
    phone = data.get('phone', '1234567890')
    
    name = f"{firstname} {lastname}".strip()
    if not name:
        name = email.split('@')[0]
        
    user_mgr = get_user_manager()
    result = user_mgr.create_user(
        email=email,
        password=password,
        name=name,
        phone=phone
    )
    
    if result['success']:
        # Auto-login after successful registration
        login_result = user_mgr.login(email=email, password=password)
        if login_result['success']:
            user = login_result['user']
            token = login_result['token']
            
            response_data = {
                "status": "success",
                "remark": "registration_success",
                "message": {
                    "success": ["Registration successful"]
                },
                "data": {
                    "user": {
                        "id": 1,
                        "username": user.get('name', name),
                        "email": user.get('email', email),
                        "mobile": user.get('phone', phone),
                        "ev": "1",
                        "sv": "1",
                        "tv": "1",
                        "profileComplete": "1"
                    },
                    "access_token": token,
                    "token_type": "Bearer"
                }
            }
            
            resp = make_response(jsonify(response_data))
            resp.set_cookie('session_token', token, httponly=True, samesite='Lax', max_age=7*24*60*60)
            return resp
            
    # Error response
    error_msg = result.get('error', 'Registration failed')
    response_data = {
        "status": "error",
        "remark": "registration_error",
        "message": {
            "error": [error_msg]
        }
    }
    return jsonify(response_data), 400


# =============================================================================
# LARAVEL COMPATIBILITY ENDPOINTS FOR FLUTTER MOBILE APP
# =============================================================================

import asyncio
import concurrent.futures
from datetime import datetime
import pytz

def run_async_in_new_loop(async_func, *args, **kwargs):
    """Run an async function in a new event loop inside a separate thread to prevent loop closed issues."""
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


@auth_bp.route('/api/trade/<symbol_id>', methods=['GET'])
@login_required
def api_trade_symbol_details(symbol_id):
    """API: Get trading details for a symbol (Laravel compatibility)."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        wallet_mgr = get_wallet_manager()
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        # Resolve quote
        async def fetch_quote(sym):
            from data_fetcher import UpstoxDataFetcher
            fetcher = UpstoxDataFetcher()
            try:
                from index_config import AVAILABLE_INDICES
                query_sym = AVAILABLE_INDICES.get(sym).symbol if sym in AVAILABLE_INDICES else sym
                quotes = await fetcher.get_stock_quotes([query_sym])
                return quotes[0] if quotes else None
            except Exception:
                return None
            finally:
                await fetcher.close()
                
        quote = None
        try:
            quote = run_async_in_new_loop(fetch_quote, symbol_id)
        except Exception:
            pass
            
        price = 100.0
        change = 0.0
        pct = 0.0
        volume = 0
        company_name = symbol_id
        open_p = 0.0
        high_p = 0.0
        low_p = 0.0
        prev_close = 0.0
        exchange = "NSE"
        
        if quote:
            price = quote.get('ltp', 100.0)
            change = quote.get('day_change', 0.0)
            pct = quote.get('percentage_change', 0.0)
            volume = quote.get('volume') or 0
            company_name = quote.get('company_name') or symbol_id
            open_p = quote.get('open', 0.0) or 0.0
            high_p = quote.get('high', 0.0) or 0.0
            low_p = quote.get('low', 0.0) or 0.0
            prev_close = quote.get('close', 0.0) or 0.0
        else:
            # Fallback for indices if API fails
            symbol_upper = symbol_id.upper()
            is_option = any(kw in symbol_upper for kw in ["CALL", "PUT", "CE", "PE"]) or (" " in symbol_id and any(kw in symbol_upper for kw in ["JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "JAN", "FEB", "MAR", "APR", "MAY"]))
            
            if is_option:
                price = 0.15
                if "NIFTY" in symbol_upper:
                    price = 85.40
                elif "BANKNIFTY" in symbol_upper:
                    price = 124.50
                elif "FINNIFTY" in symbol_upper:
                    price = 45.80
                elif "SENSEX" in symbol_upper:
                    price = 0.10
                
                # Retrieve active position price if one exists for user
                try:
                    positions = db_mgr.get_active_positions(user['email'])
                    pos_item = next((p for p in positions if p['symbol'] == symbol_id), None)
                    if pos_item:
                        price = pos_item.get('current_premium') or pos_item['entry_price']
                except Exception:
                    pass
                
                company_name = symbol_id
                exchange = "BSE" if "SENSEX" in symbol_upper else "NSE"
                open_p = price * 1.2
                high_p = price * 1.5
                low_p = price * 0.5
                prev_close = price * 1.3
            elif symbol_id == 'NIFTY':
                price = 23433.70; company_name = "NIFTY 50"
                open_p = 23282.45; high_p = 23462.30; low_p = 23247.30; prev_close = 23405.60
            elif symbol_id == 'SENSEX':
                price = 74415.52; company_name = "BSE SENSEX"; exchange = "BSE"
                open_p = 74200.0; high_p = 74550.0; low_p = 74100.0; prev_close = 74350.0
            elif symbol_id == 'BANKNIFTY':
                price = 54186.15; company_name = "NIFTY Bank"
                open_p = 54050.0; high_p = 54300.0; low_p = 53950.0; prev_close = 54120.0
            elif symbol_id == 'FINNIFTY':
                price = 24100.20; company_name = "NIFTY Financial Services"
                open_p = 24050.0; high_p = 24200.0; low_p = 23980.0; prev_close = 24080.0
            elif symbol_id == 'MIDCPNIFTY':
                price = 12150.80; company_name = "NIFTY Midcap Select"
                open_p = 12100.0; high_p = 12200.0; low_p = 12050.0; prev_close = 12130.0
            else:
                # Resolve from complete instruments list to get correct company name and exchange
                symbol_upper = symbol_id.upper()
                from data_fetcher import UpstoxDataFetcher
                fetcher = UpstoxDataFetcher()
                all_inst = fetcher.get_all_instruments()
                match = next((item for item in all_inst if item['symbol'] == symbol_upper), None)
                if match:
                    company_name = match['name']
                    exchange = match['exchange']
                else:
                    company_name = f"{symbol_id} India Ltd"
                    exchange = "NSE"
                
                # Mock a stable, realistic price using symbol hash
                import hashlib
                h = int(hashlib.md5(symbol_upper.encode()).hexdigest(), 16)
                price = (h % 950) + 50.0 # Consistent price between 50 and 1000
                open_p = price * 0.985
                high_p = price * 1.015
                low_p = price * 0.978
                prev_close = price * 0.99

        # Estimate day change if not available
        if change == 0.0 and prev_close > 0:
            change = round(price - prev_close, 2)
            pct = round((change / prev_close) * 100, 2)
            
        # Estimate 52-week high/low from current price
        year_high = round(high_p * 1.12, 2) if high_p > 0 else round(price * 1.12, 2)
        year_low = round(low_p * 0.94, 2) if low_p > 0 else round(price * 0.94, 2)
                
        # Get user holdings for this symbol
        holdings = db_mgr.get_holdings(user['email'])
        h_item = next((h for h in holdings if h['symbol'] == symbol_id), None)
        holding_qty = float(h_item['quantity']) if h_item else 0.0
        
        # User cash balance
        cash_balance = wallet_mgr.get_balance(user['email'])
        
        response_data = {
            "status": "success",
            "remark": "trade_details",
            "message": {
                "success": ["Trade details loaded successfully"]
            },
            "data": {
                "pair": {
                    "id": 1,
                    "symbol": f"{symbol_id}/INR",
                    "coin": {
                        "id": 1,
                        "symbol": symbol_id,
                        "name": company_name,
                        "image_path": ""
                    },
                    "market": {
                        "id": 1,
                        "name": "INR",
                        "currency": {
                            "id": 1,
                            "symbol": "INR",
                            "name": "Indian Rupee",
                            "image_path": ""
                        }
                    },
                    "market_data": {
                        "id": "1",
                        "price": str(price),
                        "percent_change_1h": str(pct),
                        "percent_change_24h": str(pct),
                        "market_cap": str(volume * price),
                        "html_classes": {
                            "percent_change_1h": "up" if pct >= 0 else "down",
                            "percent_change_24h": "up" if pct >= 0 else "down"
                        },
                        "open": str(open_p),
                        "high": str(high_p),
                        "low": str(low_p),
                        "prev_close": str(prev_close),
                        "day_change": str(change),
                        "exchange": exchange,
                        "year_high": str(year_high),
                        "year_low": str(year_low)
                    },
                    "percent_charge_for_buy": "0",
                    "percent_charge_for_sell": "0",
                    "minimum_buy_amount": "1",
                    "maximum_buy_amount": "100000000",
                    "minimum_sell_amount": "1",
                    "maximum_sell_amount": "100000000",
                    "listed_market_name": exchange,
                    "coin_id": "1",
                    "market_id": "1"
                },
                "is_favorite": "0",
                "coin_wallet": {
                    "id": 1,
                    "user_type": "user",
                    "wallet_type": "spot",
                    "balance": str(holding_qty),
                    "currency": {
                        "id": 1,
                        "symbol": symbol_id,
                        "name": company_name
                    }
                },
                "market_currency_wallet": {
                    "id": 2,
                    "user_type": "user",
                    "wallet_type": "spot",
                    "balance": f"{cash_balance:.2f}",
                    "currency": {
                        "id": 1,
                        "symbol": "INR",
                        "name": "Indian Rupee"
                    }
                }
            }
        }
        return jsonify(response_data)
    except Exception as e:
        return jsonify({"status": "error", "message": {"error": [str(e)]}}), 500


@auth_bp.route('/api/trade/order/book/<symbol_id>', methods=['GET'])
@login_required
def api_trade_order_book(symbol_id):
    """API: Get mock live order book for a symbol around its current price."""
    try:
        # Resolve LTP
        async def fetch_quote(sym):
            from data_fetcher import UpstoxDataFetcher
            fetcher = UpstoxDataFetcher()
            try:
                from index_config import AVAILABLE_INDICES
                query_sym = AVAILABLE_INDICES.get(sym).symbol if sym in AVAILABLE_INDICES else sym
                quotes = await fetcher.get_stock_quotes([query_sym])
                return quotes[0] if quotes else None
            except Exception:
                return None
            finally:
                await fetcher.close()
                
        quote = None
        try:
            quote = run_async_in_new_loop(fetch_quote, symbol_id)
        except Exception:
            pass
            
        price = 100.0
        if quote:
            price = quote.get('ltp', 100.0)
        else:
            if symbol_id == 'NIFTY':
                price = 23433.70
            elif symbol_id == 'SENSEX':
                price = 74415.52
            elif symbol_id == 'BANKNIFTY':
                price = 54186.15
            elif symbol_id == 'FINNIFTY':
                price = 24100.20
            elif symbol_id == 'MIDCPNIFTY':
                price = 12150.80
                
        import random
        buy_orders = []
        sell_orders = []
        
        for i in range(5):
            b_price = price - (i + 1) * (0.05 if price < 500 else 1.0)
            b_qty = round(random.uniform(10, 500), 1)
            buy_orders.append({
                "id": i + 1,
                "user_id": "0",
                "pair_id": "1",
                "coin_id": "1",
                "trx": "MOCK",
                "order_side": "1",
                "order_type": "1",
                "rate": f"{b_price:.2f}",
                "price": f"{b_price:.2f}",
                "amount": str(b_qty),
                "total": f"{b_price * b_qty:.2f}",
                "filled_amount": "0.0",
                "filed_percentage": "0.0",
                "charge": "0.0",
                "status": "open",
                "created_at": "",
                "updated_at": ""
            })
            
            s_price = price + (i + 1) * (0.05 if price < 500 else 1.0)
            s_qty = round(random.uniform(10, 500), 1)
            sell_orders.append({
                "id": 10 + i + 1,
                "user_id": "0",
                "pair_id": "1",
                "coin_id": "1",
                "trx": "MOCK",
                "order_side": "2",
                "order_type": "1",
                "rate": f"{s_price:.2f}",
                "price": f"{s_price:.2f}",
                "amount": str(s_qty),
                "total": f"{s_price * s_qty:.2f}",
                "filled_amount": "0.0",
                "filed_percentage": "0.0",
                "charge": "0.0",
                "status": "open",
                "created_at": "",
                "updated_at": ""
            })
            
        return jsonify({
            "status": "success",
            "remark": "order_book",
            "message": {"success": ["Order book loaded"]},
            "data": {
                "buy_side_orders": buy_orders,
                "sell_side_orders": sell_orders
            }
        })
    except Exception as e:
        return jsonify({"status": "error", "message": {"error": [str(e)]}}), 500


@auth_bp.route('/api/trade/history/<symbol_id>', methods=['GET'])
@login_required
def api_trade_history(symbol_id):
    """API: Get mock recent public trades for a symbol around its current price."""
    try:
        # Resolve LTP
        async def fetch_quote(sym):
            from data_fetcher import UpstoxDataFetcher
            fetcher = UpstoxDataFetcher()
            try:
                from index_config import AVAILABLE_INDICES
                query_sym = AVAILABLE_INDICES.get(sym).symbol if sym in AVAILABLE_INDICES else sym
                quotes = await fetcher.get_stock_quotes([query_sym])
                return quotes[0] if quotes else None
            except Exception:
                return None
            finally:
                await fetcher.close()
                
        quote = None
        try:
            quote = run_async_in_new_loop(fetch_quote, symbol_id)
        except Exception:
            pass
            
        price = 100.0
        if quote:
            price = quote.get('ltp', 100.0)
        else:
            if symbol_id == 'NIFTY':
                price = 23433.70
            elif symbol_id == 'SENSEX':
                price = 74415.52
            elif symbol_id == 'BANKNIFTY':
                price = 54186.15
            elif symbol_id == 'FINNIFTY':
                price = 24100.20
            elif symbol_id == 'MIDCPNIFTY':
                price = 12150.80
                
        import random
        from datetime import datetime as dt, timedelta
        trades = []
        
        for i in range(10):
            t_price = price + random.uniform(-5.0, 5.0)
            t_qty = round(random.uniform(5, 200), 1)
            trade_time = (dt.now() - timedelta(seconds=i*15)).strftime("%Y-%m-%d %H:%M:%S")
            trades.append({
                "id": i + 1,
                "order_id": str(1000 + i),
                "pair_id": "1",
                "amount": str(t_qty),
                "rate": f"{t_price:.2f}",
                "trade_side": str(random.choice([1, 2])),
                "created_at": trade_time,
                "updated_at": trade_time,
                "formatted_date": trade_time
            })
            
        return jsonify({
            "status": "success",
            "remark": "trade_history",
            "data": {
                "trades": trades
            }
        })
    except Exception as e:
        return jsonify({"status": "error", "message": {"error": [str(e)]}}), 500


@auth_bp.route('/api/trade/order/list/<symbol_id>', methods=['GET'])
@login_required
def api_trade_order_list(symbol_id):
    """API: Get active/open orders for a specific symbol."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        positions = db_mgr.get_active_positions(user['email'])
        symbol_positions = [p for p in positions if p['symbol'] == symbol_id]
        
        orders_data = []
        for p in symbol_positions:
            orders_data.append({
                "id": str(p['id']),
                "amount": str(p['quantity']),
                "rate": str(p['entry_price']),
                "order_side": "1" if p['signal_type'] in ["BUY", "CALL"] else "2",
                "order_type": "2",
                "status": "open",
                "trx": f"TX{p['id']}",
                "total": str(p['entry_price'] * p['quantity']),
                "filled_amount": "0",
                "created_at": p['entry_time'],
                "pair": {"symbol": f"{p['symbol']}/INR"}
            })
            
        return jsonify({
            "status": "success",
            "remark": "open_orders",
            "message": {"success": ["Open orders loaded"]},
            "data": {
                "orders": {
                    "current_page": 1,
                    "next_page_url": None,
                    "data": orders_data
                }
            }
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": {"error": [str(e)]}
        }), 500


@auth_bp.route('/api/order/save/<symbol_id>', methods=['POST'])
@login_required
def api_save_order(symbol_id):
    """API: Place a buy/sell order for stock or index."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        data = request.get_json(silent=True) or request.values or {}
        rate_str = data.get('rate')
        amount_str = data.get('amount')
        order_side = str(data.get('order_side', '1')) # '1' for BUY, '2' for SELL
        
        try:
            quantity = int(float(amount_str))
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": {"error": ["Invalid quantity (amount)"]}}), 400
            
        try:
            price = float(rate_str)
        except (ValueError, TypeError):
            return jsonify({"status": "error", "message": {"error": ["Invalid price (rate)"]}}), 400
            
        if quantity <= 0:
            return jsonify({"status": "error", "message": {"error": ["Quantity must be greater than zero"]}}), 400
            
        if price <= 0:
            async def get_ltp():
                from data_fetcher import UpstoxDataFetcher
                fetcher = UpstoxDataFetcher()
                try:
                    from index_config import AVAILABLE_INDICES
                    query_sym = AVAILABLE_INDICES.get(symbol_id).symbol if symbol_id in AVAILABLE_INDICES else symbol_id
                    quotes = await fetcher.get_stock_quotes([query_sym])
                    return quotes[0]['ltp'] if quotes else 0.0
                except Exception:
                    return 0.0
                finally:
                    await fetcher.close()
            try:
                price = run_async_in_new_loop(get_ltp)
            except Exception:
                pass
            if price <= 0:
                price = 100.0
                
        symbol_upper = symbol_id.upper()
        is_option = any(kw in symbol_upper for kw in ["CALL", "PUT", "CE", "PE"]) or (" " in symbol_id and any(kw in symbol_upper for kw in ["JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "JAN", "FEB", "MAR", "APR", "MAY"]))
        
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        
        if is_option:
            type_str = "OPTION"
            
            # Determine lot size
            lot_size = 1
            if "SENSEX" in symbol_upper:
                lot_size = 10
            elif "BANKNIFTY" in symbol_upper:
                lot_size = 30
            elif "FINNIFTY" in symbol_upper:
                lot_size = 40
            elif "MIDCPNIFTY" in symbol_upper:
                lot_size = 75
            elif "NIFTY" in symbol_upper:
                lot_size = 75
                
            # Parse strike price from symbol name
            import re
            strike = 0
            strike_match = re.search(r'\b\d{5}\b|\b\d{4}\b', symbol_id)
            if strike_match:
                strike = int(strike_match.group(0))
                
            # If placing buy order
            if order_side == '1':
                signal_type = "CALL" if ("CALL" in symbol_upper or "CE" in symbol_upper) else "PUT"
                success, msg = trader.place_user_order(
                    user_email=user['email'],
                    symbol=symbol_id,
                    type_str="OPTION",
                    signal_type=signal_type,
                    strike=strike,
                    price=price,
                    quantity=quantity,
                    lot_size=lot_size
                )
            else: # SELL / EXIT order
                # Find matching active position to close it
                from performance_manager import get_performance_manager
                db_mgr = get_performance_manager()
                positions = db_mgr.get_active_positions(user['email'])
                pos = next((p for p in positions if p['symbol'] == symbol_id), None)
                if pos:
                    success = trader.close_position(pos['id'], price)
                    msg = "Position closed successfully" if success else "Failed to close position"
                else:
                    success = False
                    msg = "No open option position found to exit"
        else:
            type_str = "STOCK"
            signal_type = "BUY" if order_side == '1' else "SELL"
            success, msg = trader.place_user_order(
                user_email=user['email'],
                symbol=symbol_id,
                type_str="STOCK",
                signal_type=signal_type,
                strike=0,
                price=price,
                quantity=quantity,
                lot_size=1
            )

        
        if success:
            return jsonify({
                "status": "success",
                "remark": "order_placed",
                "message": {
                    "success": ["Order placed successfully: " + msg]
                }
            })
        else:
            return jsonify({
                "status": "error",
                "remark": "order_failed",
                "message": {
                    "error": [msg]
                }
            }), 400
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "remark": "server_error",
            "message": {
                "error": [str(e)]
            }
        }), 500


@auth_bp.route('/api/order/cancel/<order_id>', methods=['POST'])
@login_required
def api_cancel_order(order_id):
    """API: Cancel/Close an open order (active position)."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        from virtual_trader import get_virtual_trader
        trader = get_virtual_trader()
        
        try:
            trade_id = int(order_id)
        except ValueError:
            return jsonify({"status": "error", "message": {"error": ["Invalid order ID"]}}), 400
            
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        positions = db_mgr.get_active_positions(user['email'])
        pos = next((p for p in positions if p['id'] == trade_id), None)
        
        if not pos:
            return jsonify({"status": "error", "message": {"error": ["Order not found or already closed"]}}), 404
            
        async def get_ltp():
            from data_fetcher import UpstoxDataFetcher
            fetcher = UpstoxDataFetcher()
            try:
                from index_config import AVAILABLE_INDICES
                query_sym = AVAILABLE_INDICES.get(pos['symbol']).symbol if pos['symbol'] in AVAILABLE_INDICES else pos['symbol']
                quotes = await fetcher.get_stock_quotes([query_sym])
                return quotes[0]['ltp'] if quotes else 0.0
            except Exception:
                return 0.0
            finally:
                await fetcher.close()
                
        price = 0.0
        try:
            price = run_async_in_new_loop(get_ltp)
        except Exception:
            pass
        if price <= 0:
            price = pos['entry_price']
            
        closed = trader.close_position(trade_id, price)
        if closed:
            return jsonify({
                "status": "success",
                "remark": "order_cancelled",
                "message": {
                    "success": ["Order cancelled/closed successfully"]
                }
            })
        else:
            return jsonify({"status": "error", "message": {"error": ["Failed to close order"]}}), 500
            
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": {"error": [str(e)]}
        }), 500


@auth_bp.route('/api/order/<history_type>', methods=['GET'])
@login_required
def api_user_order_history(history_type):
    """API: Get user order/trade history or open orders (global)."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        from performance_manager import get_performance_manager
        db_mgr = get_performance_manager()
        
        orders_data = []
        if history_type == 'open':
            positions = db_mgr.get_active_positions(user['email'])
            for p in positions:
                orders_data.append({
                    "id": str(p['id']),
                    "amount": str(p['quantity']),
                    "rate": str(p['entry_price']),
                    "order_side": "1" if p['signal_type'] in ["BUY", "CALL"] else "2",
                    "order_type": "2",
                    "status": "open",
                    "trx": f"TX{p['id']}",
                    "total": str(p['entry_price'] * p['quantity']),
                    "filled_amount": "0",
                    "created_at": p['entry_time'],
                    "pair": {"symbol": f"{p['symbol']}/INR"}
                })
        else:
            trades = db_mgr.get_user_trades(user['email'], limit=50)
            for t in trades:
                orders_data.append({
                    "id": str(t['id']),
                    "amount": str(t['quantity']),
                    "rate": str(t.get('entry_price') or t.get('exit_price') or 0.0),
                    "order_side": "1" if t['signal_type'] in ["BUY", "CALL"] else "2",
                    "order_type": "2",
                    "status": "completed",
                    "trx": f"TX{t['id']}",
                    "total": str((t.get('entry_price') or t.get('exit_price') or 0.0) * t['quantity']),
                    "filled_amount": str(t['quantity']),
                    "created_at": t.get('entry_time') or t.get('exit_time') or "",
                    "pair": {"symbol": f"{t['symbol']}/INR"}
                })
                
        return jsonify({
            "status": "success",
            "remark": "order_history",
            "message": {"success": ["Orders loaded"]},
            "data": {
                "orders": {
                    "current_page": 1,
                    "next_page_url": None,
                    "data": orders_data
                }
            }
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": {"error": [str(e)]}
        }), 500


@auth_bp.route('/api/general-setting', methods=['GET'])
def api_general_setting():
    """API: Mock general settings parameters expected by Flutter app."""
    return jsonify({
        "status": "success",
        "remark": "general_setting",
        "data": {
            "general_setting": {
                "sitename": "Dhan Trading",
                "cur_text": "INR",
                "cur_sym": "₹",
                "active_template": "basic",
                "kyc_rejection_reason": None,
                "kyc_status": "1",
                "profile_complete": "1"
            }
        }
    })


@auth_bp.route('/api/user-info', methods=['GET'])
@login_required
def api_user_info():
    """API: Get user profile details (Laravel compatibility)."""
    try:
        user = get_current_user()
        if not user:
            return jsonify({"status": "error", "message": {"error": ["Unauthorized"]}}), 401
            
        name_parts = user.get('name', 'User').split(' ')
        firstname = name_parts[0]
        lastname = name_parts[1] if len(name_parts) > 1 else ""
        
        return jsonify({
            "status": "success",
            "remark": "user_info",
            "data": {
                "user": {
                    "id": 1,
                    "firstname": firstname,
                    "lastname": lastname,
                    "username": user.get('name', 'User'),
                    "email": user.get('email', ''),
                    "mobile": user.get('phone', '1234567890'),
                    "kv": "1",
                    "ev": "1",
                    "sv": "1",
                    "profile_complete": "1"
                }
            }
        })
    except Exception as e:
        return jsonify({"status": "error", "message": {"error": [str(e)]}}), 500

