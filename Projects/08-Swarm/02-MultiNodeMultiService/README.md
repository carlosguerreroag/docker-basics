### 🐳 Multi-Node Multi-Service Docker Swarm Cluster
---
**Goal:** spin up a 3-node Docker Swarm cluster with Vagrant and deploy a multi-service application (vote/redis/worker/db/result) across overlay networks `frontend` and `backend`.

### 👉 Demonstration
By running the commands:

```bash
vagrant up
vagrant ssh n01
docker service ls
```

Vagrant provisions three Ubuntu VMs (n01, n02, n03) on a private network. Node `n01` initializes the Swarm manager, shares the join token through a shared folder, and `n02` and `n03` automatically join the cluster as workers. Once joined, the manager creates two overlay networks (`frontend` and `backend`) and deploys the classic example voting app as replicated services: `vote` and `redis` on `frontend`, `db` and `result` on `backend`, and `worker` spanning both. `docker service ls` from `n01` shows all services running with their replicas spread across the cluster.

---
