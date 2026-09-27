# Features

## Feature list (current app)

1. **Public pages**: Home/News (paginated, 4 per page), news detail, Info (static), Download (env links), Terms (static), banner slider (2 images, auto-advance 5 s + click), Discord link, footer.
2. **Sidebar on every page**: Server Statistics (online/offline + online count), Characters Ranking top 10, Guilds Ranking top 5.
3. **Rankings** (`/ranking`): Top Characters (resets → level → master level, top 50), Top Killers (top 30), Top Guilds (top 30, member popup on hover), Online Players (map + position).
4. **Account**: Register (with Terms checkbox), Login, Logout, Change Password.
5. **Characters panel** (`/characters`): per character — avatar, Resets, Level, Master Level; actions Add Stats, Reset, Reset Stats, PK Clear.
6. **Admin (Game Master)**: add news (`/admin/news`), delete news (button on news cards).
7. **UX**: toasts (react-toastify), MU cursors, Lora font, Tailwind theme colors.
8. **Not implemented** (despite links/assets/README): password recovery (`/recoverpassword` 404), donate (`donate.png` unused), "Top Level" / "Top Master Level" are not separate rankings (single combined ordering).

Detailed page behavior: `ROUTES.md`. Endpoint contracts: `API.md`.

## Character operations (exact current behavior)

Runtime status (2026-09-27, disposable DB clone): Add Stats, Reset, Reset Stats, PK Clear, Change Password **VERIFIED** as described below (see `RISKS.md` for the exploit reproductions). The online-player rejection path is NOT VERIFIED (no player online). In Phoenix: game rules unchanged (D2), security fixes R1–R6 applied (D1).

Shared pre-steps for Add Stats / Reset / Reset Stats / PK Clear:

1. Session required; `name` must be in `character.findMany({ AccountId: session.user.id })` names (see `AUTH.md` about `session.user.id`).
2. Online check: server fetches `${NEXT_PUBLIC_URL}/api/status`; character in `playersList` → reject; status unreachable → reject (500).
3. Conditions are checked **outside** the transaction. Writes use Prisma batch `$transaction([...])` (one DB transaction, default Read Committed). Affected-row counts are **not** checked.

"Zen" = `data."ItemStorage"."Money"` of the character's inventory (`ItemStorage` related through `Character.InventoryId`).

### Add Stats — `app/api/characters/addstats/route.ts`

```text
Input   { name, str, agi, vit, ene, lead }        (UI sends numbers; lead is 0 unless DL/LE class)
  ↓ total = str + agi + vit + ene + lead
Validate  ownership, online, Character.LevelUpPoints >= total
          (NO check for negative, non-integer or non-numeric values)
  ↓ TX:
    UPDATE StatAttribute SET Value = Value + str  WHERE Character.Name = name AND DefinitionId = Strength
    ... same for Agility (agi), Vitality (vit), Energy (ene), Leadership (lead)
    UPDATE Character SET LevelUpPoints = LevelUpPoints - total WHERE Name = name
Response 200 "Character points added succesfuly"
```

If a stat row does not exist (e.g. Leadership on non-DL), its update affects 0 rows but points are still deducted.

### Reset — `app/api/characters/reset/route.ts`

```text
Disabled if NEXT_PUBLIC_ZEN_TO_RESET empty (400 "Function disabled")
Input   { name, clasId }      clasId comes from the client (UI passes the DB CharacterClassId)
  ↓ target map from clasId:
      elf classes 0008/000a/000b      → Noria    00000300-0003-…  (176, 116)
      summoner classes 0014/0016/0017 → Elbeland 00000300-0033-…  (51, 226)
      anything else                   → Lorencia 00000300-0000-…  (141, 121)
Validate  ownership, online
          COUNT(StatAttribute of name WHERE (Level >= LVL_TO_RESET) OR (Resets < MAX_RESET)) must equal 2
          ItemStorage.Money >= NEXT_PUBLIC_ZEN_TO_RESET
  ↓ TX:
    UPDATE ItemStorage SET Money = Money - zen WHERE Character.Name = name AND Money >= zen
    UPDATE data."StatAttribute" sa SET "Value" = CASE
        WHEN DefinitionId = Resets THEN Value + 1
        WHEN DefinitionId = Level  THEN 1
        ELSE Value END
      FROM data."Character" c WHERE sa."CharacterId" = c."Id" AND c."Name" = name
    UPDATE Character SET CurrentMapId, PositionX, PositionY WHERE Name = name
Response 200 "Character reseted successfully!"
```

