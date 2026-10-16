import json
import urllib.request
import urllib.error

BASE_URL = "http://13.201.27.141:8080/help-support-backend"

def test_api():
    # 1. Login
    login_url = f"{BASE_URL}/api/v1/auth/login"
    login_data = json.dumps({"usernameOrEmail": "admin@filmytell.com", "password": "Password@123"}).encode('utf-8')
    req = urllib.request.Request(login_url, data=login_data, headers={"Content-Type": "application/json"})
    
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            print("Login success:", data["success"])
            token = data["data"]["accessToken"]
    except Exception as e:
        print("Login failed:", e)
        return

    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # 2. Get Agents
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/users/agents", headers=headers)
        with urllib.request.urlopen(req) as resp:
            agents = json.loads(resp.read().decode('utf-8'))
            print("Agents API response:", json.dumps(agents, indent=2))
    except Exception as e:
        print("Get agents failed:", e)

    # 3. Get Teams
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/teams", headers=headers)
        with urllib.request.urlopen(req) as resp:
            teams = json.loads(resp.read().decode('utf-8'))
            print("Teams API response:", json.dumps(teams, indent=2))
    except Exception as e:
        print("Get teams failed:", e)

    # 4. Get Tickets
    try:
        req = urllib.request.Request(f"{BASE_URL}/api/v1/tickets", headers=headers)
        with urllib.request.urlopen(req) as resp:
            tickets = json.loads(resp.read().decode('utf-8'))
            print("Tickets API response:", json.dumps(tickets, indent=2))
    except Exception as e:
        print("Get tickets failed:", e)

if __name__ == "__main__":
    test_api()
