from flask import Flask, request, jsonify, make_response, redirect
from urllib.parse import quote
import base64
import os

app = Flask(__name__)

AUTH_PUBLIC_URL = os.environ.get("AUTH_PUBLIC_URL", "http://auth-server-v2:5000")

VALID_USERS = {
    "admin": "admin",
    "operator": "admin"
}

# Simulamos sesiones en memoria (en producción usar Redis)
sessions = {}


def is_browser_request(req):
    accept = req.headers.get("Accept", "")
    if "text/html" in accept:
        return True
    return False


def validate_basic_auth(auth_header):
    if not auth_header.startswith("Basic "):
        return None
    try:
        decoded = base64.b64decode(auth_header[6:]).decode("utf-8")
        username, password = decoded.split(":", 1)
    except Exception:
        return None
    if username in VALID_USERS and VALID_USERS[username] == password:
        return username
    return None


@app.route("/auth")
def auth():
    # 1. Comprobar cookie de sesión
    session_id = request.cookies.get("session")
    if session_id and session_id in sessions:
        username = sessions[session_id]
        response = make_response("", 200)
        response.headers["X-Auth-User"] = username
        response.headers["X-Auth-Role"] = "admin" if username == "admin" else "operator"
        return response

    # 2. Comprobar Basic Auth (API / curl)
    auth_header = request.headers.get("Authorization", "")
    username = validate_basic_auth(auth_header)
    if username:
        response = make_response("", 200)
        response.headers["X-Auth-User"] = username
        response.headers["X-Auth-Role"] = "admin" if username == "admin" else "operator"
        return response

    # 3. Sin credenciales ni sesión
    if is_browser_request(request):
        proto = request.headers.get("X-Forwarded-Proto", "https")
        host = request.headers.get("X-Forwarded-Host", "")
        uri = request.headers.get("X-Forwarded-Uri", "/")
        next_url = f"{proto}://{host}{uri}" if host else "/"
        return redirect(f"{AUTH_PUBLIC_URL}/login?next={quote(next_url, safe='')}", 302)
    else:
        return jsonify({"error": "authentication required"}), 401


@app.route("/login", methods=["GET"])
def login_page():
    next_url = request.args.get("next", "/")
    return f"""
    <!DOCTYPE html>
    <html>
    <head><title>Login</title></head>
    <body>
        <h1>Login</h1>
        <form method="post" action="/login?next={quote(next_url)}">
            <input name="username" placeholder="User" required />
            <input name="password" type="password" placeholder="Password" required />
            <button type="submit">Login</button>
        </form>
    </body>
    </html>
    """, 200


@app.route("/login", methods=["POST"])
def do_login():
    username = request.form.get("username")
    password = request.form.get("password")
    next_url = request.args.get("next", "/")

    if username in VALID_USERS and VALID_USERS[username] == password:
        import uuid
        session_id = str(uuid.uuid4())
        sessions[session_id] = username

        response = redirect(next_url, 302)
        response.set_cookie(
            "session", session_id,
            httponly=True,
            secure=True,
            samesite="Lax",
            domain=".cguerrero.xyz",
            max_age=3600
        )
        return response

    return "Invalid credentials", 401


@app.route("/logout")
def logout():
    session_id = request.cookies.get("session")
    if session_id and session_id in sessions:
        del sessions[session_id]
    response = redirect("/login", 302)
    response.delete_cookie("session")
    return response


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)