-- Parity fixtures for a DISPOSABLE copy of the OpenMU DB (never run on `openmu`).
--   TEST_DB=openmu_parity ../setup_test_db.sh
--   docker exec -i database psql -U postgres -d openmu_parity -v ON_ERROR_STOP=1 < fixtures.sql
DO $$ BEGIN
  IF current_database() = 'openmu' THEN RAISE EXCEPTION 'refusing to run parity fixtures on openmu'; END IF;
END $$;

-- deterministic ranking: distinct levels / master levels / resets / kill counts
WITH r AS (SELECT c."Id", row_number() OVER (ORDER BY c."Name") n FROM data."Character" c)
UPDATE data."StatAttribute" sa SET "Value" = CASE sa."DefinitionId"
    WHEN '560931ad-0901-4342-b7f4-fd2e2fcc0563' THEN 10 + r.n * 5
    WHEN '89a891a7-f9f9-4ab5-af36-12056e53a5f7' THEN r.n % 4
    WHEN '70cd8c10-391a-4c51-9aa4-a854600e3a9f' THEN r.n * 3 END
FROM r WHERE sa."CharacterId" = r."Id" AND sa."DefinitionId" IN ('560931ad-0901-4342-b7f4-fd2e2fcc0563','89a891a7-f9f9-4ab5-af36-12056e53a5f7','70cd8c10-391a-4c51-9aa4-a854600e3a9f');
WITH r AS (SELECT "Id", row_number() OVER (ORDER BY "Name" DESC) n FROM data."Character")
UPDATE data."Character" c SET "PlayerKillCount" = r.n * 7 FROM r WHERE c."Id" = r."Id";
UPDATE data."Character" SET "CurrentMapId" = '00000300-0045-0000-0000-000000000000' WHERE "Name" = 'test1Dk';
UPDATE data."Character" SET "CurrentMapId" = NULL WHERE "Name" = 'test2Dk';

-- guilds (logo bytes, statuses 1-4)
INSERT INTO guild."Guild"("Id","Name","Logo","Score","Notice") VALUES
 ('11111111-1111-4111-8111-111111111111','Alpha',decode('0102ff','hex'),120,'hello'),
 ('22222222-2222-4222-8222-222222222222','Beta',NULL,80,NULL),
 ('33333333-3333-4333-8333-333333333333','Gamma',NULL,70,NULL);
INSERT INTO guild."GuildMember"("Id","GuildId","Status")
SELECT c."Id", g.gid, g.st FROM data."Character" c JOIN (VALUES
 ('testgmDk','11111111-1111-4111-8111-111111111111'::uuid,2),('test1Dk','11111111-1111-4111-8111-111111111111'::uuid,1),
 ('test2Dk','11111111-1111-4111-8111-111111111111'::uuid,3),('test3Dk','11111111-1111-4111-8111-111111111111'::uuid,4),
 ('test400Dw','22222222-2222-4222-8222-222222222222'::uuid,2)) g(name,gid,st) ON c."Name" = g.name;

-- news (one long body, multi-line bodies with repeated spaces)
INSERT INTO data."OpenMuWeb_News"(id,title,body,author,"creationDate")
SELECT ('aaaaaaaa-0000-4000-8000-00000000000'||g)::uuid, 'News '||g,
       CASE WHEN g=2 THEN repeat('Long body line. ', 30)||E'\nsecond line' ELSE 'Body of news '||g||E'\nwith   spaces' END,
       'testgmDk', timestamp '2026-09-20 10:00:00' + (g||' hours')::interval
FROM generate_series(1,6) g;
