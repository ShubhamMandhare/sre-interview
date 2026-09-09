# Incident: the application is down

You have full root access to a Docker host running a small stack: a web proxy
in front of an API backed by Redis, a monitoring stack (Prometheus + Grafana),
and some background workers.

Something is wrong — **users report the application is down.** Investigate,
explain what you find, and fix what you can. Treat it like a real incident:
state a hypothesis before you act, and separate symptoms from root cause.

## Wait for the environment to arm itself

The stack builds and starts in the background (~1–2 min on first boot):

```bash
tail -n 5 /root/setup.log
```{{exec}}

When you see `>> [setup] READY`, you can begin.

## Endpoints

Use the port tabs (or the "Traffic / Ports" menu) to open **8080** (app),
**9090** (Prometheus), and **3000** (Grafana) in your browser.

## Environment

Standard Docker tooling is available (`docker`, `docker compose`). Work through
the tasks on the left — each has a **Check** button that verifies your fix.
