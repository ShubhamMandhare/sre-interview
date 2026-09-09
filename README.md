# SRE / DevOps Incident — Killercoda scenario

A self-contained Killercoda scenario that reproduces the Docker Compose
interview environment (nginx → API → Redis + Prometheus/Grafana + workers) with
**several faults** baked in, plus a monitoring exercise. Faults are armed
automatically on boot; each step has an automatic **Check** (verify script).

## Files

| File | Purpose |
|------|---------|
| `index.json` | Scenario manifest (title, steps, verify scripts, backend image) |
| `intro.md` | Incident brief + how to wait for setup |
| `step1.md`–`step6.md` | The debugging tasks + the monitoring exercise |
| `verify1.sh`–`verify5.sh` | Auto-checks run by each step's **Check** button |
| `background.sh` | Runs at boot: generates the broken stack and `docker compose up -d --build` |
| `finish.md` | Wrap-up + prevention talking points |

Nothing is pulled from a private registry — images come from Docker Hub, which
Killercoda can reach (no corporate proxy there), so it runs unmodified.

## How to publish it on Killercoda (free creator account)

Killercoda serves scenarios from a **GitHub repo** connected to your creator
profile:

1. Push this folder to a GitHub repo, e.g. `killercoda-scenarios`, so the
   scenario lives at the repo root (or in a subfolder — each folder with an
   `index.json` is one scenario).
2. Go to <https://killercoda.com/creators> and sign in with GitHub (free).
3. **Connect your repository.** Killercoda auto-discovers scenarios from it.
4. Your scenario appears at
   `https://killercoda.com/<your-username>/scenario/<folder-name>`.
5. Edit + push to iterate; Killercoda re-syncs from the repo.

> Free-tier notes: environments are time-limited (longer sessions are a paid
> "PLUS" feature) and published scenarios are **public** — so don't add an
> answer key to the repo. There's no built-in candidate invite/scoring; run it
> live over screen-share, or point the candidate at the public URL.

## Try it locally first (optional)

The `background.sh` is just bash + docker, so you can sanity-check the stack on
any Docker host:

```bash
bash background.sh          # writes /root/sre-interview and starts the stack
cat /root/setup.log         # watch progress; wait for ">> [setup] READY"
```

(Adjust the `/root/...` paths if you're not running as root.)

## Answer key

The interviewer answer key is deliberately **not** in this folder, so it can
never be pushed to a public repo. It's kept locally alongside this scenario at:

```
../sre-interview-killercoda.ANSWER-KEY.md
```

It maps the neutral service names (`notifier`, `aggregator`, `reporter`,
`worker`) to their faults and fixes.
