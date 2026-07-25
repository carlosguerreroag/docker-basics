### 📌 Secure Traefik Dashboard
---
**Goal:** protect the Traefik dashboard with Basic Authentication, disable the insecure mode, and route it through a TLS-secured domain using Let's Encrypt with Cloudflare DNS-01 challenge.

### 👉 Demonstration
By running the commands:

```bash
./panel_pwgen.sh -u admin -p mypassword
docker compose up -d
curl -u admin:mypassword https://traefik.mydomain.com/dashboard/
```

The `panel_pwgen.sh` script generates a bcrypt-hashed credential line using the `carlosguerrer0/htpasswd:v1` container and writes it to `secrets/traefik-dashboard-creds`, which is mounted into Traefik as a Docker secret.

Our `docker-compose.yaml` starts Traefik and a `web2` demo service (ealen/echo-server), injecting both the Cloudflare API token and the dashboard credentials via Docker secrets. Traefik connects to two networks: `traefik` (public, for client traffic) and `internal` (private, for backend communication).

The static configuration (`config/static/traefik.yaml`) disables `api.insecure`, enables the dashboard API, sets up the `file` provider to watch for dynamic config changes, and configures Let's Encrypt with the Cloudflare DNS-01 challenge for wildcard certificates (`*.mydomain.com`). The `web` entrypoint automatically redirects all HTTP traffic to `websecure` (HTTPS).

The dashboard is routed via `traefik.mydomain.com` on the `websecure` entrypoint with TLS enabled. A BasicAuth middleware (`traefik-dashboard`) is attached to the router, reading the hashed credentials from `/run/secrets/traefik-dashboard-creds`. This router declares `tls.domains[0].main` and `tls.domains[0].sans` to request a wildcard certificate (`*.mydomain.com`) from Let's Encrypt via the Cloudflare DNS-01 challenge.

The `web2` service is also exposed behind the same wildcard certificate with sticky sessions, health checks, and TLS. It only needs `tls.certresolver=myresolver` to reuse the existing wildcard — Traefik automatically matches `web2.mydomain.com` against the `*.mydomain.com` certificate stored in `acme.json`, so there's no need to redeclare `tls.domains` on this router.

---