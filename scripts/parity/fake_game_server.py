#!/usr/bin/env python3
# Usage: fake_game_server.py [PLAYER_NAME ...]   (listens on 127.0.0.1:18080)
# Fake OpenMU admin /api/status (same body format and text/plain content type as OpenMU)
import http.server, json, sys
PLAYERS = sys.argv[1:] or ["test1Dk", "testgmDw", "test400Elf", "ghostName"]
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/status":
            body = json.dumps({"state": "Online", "players": len(PLAYERS), "playersList": PLAYERS}).encode()
            self.send_response(200); self.send_header("Content-Type", "text/plain; charset=utf-8")
        else:
            body = b"not found"; self.send_response(404)
        self.send_header("Content-Length", str(len(body))); self.end_headers(); self.wfile.write(body)
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(("127.0.0.1", 18080), H).serve_forever()
