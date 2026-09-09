# Step 3 — The `worker` can't reach Redis

**Symptom:** `worker` logs a connection failure to Redis every 5 seconds.

```bash
docker compose logs worker | tail -5
```{{exec}}

## Your task

Redis is up and other services use it fine — so why can't `worker`? Investigate
how the containers are wired together and fix the connectivity **without**
publishing Redis to the host.

Useful moves:

```bash
docker inspect worker --format '{{json .NetworkSettings.Networks}}'
docker inspect redis  --format '{{json .NetworkSettings.Networks}}'
docker compose exec worker sh -c "getent hosts redis || echo 'name does not resolve'"
```{{exec}}

Edit `/root/sre-interview/docker-compose.yml`, then:

```bash
docker compose up -d worker
docker compose exec worker redis-cli -h redis ping
```{{exec}}

Press **Check** when `worker` can reach Redis (`PONG`).
