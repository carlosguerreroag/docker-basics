### 🛞 Traefik Dashboard
---
**Goal:** spin up a Traefik reverse proxy with the dashboard enabled, exposing entrypoints for HTTP and HTTPS traffic, and configure it to discover backend services automatically via the Docker provider.

### 👉 Demonstration
By running the commands:

```bash
docker compose up -d
curl http://localhost:8080/dashboard/
```

The `docker-compose.yaml` starts a Traefik container with three published ports: `8000` for the `web` entrypoint, `4430` for the `websecure` entrypoint, and `8080` for the API/dashboard. The static configuration (`config/traefik.yaml`) defines the Docker provider to auto-discover containers with exposed labels, sets the dashboard in insecure mode, and enables debug-level logging. The Docker socket is mounted (read-only) so Traefik can watch for new services in real time. Accessing `http://localhost:8080/dashboard/` shows the Traefik dashboard with an overview of routers, services, middlewares, and entrypoints.

---
