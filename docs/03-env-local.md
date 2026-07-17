# Environment Setup: Local (macOS / Windows / Linux)

Running natively on your laptop. Setup effort varies by OS.

---

## macOS

### Prerequisites

```bash
# Python 3.9–3.13 (if not already installed)
brew install python@3.12

# OpenSSL and curl are included with macOS — no action needed
```

### Install Python dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Verify:

```bash
pip show snowpipe-streaming
```

---

## Windows

### Prerequisites

- **Python 3.9–3.13** — install from [python.org](https://www.python.org/downloads/). Check "Add Python to PATH" during install.
- **OpenSSL** — install via [Win32/Win64 OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) (the "Light" installer is sufficient), or use [Git for Windows](https://git-scm.com/download/win) which bundles it.
- **curl** — included with Windows 10 1803+ and Git for Windows.
- **Git Bash** — required to run the `.sh` scripts (`sql/02_service_auth.sh`, `scripts/install_jmeter.sh`). Included with Git for Windows.

### Install Python dependencies

In Git Bash or PowerShell:

```bash
python -m venv .venv
.venv\Scripts\activate      # PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Run shell scripts

Use Git Bash for any `.sh` scripts:

```bash
bash sql/02_service_auth.sh
```

---

## Linux

### Prerequisites

Most distributions include Python 3, OpenSSL, and curl. Verify:

```bash
python3 --version   # needs 3.9–3.13
openssl version
curl --version
```

Install if missing (Debian/Ubuntu):

```bash
sudo apt-get update && sudo apt-get install -y python3 python3-pip python3-venv openssl curl
```

> **JMeter note:** `apt-get install jmeter` installs version 2.13, which is too old for the concurrency test. Use `scripts/install_jmeter.sh` instead — see [JMeter setup](./07-jmeter.md).

### Install Python dependencies

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## All platforms: generate RSA key pair and network policy SQL

From the project root (Git Bash on Windows, terminal on macOS/Linux):

```bash
bash sql/02_service_auth.sh
```

This captures your machine's current public IP, generates `rsa_key.p8` / `rsa_key.pub`, and prints SQL to register the public key and create a network policy for the service account.

**Copy all printed SQL into Snowsight and run as `ACCOUNTADMIN`.**

> `rsa_key.p8` is in `.gitignore` and must never be committed.

---

## Create `profile.json`

```bash
cp profile.json.example profile.json
```

Fill in your account details. The last SQL statement from `02_service_auth.sh` prints a fully-populated JSON block you can paste directly. The `private_key_file` must be an **absolute path**:

```json
{
    "user":             "ARCADE_STREAMING_USER",
    "account":          "YOUR_ORG-YOUR_ACCOUNT",
    "url":              "https://YOUR_ORG-YOUR_ACCOUNT.snowflakecomputing.com:443",
    "private_key_file": "/absolute/path/to/rsa_key.p8",
    "role":             "ARCADE_STREAMING_ROLE"
}
```

The script prints the exact absolute path — copy it from there.

---

## Network policy warning

The network policy is locked to your IP at the time you ran `02_service_auth.sh`. **At a conference or on venue WiFi this IP can change.** If the Python streamer suddenly gets connection errors, re-run the script and paste the updated SQL into Snowsight.

---

## Next

[Snowflake setup →](./04-snowflake-setup.md)
