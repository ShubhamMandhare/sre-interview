#!/bin/bash
# ---------------------------------------------------------------------------
# Killercoda setup: generate the (deliberately BROKEN) stack and arm it.
# Runs once at environment boot. Generates the app and starts it.
# Progress is logged to /root/setup.log ; completion marker /root/.setup-done
# ---------------------------------------------------------------------------
set -e
exec > /root/setup.log 2>&1
echo ">> [setup] starting $(date)"

APP=/root/sre-interview
mkdir -p "$APP/nginx" "$APP/backend" "$APP/monitoring/grafana" "$APP/data/logs"

# ---- docker-compose.yml ----------------------------------------------------
cat > "$APP/docker-compose.yml" <<'YAML'
name: sre-interview

services:

  web:
    image: nginx:alpine
    container_name: web
    ports:
      - "8080:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - api
    networks:
      - web
    restart: unless-stopped

  api:
    build: ./backend
    container_name: api
    environment:
      SECRET_KEY: "interview-secret"
      REDIS_HOST: "redis"
    expose:
      - "5000"
    networks:
      - web
      - data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: redis
    networks:
      - data
    restart: unless-stopped

  notifier:
    image: python:3.11-slim
    container_name: notifier
    command:
      - python
      - -c
      - |
        import os, time
        print("worker booting...", flush=True)
        time.sleep(1)
        token = os.environ["API_TOKEN"]
        print("worker started with token", token, flush=True)
    restart: always
    networks:
      - web

  worker:
    image: redis:7-alpine
    container_name: worker
    command:
      - sh
      - -c
      - |
        while true; do
          echo "worker: pinging redis..."
          redis-cli -h redis -p 6379 ping || echo "worker: FAILED to reach redis"
          sleep 5
        done
    networks:
      - web
    restart: unless-stopped

  aggregator:
    image: python:3.11-slim
    container_name: aggregator
    command:
      - python
      - -c
      - |
        import time
        print("allocating memory...", flush=True)
        buf = []
        for i in range(200):
            buf.append(bytearray(10 * 1024 * 1024))
            print("allocated", (i + 1) * 10, "MB", flush=True)
            time.sleep(0.2)
    mem_limit: 128m
    restart: always
    networks:
      - web

  reporter:
    image: alpine:3.19
    container_name: reporter
    command:
      - sh
      - -c
      - |
        mkdir -p /data/logs
        [ -f /data/logs/archive.bin ] || dd if=/dev/zero of=/data/logs/archive.bin bs=1M count=300 2>/dev/null
        while true; do
          echo "$$(date) INFO processing batch $$RANDOM" >> /data/logs/app.log
          sleep 1
        done
    volumes:
      - ./data:/data
    networks:
      - web
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    networks:
      - web
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: "admin"
      GF_AUTH_ANONYMOUS_ENABLED: "true"
      GF_AUTH_ANONYMOUS_ORG_ROLE: "Admin"
    volumes:
      - ./monitoring/grafana/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml:ro
    depends_on:
      - prometheus
    networks:
      - web
    restart: unless-stopped

networks:
  web:
  data:
YAML

# ---- nginx.conf -----------------------------------------------------------
cat > "$APP/nginx/nginx.conf" <<'NGINX'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://api:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /health {
        proxy_pass http://api:8000/health;
    }
}
NGINX

# ---- backend/Dockerfile ---------------------------------------------------
cat > "$APP/backend/Dockerfile" <<'DOCKER'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
DOCKER

# ---- backend/app.py (healthy service) -------------------------------------
cat > "$APP/backend/app.py" <<'PY'
import os
import time

import redis
from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

SECRET_KEY = os.environ["SECRET_KEY"]

REDIS_HOST = os.environ.get("REDIS_HOST", "redis")

app = Flask(__name__)
cache = redis.Redis(host=REDIS_HOST, port=6379, socket_connect_timeout=2)

REQUESTS = Counter("app_requests_total", "Total HTTP requests", ["endpoint"])
LATENCY = Histogram("app_request_latency_seconds", "Request latency", ["endpoint"])


@app.route("/")
def index():
    with LATENCY.labels("/").time():
        REQUESTS.labels("/").inc()
        try:
            hits = cache.incr("hits")
        except Exception as exc:  # noqa: BLE001
            return jsonify(error="cannot reach redis", detail=str(exc)), 500
        return jsonify(message="Hello from the API", hits=hits)


@app.route("/health")
def health():
    REQUESTS.labels("/health").inc()
    try:
        cache.ping()
        return jsonify(status="ok", redis="connected")
    except Exception as exc:  # noqa: BLE001
        return jsonify(status="degraded", redis=str(exc)), 500


@app.route("/slow")
def slow():
    with LATENCY.labels("/slow").time():
        REQUESTS.labels("/slow").inc()
        time.sleep(8)
        return jsonify(message="that took a while")


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PY

# ---- backend/requirements.txt ---------------------------------------------
cat > "$APP/backend/requirements.txt" <<'REQ'
flask==3.0.3
redis==5.0.8
prometheus-client==0.20.0
REQ

# ---- monitoring/prometheus.yml --------------------------------------------
cat > "$APP/monitoring/prometheus.yml" <<'PROM'
global:
  scrape_interval: 5s
  evaluation_interval: 5s

scrape_configs:
  - job_name: "api"
    metrics_path: /metrics
    static_configs:
      - targets: ["api:5000"]

  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
PROM

# ---- monitoring/grafana/datasource.yml ------------------------------------
cat > "$APP/monitoring/grafana/datasource.yml" <<'DS'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
DS

# ---- make sure Docker + compose are available -----------------------------
echo ">> [setup] waiting for docker daemon..."
for i in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done

COMPOSE="docker compose"
if ! docker compose version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then COMPOSE="docker-compose"; fi
fi
echo ">> [setup] using: $COMPOSE"

# ---- arm the stack --------------------------------------------------------
cd "$APP"
echo ">> [setup] building + starting (pulls from Docker Hub, ~1-2 min)..."
$COMPOSE up -d --build

echo ">> [setup] done $(date)"
$COMPOSE ps
touch /root/.setup-done
echo ">> [setup] READY"
