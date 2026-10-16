import urllib.request
import urllib.error
import json

BASE_URL = "http://13.201.27.141:8080/help-support-backend"

# 1. Login to get Admin Token
login_req = urllib.request.Request(
    f"{BASE_URL}/api/v1/auth/login",
    data=json.dumps({"usernameOrEmail": "admin@filmytell.com", "password": "Password@123"}).encode('utf-8'),
    headers={"Content-Type": "application/json"}
)
with urllib.request.urlopen(login_req) as resp:
    token = json.loads(resp.read().decode('utf-8'))["data"]["accessToken"]

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json",
    "Accept": "application/json"
}

payload = {
    "username": "shiv_navale_agent",
    "email": "shiv.navale.test@filmytell.com",
    "password": "Password@123",
    "firstName": "Shiv",
    "lastName": "Navale",
    "teamId": 1,
    "roles": ["ROLE_SUPPORT_MEMBER"]
}

req = urllib.request.Request(f"{BASE_URL}/api/v1/auth/register", data=json.dumps(payload).encode('utf-8'), headers=headers)
try:
    with urllib.request.urlopen(req) as resp:
        print("REGISTER SUCCESS:", resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    print(f"REGISTER HTTP {e.code}:", e.read().decode('utf-8'))
except Exception as e:
    print("REGISTER ERROR:", e)
