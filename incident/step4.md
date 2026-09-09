# Step 4 — A container keeps getting killed

**Symptom:** one container restarts repeatedly; it never finishes its work.

```bash
docker inspect aggregator --format 'OOMKilled={{.State.OOMKilled}} exit={{.State.ExitCode}} restarts={{.RestartCount}}'
docker stats --no-stream aggregator
docker compose logs aggregator | tail -5
```{{exec}}

## Your task

Recognise the signal (**exit 137 = OOMKilled**) and decide on the *right* fix,
not a lazy one. Watch the logs to see roughly how much memory the workload
actually wants, then either:

- give it a limit that genuinely fits the workload, **or**
- treat it as a memory leak / oversized allocation and right-size the app.

> Note: this host **enforces** the memory limit (unlike some laptops), so a
> limit that's still smaller than what the code allocates will keep it dying.
> Figure out the real footprint before you pick a number.

Edit `/root/sre-interview/docker-compose.yml`, then:

```bash
docker compose up -d aggregator
sleep 5
docker inspect aggregator --format 'OOMKilled={{.State.OOMKilled}} status={{.State.Status}}'
```{{exec}}

Press **Check** when `aggregator` is no longer being killed.
