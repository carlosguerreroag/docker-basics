### 🛞 Traefik TLS — Self-Signed Certificates
---
**Goal:** configure Traefik to serve HTTPS traffic using self-signed certificates, enabling TLS encryption for all client-to-proxy communication. Additionally, set up automatic HTTP→HTTPS redirection so that any plain HTTP request is seamlessly upgraded to a secure connection.

### 👉 Demonstration
By running the commands:

```bash
./certgen.sh
docker compose up -d
curl -sLkv http://web1.localhost | jq
```

The `certgen.sh` script generates a wildcard self-signed certificate for `*.localhost` using OpenSSL, valid for 1 day. The certificate and private key are stored in the `certs/` directory.

The `docker-compose.yaml` starts Traefik alongside two services (`web1` and `web2`), each with 2 replicas of `ealen/echo-server`. The static configuration (`config/static/traefik.yaml`) defines two entrypoints: `web` (port 80) and `websecure` (port 443). The `web` entrypoint is configured to automatically redirect all HTTP traffic to HTTPS using `http.redirections.entryPoint`. The dynamic configuration (`config/dynamic/tls.yaml`) loads the self-signed certificate from the mounted `certs/` directory.

**Test 1: HTTP→HTTPS redirection**

```bash
curl -sLkv http://web1.localhost | jq
```

**Observation:** The verbose output shows:
1. Initial request to `http://web1.localhost:80`
2. Traefik responds with `HTTP/1.1 301 Moved Permanently` and `Location: https://web1.localhost/`
3. curl automatically follows the redirect (`-L` flag) to HTTPS
4. TLS 1.3 handshake occurs: `TLSv1.3 (OUT), TLS handshake, Client hello`
5. Connection established using `TLSv1.3 / TLS_AES_128_GCM_SHA256`
6. Server certificate presented: `subject: CN=*.localhost`, valid from `Jul 23` to `Jul 24`
7. Certificate verification fails (expected for self-signed): `SSL certificate verification failed, continuing anyway!`
8. Final response: `HTTP/2 200` with the echo-server JSON payload
9. Response headers include `x-forwarded-proto: https`, confirming the request was served over TLS

**Test 2: Direct HTTPS request**

```bash
curl -sk https://web1.localhost | jq '.environment.HOSTNAME'
# "6643ba29eb4c"

curl -sk https://web1.localhost | jq '.environment.HOSTNAME'
# "b850c8b98ff1"
```

**Observation:** Using `-k` (insecure) skips certificate verification. Requests are load-balanced across both replicas, and the connection is encrypted with TLS.

**Test 3: Dashboard over HTTPS**

```bash
curl -sk https://traefik-dashboard.localhost/dashboard/
```

**Observation:** The dashboard is accessible via HTTPS on the `websecure` entrypoint, with the router configured to use TLS (`traefik.http.routers.traefik-dashboard.tls=true`).

### 👉 Key Concepts

**Self-signed certificates:**
- Generated locally with OpenSSL, not issued by a trusted Certificate Authority (CA)
- Browsers show security warnings because the certificate cannot be verified against a trusted root
- Suitable for development and internal environments, but not for production
- The `certgen.sh` script creates a wildcard certificate (`*.localhost`) that covers all subdomains

**TLS termination at Traefik:**
- Traefik handles the TLS handshake and decrypts incoming HTTPS requests
- Backend services receive plain HTTP traffic (no TLS configuration needed on the backends)
- This is called "TLS termination" — the proxy terminates the encrypted connection and forwards unencrypted traffic to backends
- Simplifies backend configuration and centralizes certificate management

**Static vs dynamic configuration:**
- **Static config** (`traefik.yaml`): defines entrypoints, providers, and global settings. Loaded once at startup.
- **Dynamic config** (`tls.yaml`): defines routers, services, middlewares, and TLS certificates. Can be reloaded without restarting Traefik.
- The `file` provider watches the `config/dynamic/` directory and automatically reloads changes.

**HTTP→HTTPS redirection:**
- Configured at the entrypoint level in `traefik.yaml` using `http.redirections.entryPoint`
- All requests to port 80 receive a 301 redirect to the same URL on port 443 with HTTPS scheme
- Ensures clients always use encrypted connections, even if they initially request HTTP

---
