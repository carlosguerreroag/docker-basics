### 📌 Dockerized ApacheBench
---
**Goal:** create a Docker image that runs ApacheBench (`ab`) — the classic HTTP server benchmarking tool.

### 👉 Demonstration
By running the commands:

```bash
docker build -t apachebench .
docker run --rm apachebench
```

An ApacheBench container is built from an Ubuntu image with `apache2-utils` installed. After the container is executed, it will benchmark `https://www.bretfisher.com/` with 10 requests and a concurrency of 2, displaying the performance results in the terminal.

![demonstration](screenshot.png)
---
