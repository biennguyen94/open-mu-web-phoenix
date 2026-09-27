#!/usr/bin/env python3
"""Admin news parity (POST /api/admin/news, DELETE /api/admin/news/:id).

Each app runs on its OWN fresh copy of the OpenMU DB (the news table is written):
  TEST_DB=openmu_p5_next ../setup_test_db.sh ; TEST_DB=openmu_p5_phx ../setup_test_db.sh
  Next.js :4100 on openmu_p5_next, Phoenix :4101 on openmu_p5_phx, ./fake_game_server.py
The same sequence runs on both apps; responses and the final news rows are compared.
Usage: admin_parity.py [NEXT_BASE] [PHOENIX_BASE]   env NEXT_DB / PHX_DB, DB_CONTAINER
"""
import os, subprocess, sys

from auth_parity import NEXT, PHX, client, login, request

NEXT_DB = os.environ.get("NEXT_DB", "openmu_p5_next")
PHX_DB = os.environ.get("PHX_DB", "openmu_p5_phx")
CONTAINER = os.environ.get("DB_CONTAINER", "database")
failures = 0


def psql(db, sql):
    return subprocess.run(["docker", "exec", CONTAINER, "psql", "-U", "postgres", "-d", db, "-At", "-F", "|", "-c", sql],
                          capture_output=True, text=True, check=True).stdout.strip().splitlines()


def news_id(db, title):
    rows = psql(db, f"""select id from data."OpenMuWeb_News" where title = '{title}' order by "creationDate" limit 1""")
    return rows[0] if rows else "00000000-0000-4000-8000-000000000000"


def check(label, n, p, expected=None):
    global failures
    if n == p:
        print(f"OK        {label}  {p}")
    elif expected:
        print(f"EXPECTED  {label}  [{expected}] next={n} phoenix={p}")
    else:
        failures += 1
        print(f"DIFF      {label}\n            next={n}\n            phoenix={p}")


def create(sessions, label, body=None, raw=None, content_type=None, expected=None):
    hdr = {"Content-Type": content_type} if content_type else None
    n = request(sessions[0], "POST", f"{NEXT}/api/admin/news", body=body, raw=raw, headers=hdr)
    p = request(sessions[1], "POST", f"{PHX}/api/admin/news", body=body, raw=raw, headers=hdr)
    check("create " + label, n, p, expected)


def delete(sessions, label, title=None, raw_id=None, expected=None):
    n_id = raw_id or news_id(NEXT_DB, title)
    p_id = raw_id or news_id(PHX_DB, title)
    check("delete " + label, request(sessions[0], "DELETE", f"{NEXT}/api/admin/news/{n_id}"),
          request(sessions[1], "DELETE", f"{PHX}/api/admin/news/{p_id}"), expected)


def main():
    anon = (client(), client())
    create(anon, "anonymous", {"title": "a", "body": "b"})
    create(anon, "anonymous invalid JSON", raw=b"nojson")
    delete(anon, "anonymous", raw_id="00000000-0000-4000-8000-000000000000")

    gm = (login(NEXT, "testgm", "testgm"), login(PHX, "testgm", "testgm"))
    create(gm, "GM", {"title": "t1", "body": "b1\nline 2"})
    create(gm, "GM keep", {"title": "keep", "body": "stays"})
    create(gm, "missing body", {"title": "t2"})
    create(gm, "empty strings", {"title": "", "body": ""})
    create(gm, "non-string title", {"title": 5, "body": "x"})
    create(gm, "array title", {"title": ["a"], "body": "x"})
    create(gm, "invalid JSON", raw=b"nojson")
    create(gm, "text/plain body (as the Next.js form sent it)", raw=b'{"title":"t3","body":"b3"}', content_type="text/plain;charset=UTF-8")
    delete(gm, "existing", title="t1")
    delete(gm, "already deleted", raw_id="00000000-0000-4000-8000-000000000000")
    delete(gm, "malformed id", raw_id="not-a-uuid")

    gm2 = (login(NEXT, "testgm2", "testgm2"), login(PHX, "testgm2", "testgm2"))
    create(gm2, "second GM account", {"title": "t4", "body": "b4"})

    print("\n-- security fixes (expected differences)")
    user = (login(NEXT, "test1", "test1"), login(PHX, "test1", "test1"))
    create(user, "by a non-GM account", {"title": "user", "body": "x"}, expected="R3")
    delete(user, "by a non-GM account", title="keep", expected="R3")

    print("\n-- news rows (title | body | author)")
    sql = """select title, replace(body, E'\\n', '\\n'), author from data."OpenMuWeb_News" order by title, body"""
    n_rows, p_rows = psql(NEXT_DB, sql), psql(PHX_DB, sql)
    for row in sorted(set(n_rows) | set(p_rows)):
        where = "both" if row in n_rows and row in p_rows else ("next only" if row in n_rows else "phoenix only")
        print(f"  {where:13} {row}")
    # title/body must match once the R3 rows are set aside ("user" only exists on Next.js,
    # "keep" was deleted by a non-GM account on Next.js only); authors differ by design.
    title_body = lambda rows, skip: sorted(r.rsplit("|", 1)[0] for r in rows if not r.startswith(skip))
    same = title_body(n_rows, ("user|", "keep|")) == title_body(p_rows, ("user|", "keep|"))
    check("news title/body (R3 rows excluded)", same, True)
    print(f"\nfailures: {failures}  (author: Next.js used the first GM of ALL characters, Phoenix the logged-in account's first GM by slot)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
