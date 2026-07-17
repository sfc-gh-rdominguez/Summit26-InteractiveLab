-- =============================================================================
-- Generate a Programmatic Access Token (PAT) for the current user and output
-- the snow connection add command to register it with the Snowflake CLI.
--
-- Run this in Snowsight as the user who needs a snow CLI connection.
-- The PAT token is shown ONCE — it cannot be retrieved after this statement.
--
-- IMPORTANT: Do NOT run this file as a single batch (Ctrl+A → Run).
-- Run it in two stages as marked below — the RESULT_SCAN at the end must
-- immediately follow the ADD PROGRAMMATIC ACCESS TOKEN statement with no
-- other queries in between, or it will fail to capture the token.
--
-- STAGE 1: Select and run everything from here down to the
--          "── END OF STAGE 1 ──" marker.
-- STAGE 2: Select and run the remaining statements together.
-- =============================================================================

USE WAREHOUSE SUMMIT_TRAD_WH;
USE ROLE ACCOUNTADMIN;
USE DATABASE ARCADE_DB;
USE SCHEMA PUBLIC;

CREATE OR ALTER AUTHENTICATION POLICY pat_bypass_policy
  PAT_POLICY = ( NETWORK_POLICY_EVALUATION = ENFORCED_NOT_REQUIRED );

set uu = 'ALTER USER ' || CURRENT_USER() || ' UNSET AUTHENTICATION POLICY';
EXECUTE IMMEDIATE $uu;
set nu = 'ALTER USER ' || CURRENT_USER() || ' SET AUTHENTICATION POLICY pat_bypass_policy';
EXECUTE IMMEDIATE $nu;

BEGIN
    ALTER USER REMOVE PROGRAMMATIC ACCESS TOKEN SNOW_CLI_PAT;
EXCEPTION
    WHEN OTHER THEN NULL;
END;

-- ── END OF STAGE 1 ──────────────────────────────────────────────────────────
-- Run everything above this line first, then run Stage 2 below.
-- ────────────────────────────────────────────────────────────────────────────

-- ── STAGE 2 ─────────────────────────────────────────────────────────────────
-- Select from here to the end of the file and run as a single batch.
-- RESULT_SCAN must immediately follow ADD PROGRAMMATIC ACCESS TOKEN.
-- ────────────────────────────────────────────────────────────────────────────

ALTER USER
    ADD PROGRAMMATIC ACCESS TOKEN SNOW_CLI_PAT
    COMMENT = 'snow CLI connection token';

-- Capture the token from the result above.
SET PAT_TOKEN = (SELECT "token_secret" FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())));

-- Copy the SETUP_COMMAND result and run it in your terminal.
-- It registers the snow CLI connection
SELECT
    'snow connection add'
    ||   ' --connection-name arcade'
    ||   ' --account '          || LOWER(CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME())
    ||   ' --user '             || CURRENT_USER()
    ||   ' --password '         || CHAR(39) || $PAT_TOKEN || CHAR(39)
    ||   ' --role '             || CURRENT_ROLE()
    ||   ' --no-interactive --default'
    AS SETUP_COMMAND;
