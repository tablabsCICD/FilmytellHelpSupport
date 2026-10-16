import urllib.request
import urllib.error
import json

BASE_URL = "http://13.201.27.141:8080/help-support-backend"

payloads = [
    {
        "username": "shivnavale123",
        "email": "shiv123@test.com",
        "password": "Password@123",
        "firstName": "Shiv",
        "lastName": "Navale",
    },
    {
        "username": "shivnavale456",
        "email": "shiv456@test.com",
        "password": "Password@123",
        "firstName": "Shiv",
        "lastName": "Navale",
        "roles": ["ROLE_SUPPORT_MEMBER"]
    },
    {
        "username": "shivnavale789",
        "email": "shiv789@test.com",
        "password": "Password@123",
        "firstName": "Shiv",
        "lastName": "Navale",
        "teamId": 1,
        "roles": ["ROLE_SUPPORT_MEMBER"]
    }
]

for idx, p in enumerate(payloads):
    req = urllib.request.Request(
        f"{BASE_URL}/api/v1/auth/register",
        data=json.dumps(p).encode('utf-8'),
        headers={"Content-Type": "application/json", "Accept": "application/json"}
    )
    try:
        with urllib.request.urlopen(req) as resp:
            print(f"Payload {idx} SUCCESS: {resp.read().decode('utf-8')}")
    except urllib.error.HTTPError as e:
        print(f"Payload {idx} HTTP {e.code}: {e.read().decode('utf-8')}")
    except Exception as e:
        print(f"Payload {idx} ERROR: {e}")
