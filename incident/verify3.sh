#!/bin/bash
# Fixed when worker can reach redis by name.
if ! docker inspect worker >/dev/null 2>&1; then
  echo "worker container not found — run: docker compose up -d worker"
  exit 1
fi
out=$(docker exec worker redis-cli -h redis ping 2>/dev/null)
if [ "$out" = "PONG" ]; then
  echo "✓ worker reached redis (PONG) — it's now on the same network."
  exit 0
fi
echo "worker still cannot reach redis. Put it on the 'data' network too, then: docker compose up -d worker"
exit 1
