# Users report the application is down

You have full root access to a Docker host running a small stack:

- **nginx** (reverse proxy, published on port **8080**) → **API** (Flask) → **Redis**
- A monitoring stack: **Prometheus** (9090) + **Grafana** (3000)
- A few background workers

**Several things are broken.** Your job is to investigate, explain what you
find, and fix what you can. Treat it like a real incident: state a hypothesis
before you run a command, and separate *symptoms* from *root cause*.

---

## ⏳ First: wait for the environment to arm itself

The stack is being built and started in the background (it pulls images and
builds the API — roughly **1–2 minutes** on first boot). Check progress:

```bash
tail -n 20 /root/setup.log
```{{exec}}

When you see `>> [setup] READY`, you're good to go. Then:

```bash
cd /root/sre-interview
docker compose ps
```{{exec}}

A couple of containers showing **Restarting** is expected — that's part of the
incident.

## Handy starting points

```bash
docker compose ps
docker compose logs <service>
docker stats --no-stream
docker inspect <container>
docker compose exec <service> sh
```{{exec}}

## Viewing the web endpoints

Use the **port tabs** at the top of the terminal (or the "Traffic / Ports"
menu) to open **8080** (app), **9090** (Prometheus), and **3000** (Grafana)
in your browser.

Work through the steps on the left. Each has a **Check** button that verifies
your fix.
