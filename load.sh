#!/usr/bin/env bash
# Usage: ./load.sh [database_name]   (default: imdb)
set -euo pipefail
DB="${1:-imdb}"
cd "$(dirname "$0")"
createdb "$DB"
for f in schema.sql seed/genres.sql seed/roles.sql seed/users.sql \
         data/movies.sql data/people.sql data/movie_genres.sql \
         data/movie_casting.sql data/ratings.sql; do
  echo "Loading $f"
  psql -v ON_ERROR_STOP=1 -q -d "$DB" -f "$f"
done
echo "Done. Connect with: psql -d $DB"
