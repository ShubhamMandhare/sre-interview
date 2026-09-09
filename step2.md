# Step 2 — A container won't stay up

**Symptom:** one container keeps restarting instead of running.

```bash
docker compose ps
docker compose logs notifier | tail -20
docker inspect notifier --format 'exit={{.State.ExitCode}} restarts={{.RestartCount}}'
```{{exec}}

## Your task

Read the traceback, identify the real root cause (note how `restart: always`
masks a hard failure), and fix it. Recognise what **exit code 1** means versus
137 (OOM) or 143 (SIGTERM).

The compose file is at `/root/sre-interview/docker-compose.yml`. After editing,
apply just this service:

```bash
docker compose up -d notifier
```{{exec}}

Verify it no longer errors:

```bash
docker compose logs notifier | tail -5
```{{exec}}

Press **Check** when `notifier` is no longer crashing on the missing value.
