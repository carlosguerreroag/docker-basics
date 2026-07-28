### 🔐 Backend Authentication & IP Whitelist
---
**Goal:** protect backend services with multiple authentication strategies, including BasicAuth, IPWhitelist, and ForwardAuth (delegating auth to an external service). Combine middlewares on the same router to create layered security, and configure a ForwardAuth server that supports both API clients (401) and browser-based login flows (302 redirect).

### 👉 Setup

```bash
# 1. Generate credentials for the dashboard
./panel_pwgen.sh -u admin -p mypassword

# 2. Generate credentials for backend services (BasicAuth)
./panel_pwgen.sh -u backend -p backend -P ./secrets/backend-creds

# 3. Add your Cloudflare API token
echo "your-cloudflare-api-token" > secrets/cloudflare-token

# 4. Set correct permissions for acme.json
chmod 600 config/letsencrypt/acme.json

# 5. Start the stack
docker compose up -d
```

### 👉 Architecture

The `docker-compose.yaml` deploys **Traefik**, four backend services (`backend1`–`backend4`), and two auth servers (`auth-server-basic`, `auth-server-v2`). All services are connected to the `internal` network (isolated from the host). Only Traefik is exposed on ports 80/443 and connected to the public `traefik` network.

**Service overview:**

| Service | Auth mechanism | Middlewares | Auth server |
|---------|---------------|-------------|-------------|
| `backend1` | BasicAuth (Traefik) | `backend1` (basicauth) | None (Traefik handles it) |
| `backend2` | IPWhitelist + BasicAuth | `backend2-ipallowlist`, `backend2-basicauth` | None (Traefik handles it) |
| `backend3` | ForwardAuth (basic) | `backend3-forwardauth` | `auth-server-basic` (simple auth API) |
| `backend4` | ForwardAuth (v2) + IPWhitelist | `backend4-forwardauth`, `backend4-ipallowlist` | `auth-server-v2` (browser + API support) |

**Auth servers:**

- **`auth-server-basic`** (`auth-server/basic/basic.py`): a minimal Flask app with a single `/auth` endpoint. Validates Basic Auth credentials and returns 200 with `X-Auth-User` and `X-Auth-Role` headers, or 401 on failure. Not publicly exposed.

- **`auth-server-v2`** (`auth-server/v2/v2.py`): an extended Flask app that adds browser login support and session management. Its `/auth` endpoint:
  - Checks for a valid session cookie → 200 + auth headers
  - Validates Basic Auth credentials → 200 + auth headers
  - For browser requests (`Accept: text/html`) → 302 redirect to `/login`
  - For API requests → 401 JSON error
  - Exposed publicly at `auth.cguerrero.xyz` via Traefik, with ENV `AUTH_PUBLIC_URL` pointing to the public domain so redirects use the correct external URL. Session cookies are scoped to `.cguerrero.xyz` (shared across all subdomains).

**Middleware chains:**

- `backend2`: `ipallowlist → basicauth` — IP is checked first, credentials only requested if IP is allowed
- `backend4`: `forwardauth → ipallowlist` — auth is validated first, then IP gateway is checked

### 👉 Test Results

**Test 1 — backend1 (BasicAuth only)**

```bash
# No credentials → 401
curl -I https://backend1.cguerrero.xyz
# HTTP/2 401 — www-authenticate: Basic realm="traefik"

# Valid credentials → 200
curl -IH "Authorization: Basic $(echo -n backend:backend | base64)" https://backend1.cguerrero.xyz
# HTTP/2 200 — set-cookie: backend1_sticky_cookie=...
```

**Test 2 — backend2 (IPWhitelist + BasicAuth)**

```bash
# From host (allowed IP) — no credentials → 401
curl -I https://backend2.cguerrero.xyz
# HTTP/2 401 — www-authenticate: Basic realm="traefik"

# From host (allowed IP) — valid credentials → 200
curl -IH "Authorization: Basic $(echo -n backend:backend | base64)" https://backend2.cguerrero.xyz
# HTTP/2 200

# From Docker container (different IP, not in whitelist) → 403
docker run --rm -it curlimages/curl -I https://backend2.cguerrero.xyz
# HTTP/2 403 — IP not in sourcerange, blocked before auth prompt

# From Docker container (allowed IP via whitelist fallback) — with credentials → 200
docker run --rm -it curlimages/curl -IH "Authorization: Basic $(echo -n backend:backend | base64)" https://backend2.cguerrero.xyz
# HTTP/2 200
```

