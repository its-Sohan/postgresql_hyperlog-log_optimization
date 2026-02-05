CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    user_id INT,
    session_id UUID,
    created_at TIMESTAMPTZ
);

--Generating 100M rows will take around 10 minutes
INSERT INTO events (user_id, session_id, created_at)
SELECT 
    (random() * 10000000)::INT, -- 10M unique users
    gen_random_uuid(),
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 100000000);

-- Create indexes
CREATE INDEX ON events (created_at);
CREATE INDEX ON events (user_id);

-- Analyze for accurate query plans
ANALYZE events;
-- commit 2: 1789737388
-- commit 6: 1789737388
-- commit 7: 1789737388
-- commit 10: 1789737388
-- commit 11: 1789737388
-- commit 14: 1789737388
-- commit 21: 1789737389
-- commit 25: 1789737389
-- commit 38: 1789737389
-- commit 49: 1789737389
-- commit 1: 1789737506
-- commit 2: 1789737506
-- commit 3: 1789737506
-- commit 5: 1789737506
-- commit 6: 1789737506
-- commit 10: 1789737506
-- commit 17: 1789737506
-- commit 18: 1789737506
-- commit 21: 1789737506
-- commit 25: 1789737507
-- commit 28: 1789737507
-- commit 32: 1789737507
-- commit 33: 1789737507
-- commit 34: 1789737507
-- commit 45: 1789737507
