### 📌 Docker Compose Healthchecks & Service Dependencies

---

**Goal:** understand how **Docker Compose healthchecks** work and how `depends_on` with health conditions controls service startup order, ensuring that application containers only start when their dependencies are fully ready, all running inside a Vagrant-managed virtual machine.

### 👉 Demonstration

By running the command:

```bash
vagrant up
```

A virtual machine is automatically provisioned using Vagrant. Inside this virtual machine, Docker Engine and Docker Compose are used to start a multi-container application defined in a `docker-compose.yaml` file.

The project consists of two services:

* **PostgreSQL database** with a healthcheck to verify readiness
* **Flask API** that depends on the database being healthy before starting

The PostgreSQL service is configured with:

* Environment variables for database name and user
* A Docker Secret for the database password
* A persistent Docker volume for data storage
* A healthcheck using `pg_isready`

The API service is configured with:

* A build-based Docker image
* Environment variables for database connectivity
* A Docker Secret for the database password
* A `depends_on` rule with `condition: service_healthy`

Once all services are running, we can verify connectivity from the host machine:

## ![demonstration](screenshot.png)

This demonstrates how healthchecks and service dependencies prevent race conditions during container startup.
* The database container starts first
* The API container waits until the database healthcheck reports **healthy**
* The API only attempts to connect once the database is ready to accept connections

---
