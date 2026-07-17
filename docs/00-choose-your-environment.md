# Choose Your Environment

The Python streamer runs on your local machine (or a cloud workspace) and connects to Snowflake via the Snowpipe Streaming SDK. Choose the environment that fits your setup before continuing.

---

## Options at a glance

| | Codespaces | Dev Container | Local |
|---|---|---|---|
| **Setup effort** | Minimal | Low (need Docker) | Varies by OS |
| **Python deps** | Auto-installed | Auto-installed | Manual venv |
| **OpenSSL / curl** | Pre-installed | Pre-installed | Usually present |
| **JMeter** | Script provided | Script provided | Manual install |
| **Network policy** | Stable egress IP | Your machine's IP | Your machine's IP — can shift on venue WiFi |
| **Works offline** | No | Yes | Yes |

---

## Which should I pick?

**Use Codespaces if:**
- You don't want to install anything locally
- You're on venue / conference WiFi and don't want dependency issues
- You just want to follow the lab without worrying about your machine's setup

**Use Dev Container if:**
- You have Docker Desktop and VS Code installed
- You want the same clean environment as Codespaces but running locally
- You're on a network where Codespaces outbound connections are restricted

**Use Local if:**
- You already have Python 3.9–3.13, OpenSSL, and curl set up
- You prefer working directly in your own terminal
- You're comfortable managing a venv and troubleshooting OS-specific issues

---

## Network policy note

`sql/02_service_auth.sh` captures your current public IP and creates a Snowflake network policy that locks the streaming service account to that IP range. This works reliably in Codespaces and Dev Containers. On a local machine — especially at a conference — your IP can change when you switch networks or reconnect to WiFi. If the streamer suddenly gets connection errors, re-run `bash sql/02_service_auth.sh` and paste the updated SQL into Snowsight.

---

## Continue

- [Codespaces setup →](./01-env-codespaces.md)
- [Dev Container setup →](./02-env-devcontainer.md)
- [Local setup →](./03-env-local.md)
