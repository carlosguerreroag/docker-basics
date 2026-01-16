## `/01-basics`

1. **Dockerize “Hello World”**
   Goal: create a Docker image that prints a message to the console when run.

2. **Dockerize a Nginx Web Server**
   Goal: containerize a Nginx Service exposing a basic HTTP endpoint.

3. **Dockerize a Python API**
   Goal: create a Docker image for a Python API listening on a configurable port.

---

## `/02-configuration`

4. **Environment variables and volumes**
   Goal: run a dockerized application that reads configuration from environment variables and persists data using volumes.

---

## `/03-compose`

5. **App + PostgreSQL (Docker Compose)**
   Goal: run an application and a PostgreSQL database using Docker Compose with persistent storage.

6. **App + Redis (Docker Compose)**
   Goal: integrate Redis as a cache service for a dockerized application using Docker Compose.

---

## `/04-optimization`

7. **Optimized multi-stage build**
   Goal: build a Docker image using multi-stage builds to minimize the final image size.

---

## `/05-networking`

8. **Frontend + backend + Nginx**
   Goal: deploy separate frontend and backend services and serve them through Nginx containers.

9. **Reverse proxy with multiple services**
   Goal: configure a reverse proxy that routes traffic to multiple dockerized services based on host or path.

---

## `/06-environments`

10. **Development vs production environment**
    Goal: define separate Docker configurations for development and production using the same codebase.

---

## `/07-reliability`

11. **Healthchecks and restart policies**
    Goal: add healthchecks to containers and configure automatic restart policies.

12. **Centralized logging**
    Goal: centralize logs from multiple containers into a single logging service.

---

## `/08-security`

13. **Docker image hardening**
    Goal: build secure Docker images applying container hardening best practices.

---

## `/09-ci-cd`

14. **CI pipeline to build and publish images**
    Goal: implement a CI pipeline that builds, versions, and publishes Docker images automatically.

---

## `/10-architecture`

15. **Local microservices architecture**
    Goal: simulate a complete microservices architecture locally using Docker Compose.

---
