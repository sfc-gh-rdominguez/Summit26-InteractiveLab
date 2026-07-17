# Environment Setup: GitHub Codespaces

GitHub Codespaces gives you a pre-configured Linux container in the browser — Python 3.12, OpenSSL, and `curl` are all pre-installed, and the Snowpipe Streaming SDK installs automatically when the Codespace starts.

---

## 1. Open the repo in Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Snowflake-Labs/Summit26-InteractiveLab)

Or from the repo page: **Code → Codespaces → Create codespace on main**.

The container will build and install Python dependencies automatically. You'll see pip output in the terminal as it starts — wait for it to finish before continuing.

Verify the SDK is installed:

```bash
pip show snowpipe-streaming
```

---

## 2. Generate the RSA key pair and network policy SQL

Run this from the Codespace terminal (project root):

```bash
bash sql/02_service_auth.sh
```

The script:
- Generates `rsa_key.p8` and `rsa_key.pub` in the project root
- Detects the Codespace's current egress IP
- Prints SQL to register the public key and lock the service account to that IP range

**Copy all the printed SQL and paste it into Snowsight, then run it as `ACCOUNTADMIN`.**

> `rsa_key.p8` is in `.gitignore` and must never be committed.

---

## 3. Create `profile.json`

```bash
cp profile.json.example profile.json
```

The final SQL statement printed in Step 2 outputs a fully-populated JSON block. Copy its value directly into `profile.json`, or fill in manually:

```json
{
    "user":             "ARCADE_STREAMING_USER",
    "account":          "YOUR_ORG-YOUR_ACCOUNT",
    "url":              "https://YOUR_ORG-YOUR_ACCOUNT.snowflakecomputing.com:443",
    "private_key_file": "/workspaces/Summit26-InteractiveLab/rsa_key.p8",
    "role":             "ARCADE_STREAMING_ROLE"
}
```

The RSA key path in Codespaces is always `/workspaces/Summit26-InteractiveLab/rsa_key.p8`.

---

## Network policy

The network policy created in Step 2 is scoped to your Codespace's egress IP. If you stop and restart the Codespace and the IP changes, re-run `bash sql/02_service_auth.sh` and paste the updated SQL into Snowsight.

---

## Next

[Snowflake setup →](./04-snowflake-setup.md)
