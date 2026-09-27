#!/usr/bin/env python3
"""HTTP-level parity of the API surface: methods (405), OPTIONS (204 + allow),
HEAD, trailing-slash redirects (308), unknown paths, query strings, URL-encoded
parameters and response headers (content-type, allow, location).

Both apps on the same DB copy (openmu_parity + fixtures.sql) and fake game server.
Usage: http_parity.py [NEXT_BASE] [PHOENIX_BASE]
"""
import http.client, sys, urllib.parse

NEXT = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:4100"
PHX = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:4101"

ROUTES = {  # path -> methods implemented (from app/api/**/route.ts)
    "/api/status": ["GET"],
    "/api/characters/ranking/reset": ["GET"],
    "/api/characters/ranking/killers": ["GET"],
    "/api/characters/ranking/online": ["POST"],
    "/api/guilds": ["GET"],
    "/api/guilds/Alpha": ["GET"],
    "/api/account/register": ["POST"],
    "/api/account/changepassword": ["PUT"],
    "/api/characters/addstats": ["POST"],
    "/api/characters/pkclear": ["POST"],
    "/api/characters/reset": ["POST"],
    "/api/characters/resetStats": ["POST"],
    "/api/admin/news": ["POST"],
    "/api/admin/news/00000000-0000-4000-8000-000000000000": ["DELETE"],
}
# Paths where the body is not compared (non-deterministic or app-specific HTML).
UNCOMPARED_404 = True


def call(base, method, path):
    u = urllib.parse.urlparse(base)
    c = http.client.HTTPConnection(u.hostname, u.port, timeout=60)
    c.request(method, path, body=b"" if method in ("POST", "PUT", "PATCH", "DELETE") else None)
    r = c.getresponse()
    body = r.read().decode(errors="replace")
    headers = {k.lower(): v for k, v in r.getheaders() if k.lower() in ("content-type", "allow", "location")}
    return r.status, headers, body


def main():
    cases = []
    for path, methods in ROUTES.items():
        for m in ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"]:
            implemented = m in methods or (m == "HEAD" and "GET" in methods)
            if not implemented:  # 405 / 204 / HEAD-on-POST cases
                cases.append((m, path))
    cases += [("GET", "/api/guilds/"), ("GET", "/api/guilds/Alpha/"), ("GET", "/info/"), ("GET", "/news/abc/?x=1"),
              ("HEAD", "/api/guilds"), ("GET", "/api/guilds/Alpha?x=1"), ("GET", "/api/guilds/A%20b%2F%C3%A9"),
              ("GET", "/api/guilds/%E2%9C%93"), ("GET", "/api/nope"), ("POST", "/api/characters/ranking")]
    failures = 0
    for method, path in cases:
        n, p = call(NEXT, method, path), call(PHX, method, path)
        if n[0] == 404 and p[0] == 404 and UNCOMPARED_404:
            same = True  # both 404 (Next.js and Phoenix have their own 404 pages)
        else:
            same = n == p
        failures += not same
        print(f"{'OK  ' if same else 'DIFF'}  {method:7} {path:58} {p[0]} {p[1]}")
        if not same:
            print(f"        next    {n}\n        phoenix {p}")
    print(f"\n{len(cases) - failures}/{len(cases)} match")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
