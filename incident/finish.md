# Nicely done

You worked through a realistic incident across five independent faults plus a
monitoring exercise:

1. **502 / nginx** — proxy pointed at the wrong upstream port.
2. **Crash loop** — a missing environment variable (`exit 1`, masked by
   `restart: always`).
3. **Networking** — a container on the wrong Docker network; per-network DNS.
4. **OOMKilled** — a memory limit that didn't fit the workload (`exit 137`).
5. **Disk** — a runaway writer filling a mounted volume.

## The question that matters most

> "You've stabilised it. What would you change so none of this happens again?"

Strong answers mention: **health checks** + `depends_on: condition:
service_healthy`, right-sizing resource requests/limits, **centralised logging**
and **log rotation**, **alerting thresholds** (disk, latency SLOs, restart
counts), network-policy hygiene, CI checks on compose/manifests, and runbooks.

Thanks for playing incident commander. 🚒
