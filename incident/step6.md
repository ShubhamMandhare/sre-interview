# Step 6 — Monitoring: high latency, but CPU/memory look fine

Now that the app is up, use the metrics to reason about a performance problem.
The API exposes Prometheus metrics at `api:5000/metrics`; Prometheus scrapes
every 5s.

Generate some slow traffic (the `/slow` endpoint sleeps 8s):

```bash
docker compose exec api python -c "
import urllib.request as u, threading
def hit(p):
    try: u.urlopen('http://localhost:5000'+p, timeout=30).read()
    except Exception: pass
ts=[threading.Thread(target=hit,args=('/slow',)) for _ in range(3)]
[t.start() for t in ts]
for _ in range(15): hit('/')
[t.join() for t in ts]
print('traffic done')
"
```{{exec}}

Open **Prometheus** (port **9090**) and try:

```promql
sum(rate(app_requests_total[1m]))
```

```promql
histogram_quantile(0.95, sum(rate(app_request_latency_seconds_bucket[5m])) by (le))
```

Then break p95 down **by endpoint** to find the culprit:

```promql
histogram_quantile(0.95, sum(rate(app_request_latency_seconds_bucket[5m])) by (le, endpoint))
```

## Talk through it

- Which of the **golden signals** (latency, traffic, errors, saturation) is
  actually degraded here?
- Overall p95 looks alarming — but is the *system* saturated, or is one
  endpoint dragging the aggregate up?
- What alert would you add so this is caught automatically next time?

There's no automatic check on this step — it's a discussion. Press **Next**
when you're done.
