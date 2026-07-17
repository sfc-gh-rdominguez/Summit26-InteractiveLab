# Start the Streamer

The Python streamer generates realistic arcade score events and pushes them into `ARCADE_SCORES` via the Snowpipe Streaming SDK. **Keep it running for the entire lab** — the exercises all query live data.

---

## Start

```bash
cd python
python arcade_streamer.py
```

Expected output:

```
============================================================
 Summit 2026 – Arcade Scores Snowpipe Streamer
============================================================
  Account   : YOUR_ORG-YOUR_ACCOUNT
  Database  : ARCADE_DB.PUBLIC
  Pipe      : ARCADE_SCORES-STREAMING
  Channels  : 1
  Target    : 1000 rows/sec
============================================================

  [14:22:05]  rows:      512  |  512.0 rows/sec  |  errors: 0  |  elapsed:    1s
  [14:22:05]  [latency] ARCADE_CHANNEL_0_A3F2B1C4: 540 ms avg
  [14:22:10]  rows:    1,024  |  512.0 rows/sec  |  errors: 0  |  elapsed:    6s
  [14:22:10]  [latency] ARCADE_CHANNEL_0_A3F2B1C4: 512 ms avg
```

The **latency** line reports the Snowflake-side avg processing time per channel — how long between the SDK sending a row and Snowflake committing it. Sub-second is normal and expected.

---

## Wait for cache warm-up

`SUMMIT_INT_WH` (the Interactive Warehouse) warms its local SSD cache as rows arrive. **Wait 2–3 minutes after the streamer starts** before running lab queries — the first few queries after a cold start will be slower while the cache populates.

While you wait, open **`sql/03_lab_queries.sql`** in Snowsight so it's ready to run.

---

## Streamer options

```bash
# Throttle to 50 rows/sec (useful for demos where you want to watch counts climb slowly)
python arcade_streamer.py --rate 50

# 4 parallel channels for higher throughput
python arcade_streamer.py --channels 4

# Stop automatically after 10,000 rows
python arcade_streamer.py --rows 10000

# Preview generated data without connecting to Snowflake
python arcade_streamer.py --dry-run --rows 5
```

---

## Stop the streamer

`Ctrl-C` — the script closes all channels cleanly and prints a final summary.

---

## Next

[Lab exercises →](./06-exercises.md)
