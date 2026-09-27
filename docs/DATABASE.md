# Database

> **The OpenMU database is an existing database shared with the running OpenMU game server.**
> It is created and migrated by OpenMU (EF Core, `public."__EFMigrationsHistory"`).
> **Never** drop, reset, truncate or migrate OpenMU tables. No `mix ecto.drop`, `mix ecto.reset`, `prisma db push`, `prisma migrate`.
>
> Labels: **VERIFIED** = checked against the live DB (read-only) or a disposable clone on 2026-09-27. **NOT VERIFIED** = not checked. **ASSUMPTION** = reasoned, not proven.

## 0. Environment (VERIFIED 2026-09-27)

- Docker container `database`: PostgreSQL **18.6**, DB `openmu`, user `postgres`, host port **5433** (and 32768) → 5432.
- `openmu-startup` (image `munique/openmu`) and `nginx-80` use the same DB.
- EF Core migrations applied: **48**, latest `20260723073950_CascadeDeleteMiniGameRankingEntries`, ProductVersion `10.0.2`.
- Content is **OpenMU default test data** (created 2026-09-25): 20 accounts, 76 characters, 0 guilds, 0 news. It is a development DB, not real player data (ASSUMPTION: production will have the same schema version).
- Read-only access used: `PGOPTIONS='-c default_transaction_read_only=on'`.
- Disposable clone used for write tests: `openmu_phase0` (`CREATE DATABASE openmu_phase0 TEMPLATE openmu`). It **contains test modifications** and is not a clean fixture.
- Reference schema dump: `docs/db/openmu_schema.sql` (`pg_dump --schema-only --no-owner --no-privileges`, 104 tables).

## 1. Schemas and table counts

| Schema | Tables in DB (VERIFIED) | Prisma models | Used by website |
|---|---|---|---|
| `config` | **81** | 77 | None queried. Only referenced via hard-coded UUIDs. |
| `data` | 19 (18 OpenMU + `OpenMuWeb_News`) | 19 | Account, Character, StatAttribute, ItemStorage, OpenMuWeb_News |
| `friend` | 1 | 1 | Not used |
| `guild` | 2 | 2 | Guild, GuildMember |
| `public` | 1 (`__EFMigrationsHistory`) | 1 | Not used |

**Schema drift (VERIFIED)**: `prisma/schema.prisma` is older than the DB.
- Tables only in DB: `config.AreaSkillSettings`, `config.Buff`, `config.DuelArea`, `config.DuelConfiguration`.
- Extra columns in used tables (all have defaults, so current inserts still work):
  - `data."Account"`: `IsTemplate boolean NOT NULL DEFAULT false`, `LanguageIsoCode varchar(3) NOT NULL DEFAULT 'en'`, `IsBot boolean NOT NULL DEFAULT false`.
  - `data."Character"`: `IsStoreOpened boolean NOT NULL DEFAULT false`, `StoreName text NULL`.
- Use `docs/db/openmu_schema.sql`, not `prisma/schema.prisma`, as the reference for Ecto.

## 2. Tables used by the website

| Prisma model | Schema.Table | Owner | Used by |
|---|---|---|---|
| `Account` | data.`Account` | OpenMU | login, register, change password, `/characters` JOIN |
| `Character` | data.`Character` | OpenMU | ownership/GM checks, rankings, online list, all character operations, guild members |
| `StatAttribute` | data.`StatAttribute` | OpenMU | rankings, `/characters`, addstats, reset, resetStats |
| `ItemStorage` | data.`ItemStorage` | OpenMU | `Money` (zen) via `Character.InventoryId`; reset, pkclear, resetStats |
| `Guild` | guild.`Guild` | OpenMU | sidebar top 5, `/api/guilds` top 30 |
| `GuildMember` | guild.`GuildMember` | OpenMU | `/api/guilds/[guildName]` (`GuildMember.Id` = `Character.Id`) |
| `OpenMuWeb_News` | data.`OpenMuWeb_News` | **Website** | news list/detail, admin add/delete |

### Column definitions (VERIFIED with `\d`)

`data."Account"`: `Id uuid PK`, `VaultId uuid NULL UNIQUE → ItemStorage`, `LoginName varchar(10) NOT NULL UNIQUE`, `PasswordHash text`, `SecurityCode text`, `EMail text` (**no unique index**), `RegistrationDate timestamptz`, `State int`, `TimeZone smallint`, `VaultPassword text`, `IsVaultExtended bool`, `ChatBanUntil timestamptz NULL`, `IsTemplate bool def false`, `LanguageIsoCode varchar(3) def 'en'`, `IsBot bool def false`. No DB defaults for `Id`/`RegistrationDate` (app must set them).

