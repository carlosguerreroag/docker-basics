## Docker Basics — *Hello World*

### Description

Containerization of a minimal web application with the goal of running it in an isolated environment and making it accessible over HTTP.

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

---

### Expected result

A web application that can be started with `docker run` and responds over HTTP, with no external runtime dependencies.

---
