### 🛞 Traefik Let's Encrypt — Automated TLS Certificates
---
**Goal:** configure Traefik to automatically obtain and renew valid TLS certificates from Let's Encrypt using the DNS-01 challenge with Cloudflare, enabling HTTPS for real domains without manual certificate management.

### 👉 Demonstration
By running the commands:

```bash
# 1. Configure your domain in config/.env
echo "MY_DOMAIN=yourdomain.com" > config/.env

# 2. Add your Cloudflare API token with DNS edit permissions
echo "your-cloudflare-api-token" > secrets/cloudflare-token

# 3. Set correct permissions for acme.json (required by Traefik)
chmod 600 config/letsencrypt/acme.json

# 4. Update the email in config/static/traefik.yaml (line 36)
# Change: email: fake@email.com
# To: email: your-real@email.com

# 5. Start the stack
docker compose up -d

# 6. Test the HTTPS endpoint
curl -sv https://web1.${MY_DOMAIN} | jq
```

The `docker-compose.yaml` starts Traefik alongside two services (`web1` and `web2`), each with 2 replicas of `ealen/echo-server`. The static configuration (`config/static/traefik.yaml`) defines a `certificatesResolvers` section named `myresolver` that uses the ACME protocol with DNS-01 challenge via Cloudflare. The Cloudflare API token is securely injected using Docker secrets and exposed as the environment variable `CF_DNS_API_TOKEN_FILE`.

Traefik automatically requests wildcard certificates for `${MY_DOMAIN}` and `*.${MY_DOMAIN}`. The certificates are stored in `config/letsencrypt/acme.json` and persisted across container restarts. Each router is configured with `tls.certresolver=myresolver` and specifies the domains to include in the certificate via `tls.domains[0].main` and `tls.domains[0].sans`.

**Network architecture:**
Traefik is connected to two networks: `traefik` (external, exposed to host ports 80/443) and `internal` (shared with backends). The backend services (`web1`, `web2`) are only connected to the `internal` network, which is marked as `internal: true`. This means:
- Backends are **not directly accessible** from the host or external networks
- All traffic must pass through Traefik (single entry point)
- Traefik can reach backends via the `internal` network to forward requests
- This follows the principle of least privilege and defense in depth

**Test 1: Automatic certificate issuance**

```bash
curl -svk https://web1.${MY_DOMAIN} | jq '.environment.HOSTNAME'
```

**Observation:** The verbose output shows:
1. TLS handshake with the domain `web1.${MY_DOMAIN}`
2. Server presents a valid Let's Encrypt certificate (not self-signed)
3. Certificate subject: `CN=yourdomain.com` with SAN `*.yourdomain.com`
4. Certificate issuer: `Let's Encrypt` (valid CA, no browser warnings)
5. Connection established using TLS 1.3
6. Response headers include `x-forwarded-proto: https`

**Test 2: Certificate persistence**

```bash
docker compose down
docker compose up -d
curl -svk https://web1.${MY_DOMAIN} | jq
```

**Observation:** After restarting the containers, Traefik loads the existing certificate from `acme.json` instead of requesting a new one. No new ACME challenge is performed, demonstrating certificate persistence.

**Test 3: Wildcard certificate coverage**

```bash
curl -svk https://web2.${MY_DOMAIN} | jq
curl -svk https://traefik.${MY_DOMAIN}/dashboard/ | head -20
```

**Observation:** Both `web2.${MY_DOMAIN}` and `traefik.${MY_DOMAIN}` are served with the same wildcard certificate (`*.${MY_DOMAIN}`), confirming that a single certificate covers all subdomains.

### 👉 Key Concepts

**ACME protocol (Automated Certificate Management Environment):**
- Open protocol used by Let's Encrypt to automate certificate issuance and renewal
- Traefik implements ACME client functionality natively
- Supports three challenge types: HTTP-01, TLS-ALPN-01, and DNS-01
- Certificates are valid for 90 days and automatically renewed 30 days before expiration

**DNS-01 challenge:**
- Proves domain ownership by creating a specific DNS TXT record
- Required for wildcard certificates (`*.domain.com`)
- Does not require port 80 to be publicly accessible (unlike HTTP-01)
- Traefik integrates with DNS providers via plugins (Cloudflare, Route53, DigitalOcean, etc.)
- The DNS provider API token is used to programmatically create the TXT record

**certificatesResolvers:**
- Defines ACME certificate resolvers in Traefik's static configuration
- Each resolver specifies the ACME server (Let's Encrypt production or staging), email, storage file, and challenge type
- Routers reference a resolver via `tls.certresolver=<resolver-name>`
- Multiple resolvers can be configured for different domains or challenge types

**acme.json storage:**
- JSON file where Traefik stores obtained certificates and account information
- Must be persisted (via Docker volume) to avoid re-issuing certificates on every restart
- Contains the private key, certificate, and domain metadata
- **File permissions must be 600** (`chmod 600 acme.json`) — Traefik refuses to start if the file is readable by others
- The file must exist before starting Traefik (create with `touch acme.json` if it doesn't exist)

**Configuration files:**
- `config/.env` — stores the `MY_DOMAIN` variable used throughout docker-compose.yaml labels
- `config/static/traefik.yaml` — static configuration with certificatesResolvers, email must be updated to a real address
- `secrets/cloudflare-token` — Cloudflare API token with DNS:Edit permissions for the domain

**Docker secrets:**
- Secure way to inject sensitive data (API tokens, passwords) into containers
- Stored as files in `/run/secrets/` inside the container
- Not exposed in environment variables or `docker inspect` output
- The Cloudflare API token is injected as a secret and referenced via `CF_DNS_API_TOKEN_FILE`

**Staging vs production:**
- Let's Encrypt provides a staging environment for testing (rate limits: 30,000 certificates/week)
- Production environment has stricter limits (50 certificates per registered domain/week)
- Staging certificates are not trusted by browsers (show warnings)
- Always test with staging before switching to production to avoid hitting rate limits

**Rate limits:**
- Let's Encrypt enforces rate limits to prevent abuse
- Main limits: 50 certificates per domain/week, 5 failed validations/hour
- DNS-01 challenge has no additional rate limits beyond the standard ones
- Traefik caches certificates in `acme.json` to minimize ACME API calls
- If rate limit is hit, Traefik will retry automatically after the limit resets

**HTTP→HTTPS redirection:**
- Configured at the entrypoint level in `traefik.yaml` using `http.redirections.entryPoint`
- All HTTP requests (port 80) receive a 301 redirect to HTTPS (port 443)
- Ensures clients always use encrypted connections
- Required for HTTP-01 challenge (but not for DNS-01)

---
