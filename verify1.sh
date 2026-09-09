#!/bin/bash
# Fixed when the app returns HTTP 200 through nginx.
code=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 2>/dev/null || echo 000)
if [ "$code" = "200" ]; then
  echo "✓ http://localhost:8080 returns 200 — proxy is reaching the API."
  exit 0
fi
echo "Still getting HTTP $code. Check the nginx upstream port (API listens on 5000) and reload web."
exit 1