The `sourcerange` includes `172.17.0.0/16` and `172.18.0.0/16` to cover Docker bridge networks, plus the host's LAN IP `192.168.1.152/32`.

**Test 3 — backend3 (ForwardAuth with auth-server-basic)**

```bash
# No credentials → 401 (from auth-server, JSON response)
curl -I https://backend3.cguerrero.xyz
# HTTP/2 401 — content-type: application/json — server: Werkzeug

# Valid credentials → 200 + X-Auth-* headers injected into backend request
curl -IH "Authorization: Basic $(echo -n admin:admin | base64)" https://backend3.cguerrero.xyz
# HTTP/2 200

# Inspect headers received by the backend
curl -sH "Authorization: Basic $(echo -n admin:admin | base64)" https://backend3.cguerrero.xyz | jq '.request.headers'
# Shows: x-auth-user: "admin", x-auth-role: "admin" — headers injected by ForwardAuth
```

The backend receives `X-Auth-User` and `X-Auth-Role` headers injected by Traefik from the auth server's response, configured via `forwardauth.authResponseHeaders`.

**Test 4 — backend4 (ForwardAuth v2 + IPWhitelist)**

```bash
# No credentials → 401 (JSON, API mode detected by auth-server-v2)
curl -I https://backend4.cguerrero.xyz
# HTTP/2 401 — content-type: application/json — server: Werkzeug

# Invalid credentials → 401
curl -IH "Authorization: Basic $(echo -n admin:admin2 | base64)" https://backend4.cguerrero.xyz
# HTTP/2 401

# Valid credentials → 200 + X-Auth-* headers injected
curl -sH "Authorization: Basic $(echo -n admin:admin | base64)" https://backend4.cguerrero.xyz | jq '.request.headers'
# Shows: x-auth-user: "admin", x-auth-role: "admin"

# From Docker container (different IP, not in whitelist) → 403
docker run --rm -it curlimages/curl -IH "Authorization: Basic $(echo -n admin:admin | base64)" https://backend4.cguerrero.xyz
# HTTP/2 403 — IP 172.18.0.x not in sourcerange (only 192.168.1.152/32 allowed)
```

**Test 5 — backend4 browser login flow (auth-server-v2)**

```bash
# Browser request (Accept: text/html) → 302 redirect to login page
curl -IH "Accept: text/html" https://backend4.cguerrero.xyz
# HTTP/2 302 — location: https://auth.cguerrero.xyz/login?next=https%3A%2F%2Fbackend4.cguerrero.xyz%2F

# Following the redirect renders the login form
curl -LH "Accept: text/html" https://backend4.cguerrero.xyz
# Renders HTML login form at auth.cguerrero.xyz/login with next=backend4.cguerrero.xyz/

# After login (POST to auth.cguerrero.xyz/login), browser is redirected back to backend4
# with a session cookie scoped to .cguerrero.xyz, allowing access to all subdomains
```

### 👉 Key Concepts

**Backend authentication vs dashboard authentication:**
- Dashboard auth protects Traefik's internal admin UI (`api@internal`)
- Backend auth protects application services (containers) — same middlewares, different routers
- Different services can have different auth policies (one can be public, another IP-restricted, another with full auth)

**BasicAuth middleware:**
- Traefik validates credentials against a `usersfile` (bcrypt-hashed) before forwarding to the backend
- On failure, responds with `401` and `WWW-Authenticate: Basic realm="traefik"` header
- By default, Traefik **removes** the `Authorization` header before forwarding to the backend (security measure)
- Credentials file is mounted as a Docker secret in `/run/secrets/`

**DigestAuth middleware:**
- Alternative to BasicAuth that never transmits the password (uses nonce-based challenge-response)
- Requires passwords stored as `MD5(user:realm:pass)` — not compatible with bcrypt
- Largely obsolete: if you have TLS (which you should), BasicAuth is simpler and equally secure

