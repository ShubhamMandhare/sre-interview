#!/bin/bash
# Fixed when aggregator is no longer being OOM-killed.
if ! docker inspect aggregator >/dev/null 2>&1; then
  echo "aggregator container not found — run: docker compose up -d aggregator"
  exit 1
fi
oom=$(docker inspect aggregator --format '{{.State.OOMKilled}}' 2>/dev/null)
limit=$(docker inspect aggregator --format '{{.HostConfig.Memory}}' 2>/dev/null)
if [ "$oom" = "false" ] && [ "$limit" != "134217728" ]; then
  echo "✓ aggregator is not OOM-killed and the 128m limit has been changed."
  exit 0
fi
if [ "$limit" = "134217728" ]; then
  echo "aggregator is still capped at 128m. Right-size the limit to the workload (or fix the allocation), then: docker compose up -d aggregator"
else
  echo "aggregator is still being OOM-killed — the limit is smaller than what it allocates. Give it a limit that fits, then: docker compose up -d aggregator"
fi
exit 1
