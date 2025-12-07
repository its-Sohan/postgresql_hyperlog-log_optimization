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
