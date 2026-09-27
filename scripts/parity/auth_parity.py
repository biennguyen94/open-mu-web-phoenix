#!/usr/bin/env python3
"""Auth parity: register API (incl. zod error bodies), login on both apps (also
cross-app: an account created by one app logs in on the other), NextAuth-style
session JSON and the change-password API.

Both apps must use the same disposable DB copy (see README.md). Creates accounts
with a random suffix on each run.
Usage: auth_parity.py [NEXT_BASE] [PHOENIX_BASE]
"""
import http.cookiejar, json, random, re, string, sys, urllib.error, urllib.parse, urllib.request

NEXT = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:4100"
PHX = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:4101"
SUFFIX = "".join(random.choices(string.digits, k=5))
failures = 0


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def client():
    jar = http.cookiejar.CookieJar()
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar), NoRedirect())


def request(opener, method, url, body=None, form=None, raw=None, headers=None):
    data, hdrs = None, dict(headers or {})
    if body is not None:
        data, hdrs["Content-Type"] = json.dumps(body).encode(), "application/json"
    elif form is not None:
        data, hdrs["Content-Type"] = urllib.parse.urlencode(form).encode(), "application/x-www-form-urlencoded"
    elif raw is not None:
        data, hdrs["Content-Type"] = raw, "application/json"
    req = urllib.request.Request(url, data=data, method=method, headers=hdrs)
    try:
        with opener.open(req, timeout=60) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def login(base, user, password):
    c = client()
    if base == NEXT:
        token = json.loads(request(c, "GET", f"{NEXT}/api/auth/csrf")[1])["csrfToken"]
        request(c, "POST", f"{NEXT}/api/auth/callback/credentials",
                form={"csrfToken": token, "username": user, "password": password, "json": "true"})
    else:
        html = request(c, "GET", f"{PHX}/info")[1]
        token = re.search(r'name="csrf-token" content="([^"]+)"', html).group(1)
        request(c, "POST", f"{PHX}/login", form={"_csrf_token": token, "username": user, "password": password},
                headers={"Referer": f"{PHX}/info"})
    return c


def session(c, base):
    body = json.loads(request(c, "GET", f"{base}/api/auth/session")[1])
    body.pop("expires", None)
    return body


def compare(label, n, p):
    global failures
    ok = n == p
    failures += not ok
    print(("OK    " if ok else "DIFF  ") + label)
    if not ok:
        print("   next   ", str(n)[:300]); print("   phoenix", str(p)[:300])


def main():
    ok = {"Password": "password1", "RepeatPassword": "password1"}
    anon = client()
    cases = [
        {"LoginName": "ab", "EMail": "x", "Password": "1", "RepeatPassword": "2"}, {},
        {"LoginName": "abcdefghijkl", "EMail": "x" * 31 + "@example.com", "Password": "1" * 21, "RepeatPassword": "12345678"},
        {"LoginName": 123, "EMail": None, "Password": True, "RepeatPassword": ["a"]},
        {"LoginName": "test1", "EMail": f"n{SUFFIX}@example.com", **ok},
        {"LoginName": "😀😀", "EMail": f"n{SUFFIX}@example.com", **ok},
    ] + [{"LoginName": "okname", "EMail": e, **ok} for e in [".a@b.cd", "a..b@c.de", "a@b.c", "ab@c.d1"]]
    for c in cases:
        compare("register " + json.dumps(c, ensure_ascii=False)[:80],
                request(anon, "POST", f"{NEXT}/api/account/register", body=c),
                request(anon, "POST", f"{PHX}/api/account/register", body=c))
    for raw in [b"nojson", b"", b"[]", b"null"]:
        compare(f"register raw {raw!r}", request(anon, "POST", f"{NEXT}/api/account/register", raw=raw),
                request(anon, "POST", f"{PHX}/api/account/register", raw=raw))

    nx, px = f"nx{SUFFIX}", f"px{SUFFIX}"
    n = request(anon, "POST", f"{NEXT}/api/account/register", body={"LoginName": nx, "EMail": f"{nx}@example.com", **ok})
    p = request(anon, "POST", f"{PHX}/api/account/register", body={"LoginName": px, "EMail": f"{px}@example.com", **ok})
    compare("register success (names normalized)", (n[0], n[1].replace(nx, "U")), (p[0], p[1].replace(px, "U")))

    for user, pw in [("test1", "test1"), ("testgm", "testgm"), ("test1", "wrong"), ("TEST1", "test1"), (nx, "password1"), (px, "password1")]:
        compare(f"login + session {user}/{pw}", session(login(NEXT, user, pw), NEXT), session(login(PHX, user, pw), PHX))
    compare("anonymous session", session(anon, NEXT), session(anon, PHX))

    cn, cp = login(NEXT, nx, "password1"), login(PHX, px, "password1")
    cp_cases = [
        {"oldPassword": "password1", "newPassword": "password1", "repeatNewPassword": "password1"},
        {"oldPassword": "password1", "newPassword": "password2", "repeatNewPassword": "password3"},
        {"oldPassword": "wrong123", "newPassword": "password2", "repeatNewPassword": "password2"},
        {}, {"oldPassword": 123, "newPassword": "password2", "repeatNewPassword": "password2"},
    ]
    for c in cp_cases:
        compare("changepassword " + json.dumps(c)[:70], request(cn, "PUT", f"{NEXT}/api/account/changepassword", body=c),
                request(cp, "PUT", f"{PHX}/api/account/changepassword", body=c))
    compare("changepassword invalid JSON", request(cn, "PUT", f"{NEXT}/api/account/changepassword", raw=b"x"),
            request(cp, "PUT", f"{PHX}/api/account/changepassword", raw=b"x"))
    for c in cp_cases[:1] + [{"oldPassword": "a", "newPassword": "b", "repeatNewPassword": "b"}]:
        compare("changepassword anonymous " + json.dumps(c)[:60], request(anon, "PUT", f"{NEXT}/api/account/changepassword", body=c),
                request(anon, "PUT", f"{PHX}/api/account/changepassword", body=c))
    change = {"oldPassword": "password1", "newPassword": "password2", "repeatNewPassword": "password2"}
    compare("changepassword success", request(cn, "PUT", f"{NEXT}/api/account/changepassword", body={"name": nx, **change}),
            request(cp, "PUT", f"{PHX}/api/account/changepassword", body={"name": px, **change}))
    # Cross-app: the Next.js-changed password works on Phoenix and vice versa.
    compare("new password of the Next.js account works on Phoenix", session(login(PHX, nx, "password2"), PHX).get("user", {}).get("username"), nx)
    compare("new password of the Phoenix account works on Next.js", session(login(NEXT, px, "password2"), NEXT).get("user", {}).get("username"), px)
    print(f"\nfailures: {failures}  (R1 — body `name` of another account — is an intended difference, not tested here)")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
