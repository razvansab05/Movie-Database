INSERT INTO users (username, email, password_hash, country)
SELECT 'user' || g, 'user' || g || '@example.com', NULL, NULL
FROM generate_series(1, 1000) AS g;
