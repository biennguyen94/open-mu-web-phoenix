#!/usr/bin/env python3
"""API parity check: sends the same requests to the Next.js app and the Phoenix app
(both pointed at the same disposable DB copy and game server) and compares status
codes and JSON bodies.

Usage: api_parity.py [NEXT_BASE] [PHOENIX_BASE]
Defaults: http://localhost:4100 http://localhost:4101
Exit code 1 when an unexpected difference is found.
"""
import json, sys, urllib.request, urllib.error

NEXT = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:4100"
PHX = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:4101"

# (method, path, body, expected_difference_note)
CASES = [
    ("GET", "/api/status", None, None),
    ("GET", "/api/characters/ranking/reset", None, None),
    ("GET", "/api/characters/ranking/killers", None, None),
    ("GET", "/api/guilds", None, None),
    ("GET", "/api/guilds/Alpha", None, None),
    ("GET", "/api/guilds/Beta", None, None),
    ("GET", "/api/guilds/Nope", None, None),
    ("POST", "/api/characters/ranking/online", "STATUS", None),
    ("POST", "/api/characters/ranking/online", {"playersList": []}, None),
    ("POST", "/api/characters/ranking/online", {"playersList": ["test1Dk", "nobody"]}, None),
    ("POST", "/api/characters/ranking/online", {"playersList": [1, 2]}, None),
    ("POST", "/api/characters/ranking/online", {"playersList": "test1Dk"}, None),
    ("POST", "/api/characters/ranking/online", {}, "R10: Next returns every character; Phoenix 400"),
]


def call(base, method, path, body):
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(base + path, data=data, method=method)
    if data is not None:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main():
    status_body = json.loads(call(NEXT, "GET", "/api/status", None)[1])
    failures = 0
    for method, path, body, note in CASES:
        if body == "STATUS":
            body = status_body
        n_status, n_body = call(NEXT, method, path, body)
        p_status, p_body = call(PHX, method, path, body)
        same_status = n_status == p_status
        exact = n_body == p_body
        try:
            semantic = json.loads(n_body) == json.loads(p_body)
        except ValueError:
            semantic = False
        label = f"{method} {path} {json.dumps(body) if body is not None else ''}"[:110]
        if same_status and exact:
            print(f"OK        {label}")
        elif same_status and semantic:
            print(f"OK(sem)   {label}  (same JSON, different bytes)")
        elif note:
            print(f"EXPECTED  {label}  [{note}] next={n_status} phoenix={p_status}")
        else:
            failures += 1
            print(f"DIFF      {label}\n  next    {n_status} {n_body[:300]}\n  phoenix {p_status} {p_body[:300]}")
    print(f"\n{len(CASES) - failures}/{len(CASES)} cases match (incl. expected differences)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
