import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

api_key = "AIzaSyBIa_7IK0OQdlnwpqrOyIPGXuosTxDw6uk"
# Try gemini-2.0-flash
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}"

payload = {
    "contents": [{
        "parts": [{"text": "What is the latest news about Reliance Industries stock today?"}]
    }],
    "tools": [{"googleSearchRetrieval": {}}],
    "generationConfig": {
        "temperature": 0.3,
        "maxOutputTokens": 800
    }
}

req = urllib.request.Request(
    url, 
    data=json.dumps(payload).encode(),
    headers={"Content-Type": "application/json"}
)

try:
    with urllib.request.urlopen(req, context=ctx) as response:
        data = json.loads(response.read().decode())
        text = data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
        print("Response Text:\n", text)
        print("\nGrounding Metadata:")
        print(json.dumps(data.get("candidates", [{}])[0].get("groundingMetadata", {}), indent=2))
except Exception as e:
    print("Error:", e)
