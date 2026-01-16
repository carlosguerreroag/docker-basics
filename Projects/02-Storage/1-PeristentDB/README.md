### 📌 Dockerized Database (MySQL / PostgreSQL)
---
**Goal:** create a Dockerized relational database (MySQL or PostgreSQL) with persistent data storage, running inside a Vagrant-managed virtual machine.

### 👉 Demonstration
By running the command:

```bash
vagrant up
```

A virtual machine is automatically provisioned using Vagrant. Inside this virtual machine, Docker Engine is installed and used to pull and run a Docker image for the selected database engine (MySQL or PostgreSQL).

The database container is configured with:
* Exposed ports to allow connections from both the host machine and the VM
* Environment variables for database name, user, and password
* A Docker volume (or bind mount) to ensure data persistence across container restarts and VM reboots

Once the container is running, the database service is available and ready to accept connections.
We can verify connectivity from the host machine using:

```bash
mysql -h localhost -P 3306 -u user -p
```

## ![demonstration](screenshot.png)

