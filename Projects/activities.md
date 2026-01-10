# Docker Projects — Scope and Description

## 1️⃣ Docker Basics — *Hello World*

### Project

Containerization of a minimal web application.

### Scope

* Creation of a `Dockerfile`
* Selection of an appropriate base image
* Exposing the application port
* Use of environment variables
* Execution via `docker run`

### Key concepts

* Differences between `CMD` and `ENTRYPOINT`
* `EXPOSE` does not publish ports
* Purpose and usage of `.dockerignore`

**Level**: required

---

## 2️⃣ Docker & Configuration — *12-Factor App*

### Project

Environment-configurable application.

### Scope

* Environment variables
* `.env` files
* Environment-specific behavior (dev / prod)
* No hardcoded configuration

### Key concepts

* Configuration must not be baked into the image
* Image portability

**Level**: important

---

## 3️⃣ Docker Compose — *Multi-service Application*

### Project

Application with external dependencies.

Examples:

* Backend + PostgreSQL
* Frontend + API

### Scope

* `docker-compose.yml`
* Networks
* Volumes
* `depends_on`
* Healthchecks

### Key concepts

* Container-to-container networking
* Data persistence

**Level**: realistic

---

## 4️⃣ Image Optimization — *Production-grade Image*

### Project

Docker image optimization.

### Scope

* Multi-stage builds
* Image size reduction
* Layer caching
* Non-root user execution

### Metrics

* Image size under 200 MB
* Fast and reproducible builds

**Level**: differentiates junior from senior

---

## 5️⃣ Security — *Container Hardening*

### Project

Basic container security.

### Scope

* Non-root user
* Image scanning
* Reduced attack surface
* Secrets externalized from images

### Key concepts

* Fewer packages result in fewer CVEs

**Level**: DevSecOps fundamentals

---

## 6️⃣ Logs & Debugging — *Failure Scenarios*

### Project

Correct logging strategy.

### Scope

* Logging to stdout / stderr
* Log rotation
* Container debugging
* `docker logs`, `docker exec`

### Key concepts

* No internal file-based logging

**Level**: production-grade requirement

---

## 7️⃣ Networking — *Service Communication*

### Project

Docker networking behavior.

### Scope

* Bridge networks
* Internal DNS
* Exposing vs publishing ports
* Simulating service failure

### Key concepts

* `localhost` is container-scoped

**Level**: critical

---

## 8️⃣ Volumes & Data — *Persistent State*

### Project

Data persistence.

### Scope

* Named volumes
* Bind mounts
* Backups
* Data restoration

### Key concepts

* Containers are ephemeral, data is not

**Level**: required

---

## 9️⃣ Advanced Build — *Local Pipeline*

### Project

Build and execution automation.

### Scope

* Build scripts
* Image tagging
* Versioning
* CI/CD readiness

**Level**: bridge to pipelines

---

## 🔟 Final Docker Project

### Project

Application ready for Kubernetes.

Requirements:

* Optimized image
* Environment-based configuration
* Stateless design
* Healthchecks
* Non-root execution

A correct implementation implies Kubernetes readiness without code changes.

---

## Docker Golden Rule

> If it cannot be executed with `docker run`, it is not ready.

---

# Docker Projects — Objectives Only

## 1️⃣ Basic container

Deliver a web application that can be executed with `docker run` and responds over HTTP.

---

## 2️⃣ External configuration

Ensure the same image runs in multiple environments by changing only environment variables.

---

## 3️⃣ Application with dependencies

Run an application alongside another service (e.g. a database) without relying on `localhost`.

---

## 4️⃣ Persistence

Ensure data survives container destruction and recreation.

---

## 5️⃣ Optimized image

Produce a small, fast-building, production-ready image.

---

## 6️⃣ Basic security

Run the application without root privileges and with minimal attack surface.

---

## 7️⃣ Proper logging

Ensure all relevant output is observable externally without accessing the container filesystem.

---

## 8️⃣ Networking

Enable predictable and isolated communication between multiple containers.

---

## 9️⃣ Versioning

Make builds identifiable, versioned, and reproducible.

---

## 🔟 Kubernetes readiness

Produce a stateless, configurable, secure, and observable image without modifying application code.

---

## Final goal

Allow any third party to clone the repository and run the application using Docker only, without additional local dependencies.

---
