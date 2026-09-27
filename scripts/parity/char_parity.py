#!/usr/bin/env python3
"""Character operations parity (add stats, PK clear, reset, reset stats).

Each app runs on its OWN fresh copy of the OpenMU DB (operations write data):
  TEST_DB=openmu_p4_next ../setup_test_db.sh ; TEST_DB=openmu_p4_phx ../setup_test_db.sh
  Next.js :4100 on openmu_p4_next, Phoenix :4101 on openmu_p4_phx,
  ./fake_game_server.py test1Dl test400Mg   (these two characters are "online")
The same sequence runs on both apps; responses are compared, then the character
state of both databases is diffed. Security fixes (R2, R3, R4) are exercised last
and reported as expected differences.
Usage: char_parity.py [NEXT_BASE] [PHOENIX_BASE]   env NEXT_DB / PHX_DB, DB_CONTAINER
"""
import json, os, subprocess, sys

from auth_parity import NEXT, PHX, client, login, request

NEXT_DB = os.environ.get("NEXT_DB", "openmu_p4_next")
PHX_DB = os.environ.get("PHX_DB", "openmu_p4_phx")
CONTAINER = os.environ.get("DB_CONTAINER", "database")
failures = 0


def op(c, base, route, body=None, raw=None):
    return request(c, "POST", f"{base}/api/characters/{route}", body=body, raw=raw)


def both(label, sessions, route, body=None, raw=None, expected=None):
    global failures
    n = op(sessions[0], NEXT, route, body, raw)
    p = op(sessions[1], PHX, route, body, raw)
    if n == p:
        print(f"OK        {label}  {p}")
    elif expected:
        print(f"EXPECTED  {label}  [{expected}]\n            next={n}\n            phoenix={p}")
    else:
        failures += 1
        print(f"DIFF      {label}\n            next={n}\n            phoenix={p}")


def psql(db, sql):
    out = subprocess.run(["docker", "exec", CONTAINER, "psql", "-U", "postgres", "-d", db, "-At", "-F", "|", "-c", sql],
                         capture_output=True, text=True, check=True).stdout
    return out.strip().splitlines()


STATE_SQL = """
select c."Name", c."LevelUpPoints", c."State", c."StateRemainingSeconds", coalesce(c."CurrentMapId"::text,''),
       c."PositionX", c."PositionY", i."Money",
       string_agg(ad."Designation" || '=' || sa."Value", ',' order by ad."Designation")
from data."Character" c join data."ItemStorage" i on i."Id" = c."InventoryId"
join data."StatAttribute" sa on sa."CharacterId" = c."Id"
join config."AttributeDefinition" ad on ad."Id" = sa."DefinitionId"
where ad."Designation" in ('Level','Resets','Master Level','Base Strength','Base Agility','Base Vitality','Base Energy','Base Leadership')
group by 1,2,3,4,5,6,7,8 order by 1"""


