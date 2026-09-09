#!/bin/bash
# Fixed when worker can reach redis by name.
if ! docker inspect worker >/dev/null 2>&1; then
  echo "worker container not found — run: docker compose up -d worker"
  exit 1
fi
# Match PONG loosely (docker exec output can carry a trailing CR/whitespace).
if docker exec worker redis-cli -h redis ping 2>/dev/null | grep -q PONG; then
  echo "✓ worker reached redis (PONG) — it's now on the same network."
  exit 0
fi
# Fallback: the worker pings redis every 5s; accept a recent PONG in its logs.
if docker logs worker 2>&1 | tail -5 | grep -q PONG; then
  echo "✓ worker is reaching redis (PONG in recent logs)."
  exit 0
fi
echo "worker still cannot reach redis. Put it on the 'data' network too, then: docker compose up -d worker"
exit 1
