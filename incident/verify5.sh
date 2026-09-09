#!/bin/bash
# Fixed when the runaway data under data/logs is reclaimed (< 50 MB).
LOGS=/root/sre-interview/data/logs
if [ ! -d "$LOGS" ]; then
  echo "✓ data/logs no longer present — space reclaimed."
  exit 0
fi
sz=$(du -sm "$LOGS" 2>/dev/null | awk '{print $1}')
[ -z "$sz" ] && sz=0
if [ "$sz" -lt 50 ]; then
  echo "✓ data/logs is down to ${sz} MB — runaway data reclaimed."
  exit 0
fi
echo "data/logs is still ${sz} MB. Stop the writer (reporter), remove archive.bin, and truncate app.log."
exit 1
