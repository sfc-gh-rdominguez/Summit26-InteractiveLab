# Lab Exercises

All queries are in **`sql/03_lab_queries.sql`** — open it in Snowsight while the streamer is running. Each `USE WAREHOUSE` statement is already in the file; just run the block for each exercise.

> ⚡ = run on `SUMMIT_INT_WH` (Interactive Warehouse)
> 🔧 = run on `SUMMIT_TRAD_WH` (Standard Warehouse)

---

## ⚡ Exercise 1 — Pipeline throughput

**What to run:** Queries 1a, 1b, 1c in sequence. Re-run them every 30 seconds.

**What to look for:**
- `TOTAL_SCORES` climbs steadily — roughly 1,000 rows added every second
- `ROWS_PER_SECOND` in 1b should match the streamer console's throughput line
- The 10-second bucket chart (1c) shows a uniform staircase — consistent ingest with no gaps

**Why it matters:** The Snowpipe Streaming SDK writes via the channel API, not SQL DML. There's no intermediate staging table and no warehouse consumed during ingest — rows land directly in the Interactive Table.

---

## ⚡ Exercise 2 — Data freshness

**What to run:** The freshness query.

**What to look for:**
- `FRESHNESS_SEC` should be **under 2 seconds**, often under 1
- `LATEST_GAME_ENDED` should be within the last second or two of wall-clock time

**Why it matters:** `GAME_ENDED_AT` is the client-side timestamp set by the generator at the moment the score is produced. Freshness measures the end-to-end lag from event generation to Snowflake query visibility — this is what "sub-second latency" means in practice.

---

## ⚡ Exercise 3 — Global leaderboard

**What to run:** The leaderboard query.

**What to look for:**
- Results in **under 1 second** despite the table having hundreds of thousands of rows
- Top scores dominated by `legendary` tier players (very high scores, high `LEVEL_REACHED`)
- `ACHIEVEMENT` column: rare badges like `Perfect Run` or `Legendary` appear at the top

**Why it matters:** The `CLUSTER BY (GAME_ENDED_AT)` clustering key lets the Interactive Warehouse skip all micro-partitions outside the 24-hour window. Even at millions of rows, it only scans the relevant partitions.

---

## ⚡ Exercise 4 — Per-game top 5

**What to run:** The window function query.

**What to look for:**
- 5 rows per game, ranked by score descending within the last hour
- `QUALIFY ROW_NUMBER() ... <= 5` filters without a subquery — clean syntax
- Results still sub-second

**Why it matters:** Window functions with `QUALIFY` are a pattern worth highlighting — they're more readable than `ROW_NUMBER() in a subquery` and the Interactive Warehouse handles them efficiently within its 5-second timeout.

---

## ⚡ Exercise 5 — Country heat map

**What to run:** The country aggregation query.

**What to look for:**
- Japan and South Korea near the top — the generator weights them heavily (weight 6.0 each vs 1.0–4.0 for others)
- USA accumulates across many cities (San Francisco, New York, Seattle, etc.) and may overtake individual Asian cities in total count
- `UNIQUE_PLAYERS` stays well below `GAMES_PLAYED` — the 500-player pool plays many sessions

**Why it matters:** The data model is intentionally realistic — it's not uniform random. This makes aggregate queries more interesting to interpret.

---

## ⚡ Exercise 6 — Game popularity

**What to run:** The game stats query.

**What to look for:**
- Pac-Man and Tetris dominate `SESSIONS` — popularity weights are 5.0 and 4.5 vs 0.6–0.8 for Joust and Tron
- `AVG_GAME_MIN` reflects realistic play times: Street Fighter II and Time Crisis average ~10 minutes, Tetris ~1.5 minutes
- High `HIGH_SCORE` values come from legendary-tier players hitting near-max scores

---

## ⚡ Exercise 7 — Platform breakdown

**What to run:** The platform query.

**What to look for:**
- `arcade` dominates for classic titles, `mobile` for Tetris (which has a 53% mobile weight)
- `AVG_ACCURACY_PCT` is `NULL` for some platforms — `ACCURACY_PCT` is nullable in the schema and only applies to certain game/platform combos

---

