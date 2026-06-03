import urllib.request
import json
import ssl
import urllib.error

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

api_key = "AIzaSyBIa_7IK0OQdlnwpqrOyIPGXuosTxDw6uk"
url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={api_key}"

payload = {
    "contents": [{
        "parts": [{"text": "Hello"}]
    }]
}

req = urllib.request.Request(
    url, 
    data=json.dumps(payload).encode(),
    headers={"Content-Type": "application/json"}
)

try:
    with urllib.request.urlopen(req, context=ctx) as response:
        data = json.loads(response.read().decode())
        print(data)
except urllib.error.HTTPError as e:
    print("HTTP Error code:", e.code)
    try:
        body = e.read().decode()
        print("Error body:", body)
    except Exception as re:
        print("Failed to read body:", re)
except Exception as e:
    print("Error:", e)
