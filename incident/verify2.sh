#!/bin/bash
# Fixed when notifier has the required env var and is no longer KeyError-ing.
if ! docker inspect notifier >/dev/null 2>&1; then
  echo "notifier container not found — run: docker compose up -d notifier"
  exit 1
fi
if docker inspect notifier --format '{{json .Config.Env}}' 2>/dev/null | grep -q 'API_TOKEN='; then
  if docker logs notifier 2>&1 | tail -8 | grep -q 'KeyError'; then
    echo "API_TOKEN is set but the running container still shows KeyError — recreate it: docker compose up -d notifier"
    exit 1
  fi
  echo "✓ notifier has API_TOKEN and is no longer crashing on the missing variable."
  exit 0
fi
echo "notifier still has no API_TOKEN. Provide it in docker-compose.yml, then: docker compose up -d notifier"
exit 1