`data."Character"`: `Id uuid PK`, `CharacterClassId uuid NOT NULL → config.CharacterClass`, `CurrentMapId uuid NULL → config.GameMapDefinition`, `InventoryId uuid NULL UNIQUE → ItemStorage`, `AccountId uuid NULL → Account (CASCADE)`, `Name varchar(10) UNIQUE`, `CharacterSlot smallint`, `CreateDate timestamptz`, `Experience bigint`, `MasterExperience bigint`, `LevelUpPoints int`, `MasterLevelUpPoints int`, `PositionX smallint`, `PositionY smallint`, `PlayerKillCount int`, `StateRemainingSeconds int`, `State int`, `CharacterStatus int`, `Pose smallint`, `UsedFruitPoints int`, `UsedNegFruitPoints int`, `InventoryExtensions int`, `KeyConfiguration bytea NULL`, `MuHelperConfiguration bytea NULL`, `IsStoreOpened bool def false`, `StoreName text NULL`.

`data."StatAttribute"`: `Id uuid PK`, `DefinitionId uuid NULL → config.AttributeDefinition`, `CharacterId uuid NULL → Character (CASCADE)`, `Value real NOT NULL`, `AccountId uuid NULL`. **No unique constraint** on (CharacterId, DefinitionId). Character level is stored here (Level attribute).

`data."ItemStorage"`: `Id uuid PK`, `Money integer NOT NULL`.

`guild."Guild"`: `Id uuid PK`, `HostilityId uuid NULL`, `AllianceGuildId uuid NULL`, `Name varchar(8) UNIQUE`, `Logo bytea NULL`, `Score int`, `Notice text NULL`.

`guild."GuildMember"`: `Id uuid PK → data.Character (CASCADE)`, `GuildId uuid → Guild (CASCADE)`, `Status smallint`.

`data."OpenMuWeb_News"` (VERIFIED exists, matches README DDL; PK constraint name `OpenMuWeb_News_pkey`):

```sql
id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
title text NOT NULL, body text NOT NULL, author text NOT NULL,
"creationDate" timestamp(3) without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
```

`author` is filled with the **GM character name** (VERIFIED: news created by test showed `author = testgm2Sum`).

### Data facts (VERIFIED on dev data)

- Every character (76/76) has `Resets`, `Level`, `Base Strength` rows; `Master Level` rows exist only for 12 characters (master classes); `Base Leadership` rows only for Dark Lord (16) and Lord Emperor (2).
- No duplicate (CharacterId, DefinitionId) pairs.
- Every character has `InventoryId` and `AccountId`.
- All 20 existing password hashes start with **`$2a$`** (OpenMU); accounts registered by the website get **`$2b$10$`**.
- `CharacterStatus` values present: `0` (69) and `32` (7; accounts `testgm` ×5, `testgm2` ×2). `State` = 0 for all.
- Test accounts use `EMail = ''`.

## 3. Hard-coded UUIDs

### StatAttribute `DefinitionId` — VERIFIED (config."AttributeDefinition"."Designation")

| Meaning | UUID | Designation in DB |
|---|---|---|
| Resets | `89a891a7-f9f9-4ab5-af36-12056e53a5f7` | `Resets` |
| Level | `560931ad-0901-4342-b7f4-fd2e2fcc0563` | `Level` |
| Master Level | `70cd8c10-391a-4c51-9aa4-a854600e3a9f` | `Master Level` |
| Strength | `123282fe-fead-448e-ad2c-baece939b4b1` | `Base Strength` |
| Agility | `1ae9c014-e3cd-4703-bd05-1b65f5f94ceb` | `Base Agility` |
| Vitality | `6ca5c3a6-b109-45a5-87a7-fdcb107b4982` | `Base Vitality` |
| Energy | `01b0ef28-f7a0-46b5-97ba-2b624a54cd75` | `Base Energy` |
| Leadership | `6af2c9df-3ae4-4721-8462-9a8ec7f56fe4` | `Base Leadership` |

### Game Master

- `Character.CharacterStatus = 32` ⇒ GM. VERIFIED in data (only `testgm*` accounts have 32) and in OpenMU source (`CharacterStatus { Normal = 0, Banned = 1, GameMaster = 32 }`, `src/DataModel/Entities/Character.cs`).
- `GuildMember.Status` = OpenMU `GuildPosition` (VERIFIED, `src/Interfaces/GuildPosition.cs`): 0 Undefined, 1 NormalMember, 2 GuildMaster, 3 BattleMaster, 4 AssistantMaster.
- `Character.State` = OpenMU `HeroState` (VERIFIED, same file): 0 New, 1 Hero, 2 LightHero, 3 Normal, 4 PlayerKillWarning, 5 PlayerKiller1stStage, 6 PlayerKiller2ndStage (see RISKS B14).

