#!/usr/bin/env bash
# Provision the disposable test database as a FULL copy of the OpenMU database.
#
# A schema-only copy is not enough: foreign keys need the `config` reference rows
# (character classes, attribute definitions, maps). The source database is only
# read (pg_dump); the target is dropped and recreated.
#
# Usage:  scripts/setup_test_db.sh
# Env:    DB_CONTAINER  docker container running PostgreSQL (default: database;
#                       set to "" to use local psql/pg_dump instead)
#         DB_USER       PostgreSQL user (default: postgres)
#         SOURCE_DB     database to copy (default: openmu)
#         TEST_DB       database to (re)create (default: open_mu_web_test)
set -euo pipefail

DB_CONTAINER="${DB_CONTAINER-database}"
DB_USER="${DB_USER:-postgres}"
SOURCE_DB="${SOURCE_DB:-openmu}"
TEST_DB="${TEST_DB:-open_mu_web_test}"

if [[ "$TEST_DB" == "openmu" || "$TEST_DB" == "$SOURCE_DB" ]]; then
  echo "Refusing: TEST_DB ($TEST_DB) must not be the OpenMU / source database." >&2
  exit 1
fi
if [[ ! "$TEST_DB" =~ ^[a-z0-9_]+$ ]]; then
  echo "Refusing: TEST_DB must match ^[a-z0-9_]+$" >&2
  exit 1
fi

run() {
  if [[ -n "$DB_CONTAINER" ]]; then
    docker exec -i "$DB_CONTAINER" "$@"
  else
    "$@"
  fi
}

echo "Recreating $TEST_DB ..."
run psql -U "$DB_USER" -d postgres -v ON_ERROR_STOP=1 -q \
  -c "DROP DATABASE IF EXISTS \"$TEST_DB\" WITH (FORCE)" \
  -c "CREATE DATABASE \"$TEST_DB\""

echo "Copying $SOURCE_DB -> $TEST_DB (pg_dump, read-only on the source) ..."
run pg_dump -U "$DB_USER" -d "$SOURCE_DB" --no-owner --no-privileges \
  | run psql -U "$DB_USER" -d "$TEST_DB" -v ON_ERROR_STOP=1 -q >/dev/null

tables=$(run psql -U "$DB_USER" -d "$TEST_DB" -Atc \
  "select count(*) from information_schema.tables where table_schema in ('config','data','friend','guild','public')")
echo "Done: $TEST_DB has $tables tables."
