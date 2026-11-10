# Movie Database (IMDb-style) – PostgreSQL

A small relational database modelled after IMDb, written for PostgreSQL. It stores movies, the people who work on them, genres, cast/crew roles, users and user ratings, and includes ready-made views for common lookups.

All sample data is randomly generated and fictional. Any resemblance to real films or people is coincidental.

## Project structure

```
movie-database/
├── schema.sql              Tables, constraints and views
├── seed/
│   ├── genres.sql          10 genres
│   ├── roles.sql           9 cast/crew roles
│   └── users.sql           1,000 placeholder users
├── data/
│   ├── movies.sql          1,000 movies
│   ├── people.sql          1,000 people
│   ├── movie_genres.sql    1,000 movie-genre links
│   ├── movie_casting.sql   1,000 cast/crew assignments
│   └── ratings.sql         1,000 ratings (1-10)
├── load.sh                 One-command setup script
└── README.md
```

## Schema

```
users ──────────┐
                ▼
movies ◄──── ratings
  │ ▲
  │ └──── movie_genres ────► genres
  │
  └────── movie_casting ───► people
                    └──────► roles
```

| Table | Description |
|-------|-------------|
| `users` | Registered users (`username`, `email`, `password_hash`, `country`) |
| `people` | Anyone involved in a movie (`name`, `birth_date`, optional `death_date`) |
| `genres` | Genre names (unique) |
| `movies` | Title, year (>= 1888), runtime, language, country, budget |
| `movie_genres` | Many-to-many link between movies and genres |
| `roles` | Role names such as Actor or Director (unique) |
| `movie_casting` | Who played which role in which movie, plus the character name |
| `ratings` | A user's rating of a movie, constrained to 1-10 |

Design notes:

- Deleting a movie cascades to its genre links, casting rows and ratings.
- Deleting a user keeps their ratings (`user_id` is set to `NULL`).
- A role cannot be deleted while casting rows still reference it (`ON DELETE RESTRICT`).
- `year`, `runtime_minutes` and `rating` have `CHECK` constraints.

### Views

| View | Returns |
|------|---------|
| `v_movie_credits` | Movie title, person name, role and character name |
| `v_movies_with_genres` | One row per movie/genre pair |
| `v_movies_info` | Movie overview without budget |

## Getting started

Requirements: PostgreSQL 12 or newer, with `psql` and `createdb` on your PATH.

Quick setup:

```bash
./load.sh            # creates a database called "imdb"
./load.sh my_db      # or choose your own name
psql -d imdb
```

Manual setup, in this order (foreign keys depend on it):

```bash
createdb imdb
psql -d imdb -f schema.sql
psql -d imdb -f seed/genres.sql
psql -d imdb -f seed/roles.sql
psql -d imdb -f seed/users.sql
psql -d imdb -f data/movies.sql
psql -d imdb -f data/people.sql
psql -d imdb -f data/movie_genres.sql
psql -d imdb -f data/movie_casting.sql
psql -d imdb -f data/ratings.sql
```

## Example queries

Highest-rated movies:

```sql
SELECT m.title, m.year, r.rating
FROM movies m
JOIN ratings r ON r.movie_id = m.id
ORDER BY r.rating DESC, m.title
LIMIT 10;
```

Cast and crew of a movie:

```sql
SELECT person_name, role_name, character_name
FROM v_movie_credits
WHERE movie_title = 'Young Guns';
```

Number of movies per genre:

```sql
SELECT genre, COUNT(*) AS movies
FROM v_movies_with_genres
GROUP BY genre
ORDER BY movies DESC;
```

## Notes and ideas for improvement

- The sample data has one rating per movie, so averages are not meaningful yet.
- Add indexes on `ratings(movie_id)` and `movie_casting(person_id)` for larger datasets.
- Add a unique constraint on `ratings(movie_id, user_id)` so each user rates a movie once.