Not changed by reset: `Experience`, `MasterExperience`, `LevelUpPoints`, stats, master level.
A character without a Resets attribute row cannot reset (count would be ≤ 1); VERIFIED every character in the dev DB has Resets and Level rows.
VERIFIED example: `test400Dk` (Blade Master, Level 400, Resets 0, Money 10,000,000) → Level 1, Resets 1, Money 9,000,000, Lorencia (141,121); Experience and LevelUpPoints unchanged. Ineligible `test1Dk` (Level 11) → 400 "You aren't lvl 400 or you are at maximum reset 6".

### Reset Stats — `app/api/characters/resetStats/route.ts`

```text
Disabled if NEXT_PUBLIC_ZEN_TO_RESET_STATS empty
Input   { name, clasId }     (clasId unused)
Validate  ownership, online
  ↓ read StatAttribute rows of name for Str/Agi/Vit/Ene/Leadership
  ↓ points = Σ (Value − 20)                  (fixed base 20 for every class and stat)
Validate  ItemStorage.Money >= zen
  ↓ TX:
    UPDATE StatAttribute SET Value = 20 WHERE Character.Name = name AND DefinitionId IN (5 stats)
    UPDATE Character SET LevelUpPoints = LevelUpPoints + points WHERE Name = name
    UPDATE ItemStorage SET Money = Money - zen WHERE Character.Name = name   (no Money >= zen guard)
Response 200 "Points were reseted succesffuly"
```

VERIFIED example: Dark Wizard `test1Dw` Str/Agi/Vit/Ene 18/18/15/30 → 20/20/20/20, LevelUpPoints 50 → 51, Money −1,000,000. OpenMU base values per class differ from 20 (`DATABASE.md` §3) — discrepancy B3, kept by D2.

### PK Clear — `app/api/characters/pkclear/route.ts`

```text
Disabled if NEXT_PUBLIC_ZEN_TO_PKCLEAR empty
Input   { name }
Validate  ownership, online, ItemStorage.Money >= zen
  ↓ TX:
    UPDATE ItemStorage SET Money = Money - zen WHERE Character.Name = name   (no guard)
    UPDATE Character SET State = 0, StateRemainingSeconds = 0 WHERE Name = name
Response 200 "PkClear successfully"
```

`PlayerKillCount` is not changed (top killers ranking unaffected).

### Change Password — `app/api/account/changepassword/route.ts`

```text
Input   { name, oldPassword, newPassword, repeatNewPassword }
Validate  old ≠ new; new = repeat; bcrypt.compare(old, hash of SESSION account)
  ↓ UPDATE Account SET PasswordHash = bcrypt(new, 10) WHERE LoginName = name   ← name from request body
Response 200 "Password changes successfully" (even when 0 rows updated)
```

Client (`app/account/page.tsx`) sends `name` from React state that is set asynchronously right before the fetch, so the first submission sends `name: ""` (0 rows updated, success toast, form cleared). See `RISKS.md` R1.

### Character selection / info

No selection step. `/characters` lists every character of the logged-in account (queried by `LoginName`), each as a card; clicking "Add Stats" toggles one accordion panel (only one open at a time). Info shown: name, avatar by class, Resets, Lvl, Master Lvl, Free Points (`LevelUpPoints`), Strength, Agility, Vitality, Energy, Leadership (DL/LE only). `MasterLevelUpPoints` is queried but not displayed.

### Admin news

- Add: GM check from DB → insert with `author` = first GM character's name. No server-side validation (client maxLength title 200, body 3000).
- Delete: GM check → delete by id; client shows confirmation dialog then `router.refresh()`.

## Phoenix implementation (Phase 4)

- `OpenMuWeb.Characters` (`list_for_account/1`, `add_stats/3`, `pk_clear/2`, `reset/2`, `reset_stats/2`) is used by both `/characters` (`CharactersLive`) and `/api/characters/*` (`Api.CharacterController`); messages / statuses per route in `OpenMuWebWeb.CharacterMessages`.
- Game rules identical (D2): verified by running the same sequence on two identical DB copies (`phoenix/scripts/parity/char_parity.py`) — same responses, same final state for all 76 characters except the security-fix cases.
- Security fixes: R2 (integer >= 0 amounts), R3 (character must belong to the logged-in account), R4 (reset location from the DB class), R5 (transaction + `FOR UPDATE`, checks inside).
- Kept on purpose: B3 (reset stats base 20), B4 (reset keeps Experience / LevelUpPoints), B5 (Leadership points spent without a Leadership row), B14 (PK clear sets `State = 0` = HeroState.New).
- UI differences: cards ordered by `CharacterSlot` (Next.js order was arbitrary — same cards as a set); the page requires login (Next.js showed "no characters"); after any successful operation the data is reloaded (Next.js left the Add Stats values stale after closing the card).
