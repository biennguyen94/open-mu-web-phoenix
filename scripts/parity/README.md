# Parity checks (Next.js vs Phoenix)

Run both apps against the same **disposable** DB copy and the same (fake) game server, then compare.

```bash
# 1. DB copy + fixtures (never on `openmu`)
TEST_DB=openmu_parity ../setup_test_db.sh
docker exec -i database psql -U postgres -d openmu_parity -v ON_ERROR_STOP=1 < fixtures.sql

# 2. Fake OpenMU status endpoint (text/plain JSON like OpenMU) on 127.0.0.1:18080
./fake_game_server.py test1Dk testgmDw test400Elf ghostName &

# 3. Next.js on :4100 and Phoenix on :4101, both on openmu_parity
#    (DATABASE_URL = the .env URL with the database replaced by openmu_parity)
#    repo root:  DATABASE_URL=... NEXT_PUBLIC_URL=http://localhost:4100 NEXTAUTH_URL=http://localhost:4100 \
#                GAMESERVER_URL=http://localhost:18080 npx next dev -p 4100
#    phoenix/:   DATABASE_URL=... GAMESERVER_URL=http://localhost:18080 PORT=4101 mix phx.server

# 4. Compare
./api_parity.py
./auth_parity.py        # register / login / session / change password (creates accounts)
./page_parity.py http://localhost:4100 http://localhost:4101 / "/?page=1" /info /download /terms-and-conditions
```

Expected differences are documented in `../../../docs/PORTING_STATUS.md` (R10, B2, rendering-only items).
