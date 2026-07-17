# JMeter Concurrency Test

This optional exercise simulates 50 concurrent users querying `SUMMIT_INT_WH` and `SUMMIT_TRAD_WH` simultaneously, demonstrating how the Interactive Warehouse handles high concurrency without queuing.

**Keep the Python streamer running** during this test — the JMeter queries use a 30-minute time window and need live data to return meaningful results.

---

## Install JMeter

> **Do not use `apt-get install jmeter`** on Linux/Ubuntu — it installs version 2.13 which is incompatible with this test plan. Use the instructions below instead.

### Codespaces or Dev Container

Run the setup script from the project root:

```bash
bash scripts/install_jmeter.sh
```

This downloads JMeter 5.6.3 and the Snowflake JDBC driver, and places both where the test runner expects them.

Then activate for your terminal session:

```bash
export JMETER_HOME=/workspaces/Summit26-InteractiveLab/apache-jmeter-5.6.3
export PATH=$JMETER_HOME/bin:$PATH
```

### macOS (local)

```bash
brew install jmeter
curl -L -o snowflake-jdbc.jar \
  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.16.1/snowflake-jdbc-3.16.1.jar
cp snowflake-jdbc.jar $(brew --prefix)/Cellar/jmeter/*/libexec/lib/
cp snowflake-jdbc.jar jmeter/
```

### Windows or Linux (manual install)

Download JMeter 5.x from [jmeter.apache.org](https://jmeter.apache.org/download_jmeter.cgi) and extract it. Then:

```bash
export JMETER_HOME=/path/to/apache-jmeter-5.x.x
export PATH=$JMETER_HOME/bin:$PATH

# Download and place JDBC driver
cd jmeter
curl -L -o snowflake-jdbc.jar \
  https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.16.1/snowflake-jdbc-3.16.1.jar
cp snowflake-jdbc.jar $JMETER_HOME/lib/
cp snowflake-jdbc.jar .
```

---

## Set environment variables

```bash
export SNOWFLAKE_ACCOUNT=YOUR_ORG-YOUR_ACCOUNT

# Codespaces / Dev Container:
export SNOWFLAKE_PRIVATE_KEY_FILE=/workspaces/Summit26-InteractiveLab/rsa_key.p8

# Local (use the absolute path printed by 02_service_auth.sh):
# export SNOWFLAKE_PRIVATE_KEY_FILE=/absolute/path/to/rsa_key.p8
```

---

## Run the test

The test runner must be run from inside the `jmeter/` directory:

```bash
cd jmeter
./run_concurrency_test.sh SUMMIT_INT_WH
```

The script runs 50 concurrent threads for 30 seconds, executes 5 different queries randomly across threads, and generates an HTML report in `results_SUMMIT_INT_WH_TIMESTAMP/`.

Then run against the standard warehouse for comparison:

```bash
./run_concurrency_test.sh SUMMIT_TRAD_WH
```

---

## Read the results

```bash
# Quick summary in terminal
cat results_SUMMIT_INT_WH_*/statistics.json

# Full HTML report (macOS)
open results_SUMMIT_INT_WH_*/index.html
```

### Expected results

| Metric | `SUMMIT_INT_WH` | `SUMMIT_TRAD_WH` |
|---|---|---|
| Avg latency | Sub-second | Several seconds |
| Min latency | Sub-second | 1+ seconds |
| Throughput | Higher | Lower |
| Concurrency | Smooth | Queuing under load |

---

## Customise the test

Edit `jmeter/concurrency_test.jmx` to adjust:
- Thread count: `ThreadGroup.num_threads` (default 50)
- Duration: `ThreadGroup.duration` (default 30 seconds)
- Queries: add or modify `JDBCSampler` elements

---

## Troubleshooting

**Connection errors:** Verify `SNOWFLAKE_PRIVATE_KEY_FILE` is an absolute path and the RSA public key is registered on `ARCADE_STREAMING_USER` (re-run `bash sql/02_service_auth.sh` and paste the SQL if unsure).

**`Unknown option -e`:** You have an old JMeter (apt-installed 2.13). Follow the install instructions above to get JMeter 5.x.

**No data returned:** Ensure the Python streamer is still running (`python python/arcade_streamer.py`) and the table has rows (`SELECT COUNT(*) FROM ARCADE_DB.PUBLIC.ARCADE_SCORES`).
