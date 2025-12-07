-- Benchmark exact count
\timing on
--run separtely 
EXPLAIN (ANALYZE, BUFFERS) 
SELECT COUNT(DISTINCT user_id) 
FROM events 
WHERE created_at >= NOW() - INTERVAL '30 days';

-- Save output to results/exact_query_plan.txt

-- Install HLL
CREATE EXTENSION IF NOT EXISTS postgresql_hll;

-- Benchmark HLL
EXPLAIN (ANALYZE, BUFFERS)
SELECT hll_cardinality(hll_add_agg(hll_hash_integer(user_id)))
FROM events
WHERE created_at >= NOW() - INTERVAL '30 days';

-- Save output to results/hll_query_plan.txt
