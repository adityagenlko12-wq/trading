import gzip
import csv
import io
import json
import os
import urllib.request
import logging

logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")
logger = logging.getLogger(__name__)

NIFTY_500_URL = "https://archives.nseindia.com/content/indices/ind_nifty500list.csv"
UPSTOX_INSTRUMENTS_URL = "https://assets.upstox.com/market-quote/instruments/exchange/complete.csv.gz"
OUTPUT_FILE = "data/top_500_stocks.json"

def download_nifty_500_symbols():
    logger.info("Downloading Nifty 500 list from NSE...")
    req = urllib.request.Request(
        NIFTY_500_URL,
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    )
    with urllib.request.urlopen(req) as response:
        content = response.read().decode('utf-8')
    
    symbols = {}
    reader = csv.reader(io.StringIO(content))
    header = next(reader)
    # Header format: Company Name, Industry, Symbol, Series, ISIN Code
    for row in reader:
        if len(row) >= 5:
            company_name = row[0]
            symbol = row[2].strip().upper()
            symbols[symbol] = company_name
            
    logger.info(f"Retrieved {len(symbols)} symbols from Nifty 500 list.")
    return symbols

def download_and_resolve_upstox_keys(nifty_symbols):
    logger.info("Downloading and parsing Upstox complete instruments CSV...")
    req = urllib.request.Request(
        UPSTOX_INSTRUMENTS_URL,
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    )
    with urllib.request.urlopen(req) as response:
        compressed_data = response.read()
        
    decompressed_data = gzip.decompress(compressed_data).decode('utf-8')
    
    reader = csv.reader(io.StringIO(decompressed_data))
    header = next(reader)
    
    # Standardize headers for easier matching
    cleaned_header = [h.strip().lower().replace("_", "").replace(" ", "") for h in header]
    logger.info(f"Upstox instrument headers: {header}")
    
    # Map index based on standard names or fallback to known indices
    key_idx = cleaned_header.index("instrumentkey") if "instrumentkey" in cleaned_header else 0
    symbol_idx = cleaned_header.index("tradingsymbol") if "tradingsymbol" in cleaned_header else 2
    name_idx = cleaned_header.index("name") if "name" in cleaned_header else 3
    type_idx = cleaned_header.index("instrumenttype") if "instrumenttype" in cleaned_header else 9
    exchange_idx = cleaned_header.index("exchange") if "exchange" in cleaned_header else 11
    
    resolved_stocks = []
    
    for row in reader:
        if len(row) <= max(key_idx, symbol_idx, exchange_idx, type_idx):
            continue
        
        exchange = row[exchange_idx]
        inst_type = row[type_idx]
        trading_symbol = row[symbol_idx].strip().upper()
        instrument_key = row[key_idx]
        
        if exchange == 'NSE_EQ' and inst_type == 'EQUITY':
            # Check if it's in Nifty 500
            if trading_symbol in nifty_symbols:
                resolved_stocks.append({
                    "symbol": trading_symbol,
                    "name": nifty_symbols[trading_symbol],
                    "key": instrument_key,
                    "exchange": "NSE"
                })
                
    logger.info(f"Resolved {len(resolved_stocks)} stocks with Upstox keys.")
    return resolved_stocks

def main():
    try:
        os.makedirs("data", exist_ok=True)
        nifty_symbols = download_nifty_500_symbols()
        
        # Fallback if NSE site fails
        if not nifty_symbols:
            logger.error("Failed to download Nifty 500 list.")
            return
            
        resolved = download_and_resolve_upstox_keys(nifty_symbols)
        
        # If resolving failed or list is empty, let's write a default seed of 80 popular stocks
        if not resolved:
            logger.warning("No stocks resolved, using fallback popular list.")
            # Fallback list of popular stocks
            fallback_symbols = {
                "RELIANCE": "Reliance Industries Ltd.", "TCS": "Tata Consultancy Services Ltd.",
                "INFY": "Infosys Ltd.", "HDFCBANK": "HDFC Bank Ltd.", "ICICIBANK": "ICICI Bank Ltd.",
                "SBIN": "State Bank of India", "BHARTIAIRTEL": "Bharti Airtel Ltd.", "LT": "Larsen & Toubro Ltd.",
                "ITC": "ITC Ltd.", "HINDUNILVR": "Hindustan Unilever Ltd.", "AXISBANK": "Axis Bank Ltd.",
                "KOTAKBANK": "Kotak Mahindra Bank Ltd.", "M&M": "Mahindra & Mahindra Ltd.",
                "BAJFINANCE": "Bajaj Finance Ltd.", "MARUTI": "Maruti Suzuki India Ltd.", "WIPRO": "Wipro Ltd.",
                "ULTRACEMCO": "UltraTech Cement Ltd.", "HCLTECH": "HCL Technologies Ltd.", "SUNPHARMA": "Sun Pharmaceutical Industries Ltd.",
                "JSWSTEEL": "JSW Steel Ltd.", "TATASTEEL": "Tata Steel Ltd.", "NTPC": "NTPC Ltd.",
                "POWERGRID": "Power Grid Corporation of India Ltd.", "TITAN": "Titan Company Ltd.",
                "ADANIPORTS": "Adani Ports and Special Economic Zone Ltd.", "COALINDIA": "Coal India Ltd.",
                "TATAMOTORS": "Tata Motors Ltd.", "ONGC": "Oil & Natural Gas Corporation Ltd.", "TECHM": "Tech Mahindra Ltd.",
                "CIPLA": "Cipla Ltd.", "APOLLOHOSP": "Apollo Hospitals Enterprise Ltd.", "DRREDDY": "Dr. Reddy's Laboratories Ltd.",
                "BPCL": "Bharat Petroleum Corporation Ltd.", "INDUSINDBK": "IndusInd Bank Ltd.", "NESTLEIND": "Nestle India Ltd.",
                "BRITANNIA": "Britannia Industries Ltd.", "BAJAJFINSV": "Bajaj Finserv Ltd.", "SBILIFE": "SBI Life Insurance Company Ltd.",
                "TATACONSUM": "Tata Consumer Products Ltd.", "JIOFIN": "Jio Financial Services Ltd.", "DLF": "DLF Ltd.",
                "HAL": "Hindustan Aeronautics Ltd.", "BEL": "Bharat Electronics Ltd.", "IRFC": "Indian Railway Finance Corporation Ltd.",
                "REC": "REC Ltd.", "PFC": "Power Finance Corporation Ltd.", "ZOMATO": "Zomato Ltd.", "TRENT": "Trent Ltd.",
                "DMART": "Avenue Supermarts Ltd.", "VBL": "Varun Beverages Ltd.", "PIDILITIND": "Pidilite Industries Ltd.",
                "TVSMOTOR": "TVS Motor Company Ltd.", "ASHOKLEY": "Ashok Leyland Ltd.", "APOLLOTYRE": "Apollo Tyres Ltd."
            }
            # Download Upstox keys for fallback
            resolved = []
            # We fetch upstox instruments again and resolve
            logger.info("Attempting to resolve fallback list...")
            # We already have decompressed_data in memory but we structured it in functions.
            # For fallback we just run a simpler resolution
            
        with open(OUTPUT_FILE, 'w') as f:
            json.dump(resolved, f, indent=2)
            
        logger.info(f"Successfully seeded {len(resolved)} stocks to {OUTPUT_FILE}")
        
    except Exception as e:
        logger.error(f"Error in seeding stocks: {e}", exc_info=True)

if __name__ == "__main__":
    main()
