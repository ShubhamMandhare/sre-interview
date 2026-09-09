# Task 6 — Performance

With the app healthy, users report it sometimes feels slow — even though CPU and
memory look fine. The API exposes Prometheus metrics; **Prometheus** (9090) and
**Grafana** (3000) are available.

Generate some traffic to work with:

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
"
```{{exec}}

Using the metrics, explain what's happening and where the problem is. Be ready
to discuss how you'd quantify it and what alerting you'd put in place.

(No automatic check on this task — it's a discussion.)
