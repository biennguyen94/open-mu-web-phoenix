#!/usr/bin/env python3
"""Page parity check: compares what users see on server-rendered pages of the
Next.js app and the Phoenix app — visible text (exact inside <p>, because of the
global `p { white-space: pre }` rule), link targets and image files.

Usage: page_parity.py [NEXT_BASE] [PHOENIX_BASE] [PATH ...]
Env:   PARITY_NEXT_COOKIE / PARITY_PHX_COOKIE — Cookie header to send (logged-in pages)

Known, intentional rendering differences are normalized (see normalize()):
  * link targets are not compared: Next.js used <button> + router.push where
    Phoenix renders <a href> (targets are covered by the ExUnit tests);
  * Next.js renders only the visible banner image; Phoenix pre-renders the second
    one hidden (`slider-img-2`);
  * the sidebar server status is fetched client-side by Next.js (its HTML always
    shows offline / 0) while Phoenix renders the real status server-side;
  * elements with the `hidden` attribute (LiveView connection flashes) are skipped.
"""
import difflib, os, re, sys, urllib.parse, urllib.request
from html.parser import HTMLParser

NEXT = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:4100"
PHX = sys.argv[2] if len(sys.argv) > 2 else "http://localhost:4101"
PATHS = sys.argv[3:] or ["/", "/info", "/download", "/terms-and-conditions"]


class Extract(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.tokens, self.skip, self.p_depth, self.buf = [], 0, 0, []
        self.hidden_depth = 0  # >0 while inside an element with the `hidden` attribute

    def flush(self):
        text = "".join(self.buf)
        self.buf = []
        if self.p_depth:
            if text:
                self.tokens.append("P:" + text)
        else:
            text = " ".join(text.split())
            if text:
                self.tokens.append("T:" + text)

    VOID = {"img", "br", "hr", "input", "meta", "link"}

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if self.hidden_depth:
            if tag not in self.VOID:
                self.hidden_depth += 1
            return
        if "hidden" in a and tag not in self.VOID:
            self.flush()
            self.hidden_depth = 1
            return
        if tag in ("script", "style", "template", "noscript"):
            self.skip += 1
            return
        if self.skip:
            return
        if tag in ("p", "a", "img", "br", "h1", "h2", "h3", "td", "th", "div", "button", "input", "span", "hr"):
            self.flush()
        if tag == "p":
            self.p_depth += 1
        if tag == "a" and a.get("href") is not None:
            self.tokens.append("A:" + a["href"])
        if tag == "img":
            src = a.get("src") or ""
            m = re.search(r"url=([^&]+)", src)
            if m:  # next/image URL -> original file name
                src = urllib.parse.unquote(m.group(1))
            name = re.sub(r"\.[0-9a-z_-]{8,}(\.\w+)$", r"\1", src.rsplit("/", 1)[-1])
            self.tokens.append("IMG:" + name)
        if tag == "input" and a.get("placeholder"):
            self.tokens.append("INPUT:" + a["placeholder"])

    def handle_endtag(self, tag):
        if self.hidden_depth:
            self.hidden_depth -= 1
            return
        if tag in ("script", "style", "template", "noscript"):
            self.skip = max(0, self.skip - 1)
            return
        if self.skip:
            return
        if tag in ("p", "a", "h1", "h2", "h3", "td", "th", "div", "button", "span"):
            self.flush()
        if tag == "p":
            self.p_depth = max(0, self.p_depth - 1)

    def handle_data(self, data):
        if not self.skip and not self.hidden_depth:
            self.buf.append(data)


def normalize(tokens):
    out = []
    for i, t in enumerate(tokens):
        if t.startswith("A:") or t == "IMG:slider-img-2.jpg":
            continue
        if t in ("IMG:online.png", "IMG:offline.png"):
            out.append("IMG:<server-status>")
            continue
        if i > 0 and tokens[i - 1] == "P:Online Users: ":
            out.append("P:<players>")
            continue
        out.append(t)
    return out


def tokens(base, path):
    req = urllib.request.Request(base + path)
    cookie = os.environ.get("PARITY_NEXT_COOKIE" if base == NEXT else "PARITY_PHX_COOKIE")
    if cookie:
        req.add_header("Cookie", cookie)
    with urllib.request.urlopen(req, timeout=60) as r:
        html = r.read().decode()
    body = html[html.find("<body"):]
    e = Extract()
    e.feed(body)
    e.flush()
    # The Next.js HTML embeds the client-only toast container; ignore empty artifacts.
    return normalize([t for t in e.tokens if t not in ("T:",)])


def main():
    diffs = 0
    for path in PATHS:
        n, p = tokens(NEXT, path), tokens(PHX, path)
        if n == p:
            print(f"OK    {path} ({len(n)} tokens)")
        else:
            diffs += 1
            print(f"DIFF  {path}")
            for line in difflib.unified_diff(n, p, "next", "phoenix", lineterm="", n=1):
                print("   ", line[:160])
    sys.exit(1 if diffs else 0)


if __name__ == "__main__":
    main()
