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
9. **Reverse proxy with multiple services**
   Goal: configure a reverse proxy that routes traffic to multiple dockerized services based on host or path.


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
### **/07-docker-networking**

**Goal:** Deepen container networking.
**Project:**

* Create 2 microservices that communicate with each other using different networks (maybe queues)
* Simulate a microservices architecture with separate front and back ends
  **Learning:**
* Types of networks (`bridge`, `overlay`, `host`)
* Communication between containers
* Secure connections and internal firewalls

---

### **/09-logging-and-monitoring**

**Goal:** Implement observability in containers.
**Project:**

* Container with Nginx and a container with ELK stack (Elasticsearch + Logstash + Kibana)
* View centralized logs of your application
  **Learning:**
* Centralized logging
* Container monitoring
* Metrics export and alerts

---

### **/10-docker-security**

**Goal:** Improve container security.
**Project:**

* Scan your images with `Trivy`
* Restrict container permissions (`USER`, `cap-drop`)
  **Learning:**
* Security best practices
* Users and permissions in containers
* Vulnerability scanning

---

### **/11-ci-cd-with-docker**

**Goal:** Integrate Docker into DevOps pipelines.
**Project:**

* GitHub Actions / GitLab CI pipeline that:

  * Builds the image
  * Runs tests
  * Pushes to Docker Registry
    **Learning:**
* Automated pipelines
* Integration of tests inside Docker
* Secure image publishing

---

## **Expert Level**

### **/12-kubernetes-and-docker**

**Goal:** Take Docker to orchestration.
**Project:**

* Deploy your multi-container stack in a local Kubernetes cluster (`minikube`)
  **Learning:**
* Pods, Deployments, and Services
* ConfigMaps and Secrets
* Auto-scaling

---

### **/13-docker-swarm-and-advanced-networking**

**Goal:** Orchestration with native Docker.
**Project:**

* Create a Docker Swarm cluster with multiple nodes
* Deploy your multi-container application with load balancing
  **Learning:**
* Docker Swarm
* Overlay networks
* Rolling updates and rollback

---

### **/14-optimization-and-hardening**

**Goal:** Make images truly professional and secure.
**Project:**

* Optimize images (Alpine, distroless)
* Analyze resource usage and performance
  **Learning:**
* Image minimization
* Container hardening
* Efficient caching and build strategies

---
### Paso 5: CI/CD con Docker

Automatizar la construcción y el push de tus imágenes.

* **GitHub Actions:** Crear un workflow que cada vez que hagas `push`, construya la imagen y la suba a **Docker Hub** o **GitHub Container Registry**.

### Paso 6: Seguridad en Docker

* **User switching:** No ejecutar procesos como `root` dentro del contenedor.
* **Scanning:** Uso de herramientas como `trivy` o `docker scout` para buscar vulnerabilidades en tus imágenes.

---

