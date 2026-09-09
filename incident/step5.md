# Step 5 — Disk is filling up

**Symptom:** disk usage on the host keeps climbing.

```bash
df -h /
du -sh /root/sre-interview/data/* 2>/dev/null | sort -h
find /root/sre-interview/data -type f -size +50M
```{{exec}}

## Your task

Do a systematic `df` → `du` → `find` drill-down to locate what's growing and,
crucially, **which container is writing it**. Then reclaim the space and stop
the bleeding — don't just delete files at random.

Useful moves:

```bash
docker compose logs reporter | tail -5
docker system df
```{{exec}}

Reclaim + stop the writer, e.g.:

```bash
docker compose stop reporter
rm -f /root/sre-interview/data/logs/archive.bin
: > /root/sre-interview/data/logs/app.log
du -sh /root/sre-interview/data/logs
```{{exec}}

Bonus discussion: log rotation (`logrotate`, Docker `--log-opt max-size`),
retention, and alerting on disk **before** it hits 100%.

Press **Check** when the runaway data is reclaimed.
