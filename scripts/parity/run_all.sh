#!/usr/bin/env bash
# Runs every parity check between the Next.js app and the Phoenix app.
#
#   scripts/parity/run_all.sh
#
# Needs: the `database` docker container (source DB `openmu`, only read), a checkout
# of the Next.js app with its node modules (https://github.com/biennguyen94/open-mu-web;
# NEXT_APP_DIR, default ../open-mu-web next to this repository), the Elixir
# toolchain, python3.
# Uses ports 4100 (Next.js), 4101 (Phoenix), 18080 (fake OpenMU status server).
# Creates / recreates the disposable databases openmu_parity, openmu_p4_next,
# openmu_p4_phx, openmu_p5_next, openmu_p5_phx. Never writes to `openmu`.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PHX_DIR="$(cd "$HERE/../.." && pwd)"
NEXT_APP_DIR="$(cd "${NEXT_APP_DIR:-$PHX_DIR/../open-mu-web}" && pwd)"
LOG_DIR="${LOG_DIR:-$(mktemp -d)}"
export PATH="$HOME/.local/beam/otp/bin:$HOME/.local/beam/elixir/bin:$PATH"

env_file=$( [ -f "$PHX_DIR/.env" ] && echo "$PHX_DIR/.env" || echo "$NEXT_APP_DIR/.env" )
BASE_URL="${DATABASE_URL:-$(grep -E '^DATABASE_URL=' "$env_file" | cut -d= -f2- | tr -d '"')}"
db_url() { echo "$BASE_URL" | sed -E "s#/openmu(\?|$)#/$1\1#"; }

PIDS=()
start() { # name, dir, command...
  local name=$1 dir=$2; shift 2
  # exec: the recorded PID is the new session / process group leader, so the whole
  # tree (npx → next, mix → beam) can be stopped with kill -- -PID.
  (cd "$dir" && exec setsid "$@" >"$LOG_DIR/$name.log" 2>&1) &
  PIDS+=("$!")
}
stop_all() {
  for pid in "${PIDS[@]}"; do kill -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null; done
  PIDS=(); sleep 2
}
trap stop_all EXIT
wait_for() { for _ in $(seq 1 120); do curl -s -o /dev/null -m 60 "$1" && return 0; sleep 2; done; echo "timeout: $1"; return 1; }

stage() { # next_db, phoenix_db, players...
  local next_db=$1 phx_db=$2; shift 2
  start fake_gs "$HERE" python3 ./fake_game_server.py "$@"
  start next "$NEXT_APP_DIR" env DATABASE_URL="$(db_url "$next_db")" NEXT_PUBLIC_URL=http://localhost:4100 \
    NEXTAUTH_URL=http://localhost:4100 GAMESERVER_URL=http://localhost:18080 npx next dev -p 4100
  start phoenix "$PHX_DIR" env DATABASE_URL="$(db_url "$phx_db")" GAMESERVER_URL=http://localhost:18080 PORT=4101 mix phx.server
  wait_for http://localhost:4100/api/status && wait_for http://localhost:4101/api/status
}

RESULTS=()
check() { # label, command...
  local label=$1; shift
  echo "=== $label"
  if (cd "$HERE" && "$@"); then RESULTS+=("PASS  $label"); else RESULTS+=("FAIL  $label"); fi
}

echo "logs: $LOG_DIR"

# 1. Shared DB: read-only API, HTTP surface, pages, authentication.
TEST_DB=openmu_parity "$PHX_DIR/scripts/setup_test_db.sh" >/dev/null
docker exec -i database psql -U postgres -d openmu_parity -v ON_ERROR_STOP=1 -q <"$HERE/fixtures.sql"
stage openmu_parity openmu_parity test1Dk testgmDw test400Elf ghostName
check "api_parity" ./api_parity.py
check "http_parity" ./http_parity.py
check "page_parity" ./page_parity.py http://localhost:4100 http://localhost:4101 / /info /download /terms-and-conditions /register /news/not-a-uuid
check "auth_parity" ./auth_parity.py
stop_all

# 2. Character operations: one fresh copy per app.
for db in openmu_p4_next openmu_p4_phx; do TEST_DB=$db "$PHX_DIR/scripts/setup_test_db.sh" >/dev/null; done
stage openmu_p4_next openmu_p4_phx test1Dl test400Mg
check "char_parity" ./char_parity.py
stop_all

# 3. Admin news: one fresh copy per app.
for db in openmu_p5_next openmu_p5_phx; do TEST_DB=$db "$PHX_DIR/scripts/setup_test_db.sh" >/dev/null; done
stage openmu_p5_next openmu_p5_phx
check "admin_parity" ./admin_parity.py
stop_all

rm -rf "$HERE/__pycache__"
echo; printf '%s\n' "${RESULTS[@]}"
! printf '%s\n' "${RESULTS[@]}" | grep -q '^FAIL'