def main():
    anon = (client(), client())
    for route in ["pkclear", "addstats", "reset", "resetStats"]:
        both(f"anonymous {route}", anon, route, {"name": "test1Elf", "str": 1, "agi": 0, "vit": 0, "ene": 0, "lead": 0})

    t1 = (login(NEXT, "test1", "test1"), login(PHX, "test1", "test1"))
    both("pkclear own", t1, "pkclear", {"name": "test1Elf"})
    both("pkclear online character", t1, "pkclear", {"name": "test1Dl"})
    both("addstats own", t1, "addstats", {"name": "test1Dk", "str": 5, "agi": 1, "vit": 0, "ene": 2, "lead": 0})
    both("addstats zeros", t1, "addstats", {"name": "test1Dk", "str": 0, "agi": 0, "vit": 0, "ene": 0, "lead": 0})
    both("addstats not enough points", t1, "addstats", {"name": "test1Dk", "str": 1000, "agi": 0, "vit": 0, "ene": 0, "lead": 0})
    both("addstats missing lead", t1, "addstats", {"name": "test1Dk", "str": 1, "agi": 0, "vit": 0, "ene": 0})
    both("addstats online", t1, "addstats", {"name": "test1Dl", "str": 1, "agi": 0, "vit": 0, "ene": 0, "lead": 0})
    both("addstats unknown character", t1, "addstats", {"name": "nobody", "str": 1, "agi": 0, "vit": 0, "ene": 0, "lead": 0})
    both("resetStats own", t1, "resetStats", {"name": "test1Dw", "clasId": "x"})
    both("reset not eligible", t1, "reset", {"name": "test1Dk", "clasId": "x"})
    for route in ["pkclear", "addstats", "reset", "resetStats"]:
        both(f"{route} invalid JSON", t1, route, raw=b"nojson")
        both(f"{route} unknown character", t1, route, {"name": "nobody"})

    t4 = (login(NEXT, "test400", "test400"), login(PHX, "test400", "test400"))
    both("reset elf (legit clasId)", t4, "reset", {"name": "test400Elf", "clasId": "00000040-000b-0000-0000-000000000000"})
    both("reset BM", t4, "reset", {"name": "test400Dk", "clasId": "00000040-0007-0000-0000-000000000000"})
    both("reset again (now level 1)", t4, "reset", {"name": "test400Dk", "clasId": "00000040-0007-0000-0000-000000000000"})
    both("reset online", t4, "reset", {"name": "test400Mg", "clasId": "00000040-000d-0000-0000-000000000000"})
    both("addstats DL leadership", t4, "addstats", {"name": "test400Dl", "str": 0, "agi": 0, "vit": 0, "ene": 0, "lead": 3})
    both("addstats lead on non-DL (B5: points spent, no stat)", t4, "addstats", {"name": "test400Dw", "str": 1, "agi": 0, "vit": 0, "ene": 0, "lead": 3})
    for db in (NEXT_DB, PHX_DB):  # same data change on both copies
        psql(db, """update data."ItemStorage" set "Money" = 500000 where "Id" = (select "InventoryId" from data."Character" where "Name" = 'test400Dw')""")
    both("reset not enough zen", t4, "reset", {"name": "test400Dw", "clasId": "x"})
    both("resetStats not enough zen", t4, "resetStats", {"name": "test400Dw", "clasId": "x"})
    both("pkclear not enough zen", t4, "pkclear", {"name": "test400Dw"})
    both("resetStats LE (leadership row)", t4, "resetStats", {"name": "test400Dl", "clasId": "x"})

    print("\n-- security fixes (expected differences)")
    both("R3 pkclear another account's character", t1, "pkclear", {"name": "test400Elf"}, expected="R3")
    both("R2 negative amount", t1, "addstats", {"name": "test1Dk", "str": -3, "agi": 0, "vit": 0, "ene": 0, "lead": 0}, expected="R2")
    both("R2 fractional amount", t1, "addstats", {"name": "test1Dk", "str": 1.5, "agi": 0, "vit": 0, "ene": 0, "lead": 0}, expected="R2")
    both("R4 spoofed clasId", t4, "reset", {"name": "test400Dl", "clasId": "00000040-0014-0000-0000-000000000000"})

    print("\n-- database state")
    n_rows, p_rows = psql(NEXT_DB, STATE_SQL), psql(PHX_DB, STATE_SQL)
    n_map = {r.split("|")[0]: r for r in n_rows}
    p_map = {r.split("|")[0]: r for r in p_rows}
    expected_state = {"test1Dk": "R2", "test400Elf": "R3", "test400Dl": "R4"}
    for name in sorted(set(n_map) | set(p_map)):
        if n_map.get(name) != p_map.get(name):
            tag = expected_state.get(name)
            if not tag:
                failures_add()
            print(f"{'EXPECTED' if tag else 'DIFF    '}  {name} [{tag or ''}]\n            next    {n_map.get(name)}\n            phoenix {p_map.get(name)}")
    print(f"{len(n_map)} characters compared")
    print(f"\nfailures: {failures}")
    sys.exit(1 if failures else 0)


def failures_add():
    global failures
    failures += 1


if __name__ == "__main__":
    main()
