# Environment Setup: Dev Container (Local Docker)

Dev Containers run the same `.devcontainer` configuration as Codespaces but on your own machine via Docker. You get an identical Linux environment without a cloud dependency.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (running)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

---

## 1. Clone the repo and open in container

```bash
git clone https://github.com/Snowflake-Labs/Summit26-InteractiveLab.git
cd Summit26-InteractiveLab
code .
```

VS Code will detect the `.devcontainer` folder and prompt: **"Reopen in Container"** — click it. Alternatively use the command palette: `Dev Containers: Reopen in Container`.

The container builds and Python dependencies install automatically. You'll see pip output in the integrated terminal as it starts.

Verify:

```bash
pip show snowpipe-streaming
```

---

## 2. Generate the RSA key pair and network policy SQL

From the container terminal (project root):

```bash
bash sql/02_service_auth.sh
```

This captures your **host machine's** public IP (routed through Docker), generates the RSA key pair, and prints SQL to register the public key and create a network policy.

**Copy all printed SQL into Snowsight and run as `ACCOUNTADMIN`.**

> `rsa_key.p8` is in `.gitignore` and must never be committed.

---

## 3. Create `profile.json`

```bash
cp profile.json.example profile.json
```

The final SQL statement from Step 2 outputs a fully-populated JSON block. Copy its value directly into `profile.json`, or fill in manually:

```json
{
    "user":             "ARCADE_STREAMING_USER",
    "account":          "YOUR_ORG-YOUR_ACCOUNT",
    "url":              "https://YOUR_ORG-YOUR_ACCOUNT.snowflakecomputing.com:443",
    "private_key_file": "/workspaces/Summit26-InteractiveLab/rsa_key.p8",
    "role":             "ARCADE_STREAMING_ROLE"
}
```

The RSA key path inside the container is `/workspaces/Summit26-InteractiveLab/rsa_key.p8` — same as Codespaces.

---

## Network policy

The network policy is locked to your host machine's IP at the time you ran Step 2. If you change networks, re-run `bash sql/02_service_auth.sh` and paste the updated SQL into Snowsight.

---

## Next

[Snowflake setup →](./04-snowflake-setup.md)