## ⚡ Exercise 8 — Live score feed

**What to run:** Re-run this query every few seconds.

**What to look for:**
- Each run returns different rows — the `GAME_ENDED_AT >= DATEADD('minute', -5, ...)` window rolls forward with wall time
- `GAME_ENDED_AT` timestamps in the results should be within the last 30–60 seconds
- Achievements appear occasionally — they're rare by design

**Why it matters:** This is the most concrete demonstration of end-to-end freshness. Data generated seconds ago is already queryable.

---

## 🔧 Exercise 9 — Achievement rarity

**What to run:** The achievement query (switch to `SUMMIT_TRAD_WH` — the query has no tight time filter so it may exceed the Interactive Warehouse's 5-second timeout on large tables).

**What to look for:**
- `Pacifist` and `Triple Threat` at the bottom — they're marked `legendary` rarity in the generator and require very specific conditions (high skill tier + specific game mode + near-perfect stats)
- `Insert Coin` near the top — it's `common` rarity (bottom 1% scorer, ironic badge)
- `UNIQUE_EARNERS` vs `TIMES_EARNED` ratio: some badges are earned repeatedly by the same players (skill-dependent), others are more spread

---

## ⚡ Exercise 10 — Interactive vs Traditional warehouse comparison

**What to run:** Step A (Interactive), then Step B (Traditional). Then open Query History in Snowsight to compare execution times side by side.

**What to look for:**
- `SUMMIT_INT_WH`: typically **under 200ms**
- `SUMMIT_TRAD_WH`: typically **1–4 seconds** on a cold cache, depending on table size
- The query is identical — the difference is entirely the warehouse type

**Why it matters:** The Interactive Warehouse uses pre-computed index metadata aligned to the clustering key. At high concurrency (Exercise 11), this gap widens further because the Interactive Warehouse serves from shared SSD cache without re-reading S3.

---

## ⚡ Exercise 11 — Concurrency demo

Run the JMeter load test to simulate 50 concurrent users. See [JMeter setup](./07-jmeter.md) for instructions, then return here.

After running against both warehouses, compare:

| Metric | `SUMMIT_INT_WH` | `SUMMIT_TRAD_WH` |
|---|---|---|
| Throughput | Higher | Lower |
| Avg latency | Sub-second | Several seconds |
| Concurrency behaviour | Smooth — shared SSD cache | Queuing under load |

---

## Bonus exercises

### 🥚 Bonus A — Time Travel

```sql
-- Row count 5 minutes ago
SELECT COUNT(*) AS ROWS_5_MIN_AGO FROM ARCADE_SCORES AT(OFFSET => -300);

-- Rows generated in the last 5 minutes
SELECT COUNT(*) AS NEW_ROWS
FROM ARCADE_SCORES
WHERE GAME_ENDED_AT >= DATEADD('minute', -5,
      CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ);
```

Interactive Tables support Time Travel even with active streaming ingestion. The difference between the two counts shows how many rows the streamer added in 5 minutes.

### ⚡ Bonus B — Rolling city hotspot

Re-run every minute. The top cities shift as the 1-minute window rolls. Tokyo and Seoul dominate but you'll see other cities spike occasionally.

### 🥚 Bonus C — Find the ghost player

One synthetic player logs perfect scores with the badge `Summit 2026`. Run query D1 to find the rarest achievements, then D2 to see every ghost session. The ghost is injected at roughly 1 in every 100,000 rows — leave the streamer running if counts are 0.

### 🔧 Bonus D — Interactive Table metadata

```sql
USE WAREHOUSE SUMMIT_TRAD_WH;
SHOW INTERACTIVE TABLES IN SCHEMA ARCADE_DB.PUBLIC;
SELECT SYSTEM$CLUSTERING_INFORMATION('ARCADE_DB.PUBLIC.ARCADE_SCORES', '(GAME_ENDED_AT)');
```

`SYSTEM$CLUSTERING_INFORMATION` shows the clustering depth — lower means better-clustered partitions and faster partition pruning on time-range queries.

---

## Next (optional)

- [JMeter concurrency test →](./07-jmeter.md)
- [Streamlit dashboard →](../STREAMLIT.md)