**IPWhitelist middleware:**
- Restricts access to a list of CIDR ranges via `sourcerange`
- IPs are checked against `X-Forwarded-For` or the direct TCP connection IP
- `ipStrategy.depth` and `ipStrategy.excludedIPs` handle proxy/CDN scenarios
- Docker containers have their own IP range (`172.17.0.0/16`, `172.18.0.0/16`) — include these for local testing
- A container not in the whitelist gets `403 Forbidden` immediately (no auth prompt)

**ForwardAuth middleware:**
- Delegates the authentication decision to an external HTTP service
- Traefik forwards the original request headers to the auth server (method, path, headers)
- Auth server response codes determine the outcome:
  - **2xx** → allow, forward to backend (auth headers from response are injected)
  - **401** → not authenticated, return to client
  - **403** → authenticated but forbidden
  - **302** → redirect to login page (browser follows it)
  - **5xx** → auth server error, return 500
- `authResponseHeaders` lists which headers from the auth server's response get injected into the backend request (e.g., `X-Auth-User`, `X-Auth-Role`)
- `authRequestHeaders` restricts which original headers are forwarded to the auth server (default: all)
- `trustForwardHeader` tells Traefik to trust `X-Forwarded-*` headers when talking to the auth server

**Browser login flow with ForwardAuth:**
1. Browser requests `backend4.cguerrero.xyz` → no session cookie → auth server returns `302` to `auth.cguerrero.xyz/login?next=...`
2. Browser renders login form at `auth.cguerrero.xyz/login`
3. User submits credentials → auth server validates → sets session cookie with `domain=.cguerrero.xyz` → redirects to the original `next` URL
4. Browser requests `backend4.cguerrero.xyz` again, now with the session cookie → Traefik forwards it to the auth server → auth server validates session → `200` + `X-Auth-*` headers → backend responds

The `next` URL is built from `X-Forwarded-Proto`, `X-Forwarded-Host`, and `X-Forwarded-Uri` headers that Traefik automatically injects. The `AUTH_PUBLIC_URL` environment variable ensures the redirect `Location` header uses the publicly resolvable domain (`https://auth.cguerrero.xyz`) instead of the internal Docker hostname.

**Cookie domain scoping:**
- Session cookies must be scoped to the parent domain (`.cguerrero.xyz`) so they are sent to all subdomains (`backend4.cguerrero.xyz`, `backend3.cguerrero.xyz`, `auth.cguerrero.xyz`)
- Without this, the cookie set on `auth.cguerrero.xyz` would not be sent when the browser redirects to `backend4.cguerrero.xyz`

**Combining middlewares:**
- Multiple middlewares are chained on a router: `middlewares=middleware1,middleware2,middleware3`
- They execute in the exact order listed — if any rejects, the chain stops
- Best practice: put the most restrictive/cheapest middleware first (e.g., IPWhitelist before BasicAuth, so blocked IPs never get a login prompt)

**Middleware chain design rules:**
1. Most restrictive first (IPWhitelist before auth)
2. RateLimit before auth (prevents brute force from saturating the auth server)
3. Security headers last (applied to the response, not the request)
4. Redirect scheme before everything (HTTP→HTTPS at entrypoint level)

**Auth server resilience:**
- The auth server is a single point of failure — if it's down, all ForwardAuth-protected services return 500
- Mitigation: multiple replicas, health checks, circuit breaker
- Traefik's Docker load balancer distributes ForwardAuth requests across replicas automatically

**Configuration files:**
- `config/static/traefik.yaml` — static Traefik config with Let's Encrypt resolver, `api.insecure: false`, file provider, and entrypoints
- `config/letsencrypt/acme.json` — Let's Encrypt certificate storage (must be `chmod 600`)
- `config/dynamic/` — directory for dynamic config files (watched by Traefik)
- `secrets/backend-creds` — bcrypt-hashed credentials for backend1 and backend2 BasicAuth
- `secrets/traefik-dashboard-creds` — credentials for the Traefik dashboard
- `secrets/cloudflare-token` — Cloudflare API token for DNS-01 challenge
- `.env` — `MY_DOMAIN=cguerrero.xyz` used in all Host labels

**Auth server implementations:**
- `auth-server/basic/` — minimal Flask app: validates Basic Auth, returns 200/401 with X-Auth-* headers
- `auth-server/v2/` — extended Flask app: adds session cookies, browser login page, `AUTH_PUBLIC_URL` for correct redirects, cookie domain scoping, and `is_browser_request()` detection

---