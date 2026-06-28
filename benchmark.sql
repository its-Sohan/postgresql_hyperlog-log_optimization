-- ============================================================================
-- BENCHMARK: Exact Count vs. Probabilistic HLL
-- ============================================================================
\timing on

-- TEST 1: Baseline Exact Count
-- Expectation: Slow, high memory usage, disk spill for 100M rows.
SELECT '--- TEST 1: Exact COUNT(DISTINCT) ---' AS test;
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(DISTINCT user_id) 
FROM events 
WHERE created_at >= NOW() - INTERVAL '30 days';

-- TEST 2: HLL Raw Scan (Approximate)
-- Expectation: Faster than exact, but still scans the events table.
SELECT '--- TEST 2: HLL Raw Scan ---' AS test;
SELECT hll_cardinality(hll_add_agg(hll_hash_integer(user_id)))
FROM events
WHERE created_at >= NOW() - INTERVAL '30 days';

-- TEST 3: HLL Pre-aggregated (The 38x Winner)
-- Expectation: Ultra-fast (<100ms), reads only 30 rows from the materialized view.
SELECT '--- TEST 3: HLL Pre-aggregated (Materialized View) ---' AS test;
SELECT hll_cardinality(hll_union_agg(unique_users_hll))
FROM daily_user_stats
WHERE date >= CURRENT_DATE - 30;

\timing off
