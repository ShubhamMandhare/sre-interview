# Step 1 — The headline: 502 Bad Gateway

**Symptom:** users hitting the app get a `502`.

```bash
curl -i http://localhost:8080
```{{exec}}

## Your task

Find out *why* the proxy can't reach the app, and fix it — **without** changing
the application itself. Prove the API is actually healthy before you touch any
config; isolate the proxy from the app.

Useful moves:

```bash
docker compose logs web
docker compose exec web cat /etc/nginx/conf.d/default.conf
docker compose exec api python -c "import urllib.request as u; print(u.urlopen('http://localhost:5000/').read())"
```{{exec}}

The nginx config lives on the host at `/root/sre-interview/nginx/nginx.conf`.
After editing, reload the proxy:

```bash
docker compose exec web nginx -s reload
```{{exec}}

Then re-check:

```bash
curl -i http://localhost:8080
```{{exec}}

Press **Check** when `http://localhost:8080` returns `200`.
