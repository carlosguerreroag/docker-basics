### 🛞 Traefik Sticky Sessions
---
**Goal:** configure Traefik to maintain sticky sessions using cookies, ensuring that a client's requests are consistently routed to the same backend container across multiple requests, even when multiple replicas are running.

### 👉 Demonstration
By running the commands:

```bash
docker compose up -d
```

The `docker-compose.yaml` starts Traefik alongside two replicas of `ealen/echo-server` (`web1` and `web2`). Each service has sticky cookies enabled via the labels `loadbalancer.sticky.cookie=true`, `httpOnly=true`, and a custom cookie name (`web1_sticky_cookie` for web1, `web2_sticky_cookie` for web2).

**Test 1: Round-robin without cookies**

```bash
curl -s http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"

curl -s http://web1.localhost | jq '.environment.HOSTNAME'
# "4d574b3f5d9c"

curl -s http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"
```

**Observation:** Without cookies, requests are load-balanced in round-robin across both containers.

**Test 2: Sticky session with cookies**

```bash
curl -s -c cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"

cat cookie.txt
# #HttpOnly_web1.localhost	FALSE	/	FALSE	0	web1_sticky_cookie	eb1093fcef236d48

curl -s -b cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"

curl -s -b cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"

curl -s -b cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "ef4e710eb5cb"
```

**Observation:** The `-c` flag saves the cookie, and `-b` sends it with subsequent requests. All requests with the cookie are routed to the same container (`ef4e710eb5cb`), demonstrating session stickiness.

**Test 3: Failover when sticky backend is stopped**

```bash
docker stop ef4e710eb5cb
# ef4e710eb5cb

curl -s -b cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "4d574b3f5d9c"

curl -s -b cookie.txt http://web1.localhost | jq '.environment.HOSTNAME'
# "4d574b3f5d9c"
```

**Observation:** When the sticky container is stopped, Traefik automatically routes the request to the remaining healthy replica, even though the cookie still points to the stopped container. This shows that sticky sessions gracefully handle backend failures.

---
