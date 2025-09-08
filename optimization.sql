-- 1. Install the HLL extension
CREATE EXTENSION IF NOT EXISTS postgresql_hll;

-- 2. Create a Materialized View for daily pre-aggregation
-- This is the core optimization: we pre-calculate the HLL sketch for every day.
DROP MATERIALIZED VIEW IF EXISTS daily_user_stats;

CREATE MATERIALIZED VIEW daily_user_stats AS
SELECT 
    DATE(created_at) as date,
    hll_add_agg(hll_hash_integer(user_id)) as unique_users_hll,
    COUNT(*) as total_events
FROM events
GROUP BY DATE(created_at);

-- 3. Index the materialized view for fast date range lookups
CREATE UNIQUE INDEX ON daily_user_stats (date);

-- 4. Refresh statistics for the optimizer
ANALYZE daily_user_stats;
-- commit 5: 1789737388
-- commit 13: 1789737388
-- commit 16: 1789737388
-- commit 17: 1789737388
-- commit 19: 1789737388
-- commit 23: 1789737389
-- commit 30: 1789737389
-- commit 32: 1789737389
-- commit 33: 1789737389
-- commit 35: 1789737389
-- commit 41: 1789737389
-- commit 42: 1789737389
