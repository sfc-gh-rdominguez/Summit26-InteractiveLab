# Snowflake Setup

Run these steps once, regardless of your environment. You need a Snowflake account in a [supported region](https://docs.snowflake.com/en/user-guide/interactive#region-availability) and `ACCOUNTADMIN` (or `CREATE WAREHOUSE` + `CREATE DATABASE`) privileges.

---

## 1. Run the provisioning script

Open **`sql/01_setup.sql`** in Snowsight and run it using a standard warehouse session.

The script provisions:

1. `ARCADE_STREAMING_ROLE` + `ARCADE_STREAMING_USER` (service account) + keypair auth policy
2. `ARCADE_DB` database + `PUBLIC` schema + `SUMMIT_TRAD_WH` standard warehouse
3. `ARCADE_SCORES` **Interactive Table** — `CLUSTER BY (GAME_ENDED_AT)`, initially empty
4. `SUMMIT_INT_WH` **Interactive Warehouse** (XS, always-on)
5. `ARCADE_REPORTING_POOL` compute pool (XS, for the optional Streamlit dashboard)
6. Grants for `ARCADE_STREAMING_ROLE` and `ARCADE_LAB_READER`

**Why two warehouses?** `SUMMIT_INT_WH` is an Interactive Warehouse — optimised for sub-second query latency on Interactive Tables using local SSD caching and pre-computed index metadata. `SUMMIT_TRAD_WH` is a standard warehouse used as the comparison baseline in Exercise 10. Snowpipe Streaming does not consume warehouse credits at all — data is ingested via the SDK channel API directly into the table.

---

## 2. Register the RSA public key and network policy

> If you already completed this step during environment setup (Codespaces or Dev Container docs), skip to Step 3.

From your terminal in the project root:

```bash
bash sql/02_service_auth.sh
```

Copy all printed SQL into Snowsight and run as `ACCOUNTADMIN`. This registers the RSA public key on `ARCADE_STREAMING_USER` and creates a network policy (`GH_WORKSPACE_POLICY`) that restricts the service account to your current IP range.

---

## 3. Verify setup

Back in Snowsight, run:

```sql
SHOW INTERACTIVE TABLES IN SCHEMA ARCADE_DB.PUBLIC;
SHOW WAREHOUSES LIKE 'SUMMIT%';
```

You should see `ARCADE_SCORES` in the first result and both `SUMMIT_INT_WH` and `SUMMIT_TRAD_WH` in the second.

---

## Next

[Start the streamer →](./05-start-streaming.md)