### Character classes — VERIFIED (config."CharacterClass", all 18 rows)

| UUID | Number | DB Name | Master class | Creatable | Avatar |
|---|---|---|---|---|---|
| `00000040-0000-0000-0000-000000000000` | 0 | Dark Wizard | f | t | dw |
| `00000040-0002-0000-0000-000000000000` | 2 | Soul Master | f | f | dw |
| `00000040-0003-0000-0000-000000000000` | 3 | Grand Master | t | f | dw |
| `00000040-0004-0000-0000-000000000000` | 4 | Dark Knight | f | t | dk |
| `00000040-0006-0000-0000-000000000000` | 6 | Blade Knight | f | f | dk |
| `00000040-0007-0000-0000-000000000000` | 7 | Blade Master | t | f | dk |
| `00000040-0008-0000-0000-000000000000` | 8 | Fairy Elf | f | t | elf |
| `00000040-000a-0000-0000-000000000000` | 10 | Muse Elf | f | f | elf |
| `00000040-000b-0000-0000-000000000000` | 11 | High Elf | t | f | elf |
| `00000040-000c-0000-0000-000000000000` | 12 | Magic Gladiator | f | t | mg |
| `00000040-000d-0000-0000-000000000000` | 13 | Duel Master | t | f | mg |
| `00000040-0010-0000-0000-000000000000` | 16 | Dark Lord | f | t | dl |
| `00000040-0011-0000-0000-000000000000` | 17 | Lord Emperor | t | f | dl |
| `00000040-0014-0000-0000-000000000000` | 20 | Summoner | f | t | sum |
| `00000040-0016-0000-0000-000000000000` | 22 | Bloody Summoner | f | f | sum |
| `00000040-0017-0000-0000-000000000000` | 23 | Dimension Master | t | f | sum |
| `00000040-0018-0000-0000-000000000000` | 24 | Rage Fighter | f | t | rf |
| `00000040-0019-0000-0000-000000000000` | 25 | Fist Master | t | f | rf |

The DB has exactly these 18 classes, so `getImage` covers every class in this DB.
Groups used by code: Leadership UI = `0010`, `0011`; reset → Noria = `0008`, `000a`, `000b`; reset → Elbeland = `0014`, `0016`, `0017`.

### Base stats per creatable class — VERIFIED (config."StatAttributeDefinition"."BaseValue")

| Class | Str | Agi | Vit | Ene | Lead |
|---|---|---|---|---|---|
| Dark Wizard | 18 | 18 | 15 | 30 | — |
| Dark Knight | 28 | 20 | 25 | 10 | — |
| Fairy Elf | 22 | 25 | 20 | 15 | — |
| Magic Gladiator | 26 | 26 | 26 | 26 | — |
| Dark Lord | 26 | 20 | 20 | 15 | 25 |
| Summoner | 21 | 21 | 18 | 23 | — |
| Rage Fighter | 32 | 27 | 25 | 20 | — |

⇒ The current Reset Stats rule (every stat = 20) differs from OpenMU base values. Kept by decision D2; discrepancy tracked as B3.

### Maps — VERIFIED (config."GameMapDefinition")

| Map | UUID | Number | DB Name | Reset position |
|---|---|---|---|---|
| Lorencia | `00000300-0000-0000-0000-000000000000` | 0 | Lorencia | 141, 121 |
| Noria | `00000300-0003-0000-0000-000000000000` | 3 | Noria | 176, 116 |
| Elbeland | `00000300-0033-0000-0000-000000000000` | 51 | Elvenland | 51, 226 |

`app/_utils/mapEnum.ts` (73 entries): all 73 UUIDs exist in DB and the DB has no map outside the enum. 10 names differ only cosmetically (e.g. enum `KanturuI` vs DB `Kanturu_I`, `SilentMap` vs `Silent Map?`, `FortressGuardian2` vs `Fortress of Imperial Guardian 2`). Keep the enum names for UI parity (or read DB names — cosmetic decision). Whether the reset spawn coordinates are valid walkable positions is NOT VERIFIED in-game.

## 4. Queries (exact current behavior)

### Character ranking (sidebar LIMIT 10, `/api/characters/ranking/reset` LIMIT 50) — VERIFIED output shape

