## `/05-architecture`

1. **Reverse proxy with multiple services**
   Goal: configure a reverse proxy that routes traffic to multiple dockerized services based on host or path.
   Goal: simulate a complete microservices architecture locally using Docker Compose.

---

## **/06-reliability**

2. **Project:**
   **Goal:** Implement observability in containers, (+container monitoring).

* View centralized logs of your application
  **Learning:**
* Centralized logging
* Container monitoring
* Metrics export and alerts

---

### **/07-ci-cd-with-docker**

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

Automatizar la construcción y el push de tus imágenes.

* **GitHub Actions:** Crear un workflow que cada vez que hagas `push`, construya la imagen y la suba a **Docker Hub** o **GitHub Container Registry**.

**CI pipeline to build and publish images**
  Goal: implement a CI pipeline that builds, versions, and publishes Docker images automatically.


2. Advanced Build — *Local Pipeline*

### Project

Build and execution automation.

### Scope

* Build scripts
* Image tagging
* Versioning
* CI/CD readiness

**Level**: bridge to pipelines

---

### **/08-kubernetes-ready**

Application ready for Kubernetes.

Requirements:

* Optimized image
* Environment-based configuration
* Stateless design
* Healthchecks
* Non-root execution

A correct implementation implies Kubernetes readiness without code changes.

---

### **/09-kubernetes-and-docker**

**Goal:** Take Docker to orchestration.
**Project:**

* Deploy your multi-container stack in a local Kubernetes cluster (`minikube`)
  **Learning:**
* Pods, Deployments, and Services
* ConfigMaps and Secrets
* Auto-scaling

---

### **/10-docker-swarm-and-advanced-networking**

**Goal:** Orchestration with native Docker.
**Project:**

* Create a Docker Swarm cluster with multiple nodes
* Deploy your multi-container application with load balancing
  **Learning:**
* Docker Swarm
* Overlay networks
* Rolling updates and rollback

---

### **/11-optimization-and-hardening**

**Goal:** Make images truly professional and secure.
**Project:**

* Optimize images (Alpine, distroless)
* Analyze resource usage and performance
  **Learning:**
* Image minimization
* Container hardening
* Efficient caching and build strategies

---

### **/12-docker-security**

**Goal:** Improve container security.
**Project:**

* Scan your images with `Trivy`
* Restrict container permissions (`USER`, `cap-drop`)
  **Learning:**
* Security best practices
* Users and permissions in containers
* Vulnerability scanning

* **User switching:** No ejecutar procesos como `root` dentro del contenedor.
* **Scanning:** Uso de herramientas como `trivy` o `docker scout` para buscar vulnerabilidades en tus imágenes.

2. **Docker image hardening**
    Goal: build secure Docker images applying container hardening best practices.

3. Security — *Container Hardening*

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
