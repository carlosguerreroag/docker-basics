from flask import Flask, request, jsonify

app = Flask(__name__)

# hardcoded users for demo purposes
VALID_USERS = {
    "admin": "admin",
    "operator": "operator"
}

@app.route("/auth")
def auth():
    auth_header = request.headers.get("Authorization", "")

    if not auth_header.startswith("Basic "):
        return jsonify({"error": "missing credentials"}), 401

    import base64
    try:
        decoded = base64.b64decode(auth_header[6:]).decode("utf-8")
        username, password = decoded.split(":", 1)
    except Exception:
        return jsonify({"error": "invalid encoding"}), 401

    if username in VALID_USERS and VALID_USERS[username] == password:
        # Éxito: devolvemos 200 con headers que Traefik inyectará en la petición al backend
        response = jsonify({"authenticated": True, "user": username})
        response.headers["X-Auth-User"] = username
        response.headers["X-Auth-Role"] = "admin" if username == "admin" else "operator"
        return response, 200
    else:
        return jsonify({"error": "invalid credentials"}), 401

@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)