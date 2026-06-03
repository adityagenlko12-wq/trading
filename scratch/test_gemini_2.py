import os
import requests
import json
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY", "")
print(f"API Key: {api_key[:10]}...{api_key[-10:] if len(api_key) > 10 else ''}")

url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}"

prompt = """
You are a financial analyst. Analyze the following details for 'NIFTY':
- Current Price: 23150.50
- Technical Trend: BULLISH

INSTRUCTIONS:
1. Use Google Search Grounding to fetch the latest financial news and events affecting NIFTY as of today.
2. Return a JSON object with a list of 'news' (latest headlines) and 'reasoning' (explaining the news and technical alignment).

Return ONLY valid JSON.
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
    response = requests.post(url, json=payload, headers={"Content-Type": "application/json"}, timeout=15)
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        res_json = response.json()
        text = res_json.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
        print("Response Text:")
        print(text)
        
        # Print grounding metadata if present
        metadata = res_json.get("candidates", [{}])[0].get("groundingMetadata", {})
        if metadata:
            print("\nGrounding Metadata queries:")
            print(metadata.get("webSearchQueries"))
    else:
        print("Error:")
        print(response.text)
except Exception as e:
    print(f"Exception: {e}")
