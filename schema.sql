-- TABLES 
-- user 
CREATE TABLE IF NOT EXISTS users (
	id BIGSERIAL PRIMARY KEY,
	username TEXT NOT NULL UNIQUE,
	email TEXT UNIQUE,
	password_hash TEXT,
	country TEXT
);

-- people involved with movies
CREATE TABLE IF NOT EXISTS people (
	id BIGSERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	birth_date DATE NOT NULL,
	death_date DATE
);

-- genres
CREATE TABLE IF NOT EXISTS genres (
	id SMALLSERIAL PRIMARY KEY,
	name TEXT NOT NULL UNIQUE
);

-- movies
CREATE TABLE IF NOT EXISTS movies (
	id BIGSERIAL PRIMARY KEY,
	title TEXT NOT NULL,
	year INT CHECK (year >= 1888), 
	runtime_minutes INT CHECK (runtime_minutes >= 0),
	language TEXT,
	country TEXT,
	budget BIGINT
);

-- movie_genres
CREATE TABLE IF NOT EXISTS movie_genres (
	movie_id BIGINT NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
	genre_id SMALLINT NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
	PRIMARY KEY (movie_id, genre_id)
);

-- peoples roles
CREATE TABLE IF NOT EXISTS roles (
	id BIGSERIAL PRIMARY KEY,
	role_name TEXT NOT NULL UNIQUE 
);	

-- casting
CREATE TABLE IF NOT EXISTS movie_casting (
	movie_id BIGINT NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
	person_id BIGINT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
	role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
	character_name TEXT,
	PRIMARY KEY (movie_id, person_id, role_id)
);

-- movie ratings
CREATE TABLE IF NOT EXISTS ratings (
	id BIGSERIAL PRIMARY KEY,
	movie_id BIGINT NOT NULL REFERENCES movies(id) ON DELETE CASCADE,
	user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
	rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 10)
);

-- VIEWS
-- CREDITS
CREATE OR REPLACE VIEW v_movie_credits AS
SELECT mc.movie_id, m.title AS movie_title,
	   p.id AS person_id, p.name AS person_name,
	   r.role_name, mc.character_name
FROM movie_casting mc
	JOIN movies m ON m.id = mc.movie_id
	JOIN people p ON p.id = mc.person_id
	JOIN roles r ON r.id = mc.role_id
ORDER BY mc.movie_id;

-- MOVIE GENRES
CREATE OR REPLACE VIEW v_movies_with_genres AS
SELECT m.id AS movie_id, m.title, g.name AS genre
FROM movies m
	LEFT JOIN movie_genres mg ON mg.movie_id = m.id
	LEFT JOIN genres g ON g.id = mg.genre_id
ORDER BY m.id;

-- MOVIE INFO
CREATE OR REPLACE VIEW v_movies_info AS
SELECT id, title, year, runtime_minutes, language, country
FROM movies;

