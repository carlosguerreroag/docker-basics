### **/04-multi-container-app**

**Goal:** Learn Docker Compose and container interaction.
**Project:** A simple fullstack application:

* Frontend: React or Vue.
* Backend: Python Flask or Node.js.
* Database: Postgres or MongoDB.
  **Learning:**
* Docker Compose (`docker-compose.yml`)
* Container networks
* Volumes and data persistence

---

### **/05-docker-volumes-and-storage**

**Goal:** Handle persistent data in containers.
**Project:**

* A MySQL/Postgres container with persistent data
* A container that makes daily backups to a mounted volume
  **Learning:**
* Volumes vs Bind mounts
* Database backup and restore inside containers
* Storage strategies for containers

---

### **/06-env-and-config-management**

**Goal:** Manage configurations and secrets in containers.
**Project:**

* Extend your Python API/Nginx using `.env` for configurations
* Use `docker secret` for sensitive data
  **Learning:**
* Environment variables in Docker
* Sensitive and secure configuration
* Multi-stage builds to separate secrets from the final build

---

### **/07-docker-networking**

**Goal:** Deepen container networking.
**Project:**

* Create 2 microservices that communicate with each other using different networks
* Simulate a microservices architecture with separate front and back ends
  **Learning:**
* Types of networks (`bridge`, `overlay`, `host`)
* Communication between containers
* Secure connections and internal firewalls

---

## **Advanced Level**

### **/08-multi-stage-builds**

**Goal:** Optimize images and CI/CD processes.
**Project:**

* Create a Python API with a multi-stage build
* Separate development and production dependencies
  **Learning:**
* Multi-stage builds
* Image size reduction
* Caching strategies

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
