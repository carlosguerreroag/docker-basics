# 🐳 Docker Learning Projects

Hello there! This repository contains Docker projects and exercises created while learning containerization through **self-directed study** and a **learn-by-doing approach**.

The goal is to build practical knowledge by experimenting with progressively more advanced Docker concepts.

---

## 📂 Projects folder structure

```bash
.
├── 01-Basics
├── 02-Storage
├── 03-ConfigManagement
├── 04-Networking
├── 05-Compose
├── 06-Optimization
├── 07-Logging_and_Metrics
└── to-do.md
```

Each top-level directory represents a specific Docker topic.
Inside each directory, individual subprojects explore focused use cases and configurations.

### 01 – Basics

* Running containers
* Understanding images
* Core Docker commands
* Containerizing simple applications (Nginx, Python API, etc.)

### 02 – Storage

* Docker volumes
* Bind mounts
* Database persistence

### 03 – Configuration Management

* Environment variables
* Build arguments
* Docker secrets

### 04 – Networking

* Custom networks
* Network segmentation
* Inter-container communication

### 05 – Docker Compose

* Multi-service applications
* Health checks
* Restart policies
* Dependency conditions
* Storage systems

### 06 – Optimization

* Multi-stage builds
* Image size reduction
* Production-ready image strategies

### 07 – Logging and Metrics
* Centralized container logging and debugging
* Container observability through metrics
* Integrations with Grafana

---

## 🚀 How to Run a Project

Each project is designed to run inside its own **Vagrant virtual machine**.

The purpose of this approach is to:

* Keep every project isolated
* Maintain a clean and reproducible environment
* Avoid conflicts between dependencies
* Simulate real-world infrastructure setups

### What happens when you start a project?

1. Vagrant provisions a fresh virtual machine.
2. Docker Engine is automatically installed.
3. The project environment is configured.
4. The application is built and deployed automatically inside the VM.

### Running a project

Navigate to the desired project directory and run:

```bash
vagrant up
```

Once provisioning is complete, the containerized application will be running inside the virtual machine.

If needed, you can access the VM with:

```bash
vagrant ssh
```

To stop and remove the environment:

```bash
vagrant destroy
```

This ensures every experiment starts from a clean state.

---