```sql
SELECT sa."CharacterId", c."Name", c."CharacterClassId",
  MAX(CASE WHEN sa."DefinitionId" = '<Resets>'      THEN sa."Value" ELSE 0 END) AS resets,
  MAX(CASE WHEN sa."DefinitionId" = '<Level>'       THEN sa."Value" ELSE 0 END) AS lvl,
  MAX(CASE WHEN sa."DefinitionId" = '<MasterLevel>' THEN sa."Value" ELSE 0 END) AS masterlvl
FROM data."StatAttribute" sa
INNER JOIN data."Character" c ON sa."CharacterId" = c."Id"
GROUP BY sa."CharacterId", c."Name", c."CharacterClassId"
ORDER BY resets DESC, lvl DESC, masterlvl DESC
LIMIT 10 | 50;
```

GM characters are included (VERIFIED: `testgmDk` ranks first). Ties beyond the three keys have no deterministic order (ASSUMPTION: Phoenix output may differ from Next.js for fully tied rows).

### Top killers — `SELECT "Id","CharacterClassId","CurrentMapId","Name","PlayerKillCount" FROM data."Character" ORDER BY "PlayerKillCount" DESC LIMIT 30` (all kill counts are 0 in dev data → order undetermined).

### Characters panel (`app/characters/page.tsx`)

Same pivot for 8 definitions **without `ELSE 0`** (missing ⇒ NULL, e.g. Master Level for non-master classes, Leadership for non-DL), joined with `data."Account"` on `LoginName = <session username>`, `WHERE DefinitionId IN (8 ids)`, `GROUP BY c."Name", c."CharacterClassId", c."LevelUpPoints", c."MasterLevelUpPoints"`. VERIFIED: `/characters` as `test1` lists `test1Dk`, `test1Dl`, `test1Dw`, `test1Elf`.

### Others

- Online: `Name IN playersList` → `Name, CurrentMapId, CharacterClassId, PositionX, PositionY` (VERIFIED returns `[]` for empty/offline list).
- Guild top: `findMany({ take: 5 | 30, orderBy: Score desc })` (VERIFIED `[]`; no guild data exists).
- Guild members: VERIFIED 400 path only (no guilds).
- News list: `skip page*4, take 4, orderBy creationDate desc`; News detail `findFirst({ id })`.
- Character writes: `FEATURES.md`.

## 5. Ecto strategy (PROPOSAL for Phase 1+)

- Repo points at the existing DB. Remove `ecto.setup`/`ecto.reset` aliases generated by `phx.new`. Never run `ecto.create/drop/reset` against `openmu`.
- `migration_source: "openmu_web_schema_migrations"` so Ecto never touches `__EFMigrationsHistory`.
- Only allowed migration: `CREATE TABLE IF NOT EXISTS data."OpenMuWeb_News" (...)` identical to §2.
- Schemas declare only needed columns; `@schema_prefix "data"` / `"guild"`; `source:` for PascalCase columns:

  ```elixir
  @schema_prefix "data"
  @primary_key {:id, :binary_id, autogenerate: false, source: :Id}
  schema "Character" do
    field :name, :string, source: :Name
    field :level_up_points, :integer, source: :LevelUpPoints
  end
  ```

- Types: `uuid` → `:binary_id`; `timestamptz` → `:utc_datetime_usec`; News `creationDate` `timestamp(3)` → `:naive_datetime_usec` with DB default (`read_after_writes: true`); `real` → `:float`; `bigint` → `:integer`; `bytea` → `:binary` (do not load `Guild.Logo` unless needed).
- Account insert must set `Id` (`Ecto.UUID.generate()`) and `RegistrationDate` (no DB default); leave `IsTemplate`/`LanguageIsoCode`/`IsBot` to DB defaults (matches current behavior, VERIFIED: `false`/`en`/`false`).
- Rankings via `fragment("MAX(CASE WHEN ? = ? THEN ? ELSE 0 END)", ...)`; keep GROUP BY/ORDER BY/LIMIT; no `ELSE` for characters panel.
- Writes: `update_all` with `join` (`UPDATE ... FROM`) and `inc:`.
- Transactions: `Ecto.Multi` with `SELECT ... FOR UPDATE` on Character and ItemStorage, conditions re-checked inside the transaction, rollback when an update affects 0 rows (fixes R5; same results for non-concurrent requests).
- **Test database** (implemented in Phase 1): schema-only is **not enough** — FKs require `config` rows (CharacterClass, AttributeDefinition, GameMapDefinition). `phoenix/scripts/setup_test_db.sh` recreates `open_mu_web_test` as a full `pg_dump` copy of `openmu` (source only read); tests run inside the Ecto SQL sandbox and refuse `openmu`.
- **Implemented in Phase 1**: `migration_source`, blocked destructive Ecto tasks, migration `20260927000000_ensure_openmu_web_news.exs`, no `CheckRepoStatus`.
