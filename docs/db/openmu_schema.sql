--
-- PostgreSQL database dump
--

\restrict MTy73cPha2c8Hec9OELVAOzRBvfD0a0NEwPzcIV2x5TdjQfa2IoEsImxy8A7zO7

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
-- Dumped by pg_dump version 18.6 (Debian 18.6-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: config; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA config;


--
-- Name: data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA data;


--
-- Name: friend; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA friend;


--
-- Name: guild; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA guild;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AreaSkillSettings; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."AreaSkillSettings" (
    "Id" uuid NOT NULL,
    "UseFrustumFilter" boolean NOT NULL,
    "FrustumStartWidth" real NOT NULL,
    "FrustumEndWidth" real NOT NULL,
    "FrustumDistance" real NOT NULL,
    "UseTargetAreaFilter" boolean NOT NULL,
    "TargetAreaDiameter" real NOT NULL,
    "UseDeferredHits" boolean NOT NULL,
    "DelayPerOneDistance" interval NOT NULL,
    "DelayBetweenHits" interval NOT NULL,
    "MinimumNumberOfHitsPerTarget" integer NOT NULL,
    "MaximumNumberOfHitsPerTarget" integer NOT NULL,
    "MaximumNumberOfHitsPerAttack" integer NOT NULL,
    "HitChancePerDistanceMultiplier" real NOT NULL,
    "ProjectileCount" integer DEFAULT 1 NOT NULL,
    "EffectRange" integer DEFAULT 0 NOT NULL,
    "MinimumNumberOfHitsPerAttack" integer DEFAULT 0 NOT NULL
);


--
-- Name: AttributeDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."AttributeDefinition" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Designation" text,
    "Description" text,
    "MaximumValue" real
);


--
-- Name: AttributeRelationship; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."AttributeRelationship" (
    "Id" uuid NOT NULL,
    "TargetAttributeId" uuid,
    "InputAttributeId" uuid,
    "CharacterClassId" uuid,
    "PowerUpDefinitionValueId" uuid,
    "InputOperator" integer NOT NULL,
    "InputOperand" real NOT NULL,
    "OperandAttributeId" uuid,
    "AggregateType" integer DEFAULT 0 NOT NULL,
    "SkillId" uuid,
    "GameConfigurationId" uuid
);


--
-- Name: AttributeRequirement; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."AttributeRequirement" (
    "Id" uuid NOT NULL,
    "AttributeId" uuid,
    "GameMapDefinitionId" uuid,
    "ItemDefinitionId" uuid,
    "SkillId" uuid,
    "SkillId1" uuid,
    "MinimumValue" integer NOT NULL
);


--
-- Name: BattleZoneDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."BattleZoneDefinition" (
    "Id" uuid NOT NULL,
    "GroundId" uuid,
    "LeftGoalId" uuid,
    "RightGoalId" uuid,
    "Type" integer NOT NULL,
    "LeftTeamSpawnPointX" smallint,
    "LeftTeamSpawnPointY" smallint NOT NULL,
    "RightTeamSpawnPointX" smallint,
    "RightTeamSpawnPointY" smallint NOT NULL
);


--
-- Name: Buff; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."Buff" (
    "Id" uuid NOT NULL,
    "MagicEffectDefinitionId" uuid,
    "MonsterDefinitionId" uuid,
    "MinimumLevel" integer,
    "MaximumLevel" integer
);


--
-- Name: CharacterClass; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."CharacterClass" (
    "Id" uuid NOT NULL,
    "NextGenerationClassId" uuid,
    "HomeMapId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Name" text NOT NULL,
    "CanGetCreated" boolean NOT NULL,
    "LevelRequirementByCreation" smallint NOT NULL,
    "CreationAllowedFlag" smallint NOT NULL,
    "IsMasterClass" boolean NOT NULL,
    "LevelWarpRequirementReductionPercent" integer NOT NULL,
    "FruitCalculation" integer NOT NULL,
    "ComboDefinitionId" uuid
);


--
-- Name: ChatServerDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ChatServerDefinition" (
    "Id" uuid NOT NULL,
    "ServerId" smallint NOT NULL,
    "Description" text NOT NULL,
    "MaximumConnections" integer NOT NULL,
    "ClientTimeout" interval NOT NULL,
    "ClientCleanUpInterval" interval NOT NULL,
    "RoomCleanUpInterval" interval NOT NULL
);


--
-- Name: ChatServerEndpoint; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ChatServerEndpoint" (
    "Id" uuid NOT NULL,
    "ClientId" uuid,
    "ChatServerDefinitionId" uuid,
    "NetworkPort" integer NOT NULL
);


--
-- Name: CombinationBonusRequirement; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."CombinationBonusRequirement" (
    "Id" uuid NOT NULL,
    "OptionTypeId" uuid,
    "ItemOptionCombinationBonusId" uuid,
    "SubOptionType" integer NOT NULL,
    "MinimumCount" integer NOT NULL
);


--
-- Name: ConfigurationUpdate; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ConfigurationUpdate" (
    "Id" uuid NOT NULL,
    "Version" integer NOT NULL,
    "Name" text DEFAULT ''::text NOT NULL,
    "Description" text DEFAULT ''::text NOT NULL,
    "CreatedAt" timestamp with time zone,
    "InstalledAt" timestamp with time zone
);


--
-- Name: ConfigurationUpdateState; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ConfigurationUpdateState" (
    "Id" uuid NOT NULL,
    "InitializationKey" text,
    "CurrentInstalledVersion" integer NOT NULL
);


--
-- Name: ConnectServerDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ConnectServerDefinition" (
    "Id" uuid NOT NULL,
    "ClientId" uuid,
    "ServerId" smallint NOT NULL,
    "Description" text NOT NULL,
    "DisconnectOnUnknownPacket" boolean NOT NULL,
    "MaximumReceiveSize" smallint NOT NULL,
    "ClientListenerPort" integer NOT NULL,
    "Timeout" interval NOT NULL,
    "CurrentPatchVersion" bytea,
    "PatchAddress" text NOT NULL,
    "MaxConnectionsPerAddress" integer NOT NULL,
    "CheckMaxConnectionsPerAddress" boolean NOT NULL,
    "MaxConnections" integer NOT NULL,
    "ListenerBacklog" integer NOT NULL,
    "MaxFtpRequests" integer NOT NULL,
    "MaxIpRequests" integer NOT NULL,
    "MaxServerListRequests" integer NOT NULL
);


--
-- Name: ConstValueAttribute; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ConstValueAttribute" (
    "Id" uuid NOT NULL,
    "DefinitionId" uuid,
    "CharacterClassId" uuid,
    "Value" real NOT NULL,
    "GameConfigurationId" uuid
);


--
-- Name: DropItemGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."DropItemGroup" (
    "Id" uuid NOT NULL,
    "MonsterId" uuid,
    "GameConfigurationId" uuid,
    "Description" text NOT NULL,
    "Chance" double precision NOT NULL,
    "MinimumMonsterLevel" smallint,
    "MaximumMonsterLevel" smallint,
    "ItemLevel" smallint,
    "ItemType" integer NOT NULL
);


--
-- Name: DropItemGroupItemDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."DropItemGroupItemDefinition" (
    "DropItemGroupId" uuid NOT NULL,
    "ItemDefinitionId" uuid NOT NULL
);


--
-- Name: DuelArea; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."DuelArea" (
    "Id" uuid NOT NULL,
    "FirstPlayerGateId" uuid,
    "SecondPlayerGateId" uuid,
    "SpectatorsGateId" uuid,
    "DuelConfigurationId" uuid,
    "Index" smallint NOT NULL
);


--
-- Name: DuelConfiguration; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."DuelConfiguration" (
    "Id" uuid NOT NULL,
    "ExitId" uuid,
    "MaximumScore" integer NOT NULL,
    "EntranceFee" integer NOT NULL,
    "MinimumCharacterLevel" integer NOT NULL,
    "MaximumSpectatorsPerDuelRoom" integer NOT NULL
);


--
-- Name: EnterGate; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."EnterGate" (
    "Id" uuid NOT NULL,
    "TargetGateId" uuid,
    "GameMapDefinitionId" uuid,
    "X1" smallint NOT NULL,
    "Y1" smallint NOT NULL,
    "X2" smallint NOT NULL,
    "Y2" smallint NOT NULL,
    "LevelRequirement" smallint NOT NULL,
    "Number" smallint NOT NULL
);


--
-- Name: ExitGate; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ExitGate" (
    "Id" uuid NOT NULL,
    "MapId" uuid,
    "X1" smallint NOT NULL,
    "Y1" smallint NOT NULL,
    "X2" smallint NOT NULL,
    "Y2" smallint NOT NULL,
    "Direction" integer NOT NULL,
    "IsSpawnGate" boolean NOT NULL
);


--
-- Name: GameClientDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameClientDefinition" (
    "Id" uuid NOT NULL,
    "Season" smallint NOT NULL,
    "Episode" smallint NOT NULL,
    "Language" integer NOT NULL,
    "Version" bytea,
    "Serial" bytea,
    "Description" text NOT NULL
);


--
-- Name: GameConfiguration; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameConfiguration" (
    "Id" uuid NOT NULL,
    "MaximumLevel" smallint NOT NULL,
    "MaximumMasterLevel" smallint NOT NULL,
    "ExperienceRate" real NOT NULL,
    "MinimumMonsterLevelForMasterExperience" smallint CONSTRAINT "GameConfiguration_MinimumMonsterLevelForMasterExperien_not_null" NOT NULL,
    "InfoRange" smallint NOT NULL,
    "AreaSkillHitsPlayer" boolean NOT NULL,
    "MaximumInventoryMoney" integer NOT NULL,
    "MaximumVaultMoney" integer NOT NULL,
    "RecoveryInterval" integer NOT NULL,
    "MaximumLetters" integer NOT NULL,
    "LetterSendPrice" integer NOT NULL,
    "MaximumCharactersPerAccount" smallint NOT NULL,
    "CharacterNameRegex" text,
    "MaximumPasswordLength" integer NOT NULL,
    "MaximumPartySize" smallint NOT NULL,
    "ShouldDropMoney" boolean NOT NULL,
    "DamagePerOneItemDurability" double precision NOT NULL,
    "DamagePerOnePetDurability" double precision NOT NULL,
    "HitsPerOneItemDurability" double precision NOT NULL,
    "ItemDropDuration" interval DEFAULT '00:01:00'::interval NOT NULL,
    "DuelConfigurationId" uuid,
    "ExperienceFormula" text DEFAULT 'if(level == 0, 0, if(level < 256, 10 * (level + 8) * (level - 1) * (level - 1), (10 * (level + 8) * (level - 1) * (level - 1)) + (1000 * (level - 247) * (level - 256) * (level - 256))))'::text,
    "MasterExperienceFormula" text DEFAULT '(505 * level * level * level) + (35278500 * level) + (228045 * level * level)'::text,
    "MaximumItemOptionLevelDrop" smallint DEFAULT 3 NOT NULL,
    "ClampMoneyOnPickup" boolean DEFAULT false NOT NULL,
    "PreventExperienceOverflow" boolean DEFAULT false NOT NULL,
    "MasterExperienceRate" real DEFAULT 1 NOT NULL,
    "ExcellentItemDropLevelDelta" smallint DEFAULT 25 NOT NULL
);


--
-- Name: GameMapDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameMapDefinition" (
    "Id" uuid NOT NULL,
    "SafezoneMapId" uuid,
    "BattleZoneId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Name" text NOT NULL,
    "TerrainData" bytea,
    "ExpMultiplier" double precision NOT NULL,
    "Discriminator" integer NOT NULL
);


--
-- Name: GameMapDefinitionDropItemGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameMapDefinitionDropItemGroup" (
    "GameMapDefinitionId" uuid NOT NULL,
    "DropItemGroupId" uuid NOT NULL
);


--
-- Name: GameServerConfiguration; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameServerConfiguration" (
    "Id" uuid NOT NULL,
    "MaximumPlayers" smallint NOT NULL
);


--
-- Name: GameServerConfigurationGameMapDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameServerConfigurationGameMapDefinition" (
    "GameServerConfigurationId" uuid CONSTRAINT "GameServerConfigurationGameM_GameServerConfigurationId_not_null" NOT NULL,
    "GameMapDefinitionId" uuid CONSTRAINT "GameServerConfigurationGameMapDefi_GameMapDefinitionId_not_null" NOT NULL
);


--
-- Name: GameServerDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameServerDefinition" (
    "Id" uuid NOT NULL,
    "ServerConfigurationId" uuid,
    "GameConfigurationId" uuid,
    "ServerID" smallint NOT NULL,
    "Description" text NOT NULL,
    "ExperienceRate" real NOT NULL,
    "PvpEnabled" boolean DEFAULT true NOT NULL
);


--
-- Name: GameServerEndpoint; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."GameServerEndpoint" (
    "Id" uuid NOT NULL,
    "ClientId" uuid,
    "GameServerDefinitionId" uuid,
    "NetworkPort" integer NOT NULL,
    "AlternativePublishedPort" integer NOT NULL
);


--
-- Name: IncreasableItemOption; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."IncreasableItemOption" (
    "Id" uuid NOT NULL,
    "OptionTypeId" uuid,
    "PowerUpDefinitionId" uuid,
    "ItemOptionDefinitionId" uuid,
    "Number" integer NOT NULL,
    "SubOptionType" integer NOT NULL,
    "LevelType" integer NOT NULL,
    "Weight" smallint DEFAULT 0 NOT NULL
);


--
-- Name: ItemBasePowerUpDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemBasePowerUpDefinition" (
    "Id" uuid NOT NULL,
    "TargetAttributeId" uuid,
    "BonusPerLevelTableId" uuid,
    "ItemDefinitionId" uuid,
    "BaseValue" real NOT NULL,
    "AggregateType" integer DEFAULT 0 NOT NULL
);


--
-- Name: ItemCrafting; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemCrafting" (
    "Id" uuid NOT NULL,
    "SimpleCraftingSettingsId" uuid,
    "MonsterDefinitionId" uuid,
    "Number" smallint NOT NULL,
    "Name" text NOT NULL,
    "ItemCraftingHandlerClassName" text NOT NULL
);


--
-- Name: ItemCraftingRequiredItem; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemCraftingRequiredItem" (
    "Id" uuid NOT NULL,
    "SimpleCraftingSettingsId" uuid,
    "MinimumItemLevel" smallint NOT NULL,
    "MaximumItemLevel" smallint NOT NULL,
    "MinimumAmount" smallint NOT NULL,
    "MaximumAmount" smallint NOT NULL,
    "SuccessResult" integer NOT NULL,
    "FailResult" integer NOT NULL,
    "NpcPriceDivisor" integer NOT NULL,
    "AddPercentage" smallint NOT NULL,
    "Reference" smallint NOT NULL
);


--
-- Name: ItemCraftingRequiredItemItemDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemCraftingRequiredItemItemDefinition" (
    "ItemCraftingRequiredItemId" uuid CONSTRAINT "ItemCraftingRequiredItemIt_ItemCraftingRequiredItemId_not_null1" NOT NULL,
    "ItemDefinitionId" uuid CONSTRAINT "ItemCraftingRequiredItemItemDefinitio_ItemDefinitionId_not_null" NOT NULL
);


--
-- Name: ItemCraftingRequiredItemItemOptionType; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemCraftingRequiredItemItemOptionType" (
    "ItemCraftingRequiredItemId" uuid CONSTRAINT "ItemCraftingRequiredItemIte_ItemCraftingRequiredItemId_not_null" NOT NULL,
    "ItemOptionTypeId" uuid CONSTRAINT "ItemCraftingRequiredItemItemOptionTyp_ItemOptionTypeId_not_null" NOT NULL
);


--
-- Name: ItemCraftingResultItem; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemCraftingResultItem" (
    "Id" uuid NOT NULL,
    "ItemDefinitionId" uuid,
    "SimpleCraftingSettingsId" uuid,
    "RandomMinimumLevel" smallint NOT NULL,
    "RandomMaximumLevel" smallint NOT NULL,
    "Durability" smallint,
    "Reference" smallint NOT NULL,
    "AddLevel" smallint NOT NULL
);


--
-- Name: ItemDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDefinition" (
    "Id" uuid NOT NULL,
    "ItemSlotId" uuid,
    "ConsumeEffectId" uuid,
    "SkillId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Width" smallint NOT NULL,
    "Height" smallint NOT NULL,
    "DropsFromMonsters" boolean NOT NULL,
    "IsAmmunition" boolean NOT NULL,
    "IsBoundToCharacter" boolean NOT NULL,
    "Name" text NOT NULL,
    "DropLevel" smallint NOT NULL,
    "MaximumItemLevel" smallint NOT NULL,
    "Durability" smallint NOT NULL,
    "Group" smallint NOT NULL,
    "Value" integer NOT NULL,
    "MaximumSockets" integer NOT NULL,
    "PetExperienceFormula" text,
    "StorageLimitPerCharacter" integer DEFAULT 0 NOT NULL,
    "MaximumDropLevel" smallint,
    "IsQuestItem" boolean DEFAULT false NOT NULL
);


--
-- Name: ItemDefinitionCharacterClass; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDefinitionCharacterClass" (
    "ItemDefinitionId" uuid NOT NULL,
    "CharacterClassId" uuid NOT NULL
);


--
-- Name: ItemDefinitionItemOptionDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDefinitionItemOptionDefinition" (
    "ItemDefinitionId" uuid NOT NULL,
    "ItemOptionDefinitionId" uuid CONSTRAINT "ItemDefinitionItemOptionDefinit_ItemOptionDefinitionId_not_null" NOT NULL
);


--
-- Name: ItemDefinitionItemSetGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDefinitionItemSetGroup" (
    "ItemDefinitionId" uuid NOT NULL,
    "ItemSetGroupId" uuid NOT NULL
);


--
-- Name: ItemDropItemGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDropItemGroup" (
    "Id" uuid NOT NULL,
    "MonsterId" uuid,
    "ItemDefinitionId" uuid,
    "Description" text NOT NULL,
    "Chance" double precision NOT NULL,
    "MinimumMonsterLevel" smallint,
    "MaximumMonsterLevel" smallint,
    "ItemLevel" smallint,
    "ItemType" integer NOT NULL,
    "SourceItemLevel" smallint NOT NULL,
    "MoneyAmount" integer NOT NULL,
    "MinimumLevel" smallint NOT NULL,
    "MaximumLevel" smallint NOT NULL,
    "RequiredCharacterLevel" smallint NOT NULL,
    "DropEffect" integer NOT NULL
);


--
-- Name: ItemDropItemGroupItemDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemDropItemGroupItemDefinition" (
    "ItemDropItemGroupId" uuid NOT NULL,
    "ItemDefinitionId" uuid NOT NULL
);


--
-- Name: ItemLevelBonusTable; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemLevelBonusTable" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Name" text NOT NULL,
    "Description" text NOT NULL
);


--
-- Name: ItemOfItemSet; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOfItemSet" (
    "Id" uuid NOT NULL,
    "ItemSetGroupId" uuid,
    "ItemDefinitionId" uuid,
    "BonusOptionId" uuid,
    "AncientSetDiscriminator" integer NOT NULL
);


--
-- Name: ItemOption; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOption" (
    "Id" uuid NOT NULL,
    "OptionTypeId" uuid,
    "PowerUpDefinitionId" uuid,
    "Number" integer NOT NULL,
    "SubOptionType" integer NOT NULL
);


--
-- Name: ItemOptionCombinationBonus; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOptionCombinationBonus" (
    "Id" uuid NOT NULL,
    "BonusId" uuid,
    "GameConfigurationId" uuid,
    "Description" text NOT NULL,
    "Number" integer NOT NULL,
    "AppliesMultipleTimes" boolean NOT NULL
);


--
-- Name: ItemOptionDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOptionDefinition" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Name" text NOT NULL,
    "AddsRandomly" boolean NOT NULL,
    "AddChance" real NOT NULL,
    "MaximumOptionsPerItem" integer NOT NULL
);


--
-- Name: ItemOptionOfLevel; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOptionOfLevel" (
    "Id" uuid NOT NULL,
    "PowerUpDefinitionId" uuid,
    "IncreasableItemOptionId" uuid,
    "Level" integer NOT NULL,
    "RequiredItemLevel" integer NOT NULL
);


--
-- Name: ItemOptionType; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemOptionType" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "IsVisible" boolean NOT NULL
);


--
-- Name: ItemSetGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemSetGroup" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Name" text NOT NULL,
    "AlwaysApplies" boolean NOT NULL,
    "CountDistinct" boolean NOT NULL,
    "MinimumItemCount" integer NOT NULL,
    "SetLevel" integer NOT NULL,
    "OptionsId" uuid
);


--
-- Name: ItemSlotType; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."ItemSlotType" (
    "Id" uuid NOT NULL,
    "ItemSlots" text,
    "GameConfigurationId" uuid,
    "Description" text NOT NULL
);


--
-- Name: JewelMix; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."JewelMix" (
    "Id" uuid NOT NULL,
    "SingleJewelId" uuid,
    "MixedJewelId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL
);


--
-- Name: LevelBonus; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."LevelBonus" (
    "Id" uuid NOT NULL,
    "ItemLevelBonusTableId" uuid,
    "Level" integer NOT NULL,
    "AdditionalValue" real NOT NULL
);


--
-- Name: MagicEffectDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MagicEffectDefinition" (
    "Id" uuid NOT NULL,
    "DurationId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Name" text NOT NULL,
    "SubType" smallint NOT NULL,
    "InformObservers" boolean NOT NULL,
    "StopByDeath" boolean NOT NULL,
    "SendDuration" boolean NOT NULL,
    "ChanceId" uuid,
    "ChancePvpId" uuid,
    "DurationDependsOnTargetLevel" boolean DEFAULT false NOT NULL,
    "DurationPvpId" uuid,
    "MonsterTargetLevelDivisor" real DEFAULT 0 NOT NULL,
    "PlayerTargetLevelDivisor" real DEFAULT 0 NOT NULL
);


--
-- Name: MasterSkillDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MasterSkillDefinition" (
    "Id" uuid NOT NULL,
    "RootId" uuid,
    "TargetAttributeId" uuid,
    "ReplacedSkillId" uuid,
    "Rank" smallint NOT NULL,
    "MaximumLevel" smallint NOT NULL,
    "MinimumLevel" smallint NOT NULL,
    "ValueFormula" text NOT NULL,
    "DisplayValueFormula" text NOT NULL,
    "Aggregation" integer NOT NULL,
    "ExtendsDuration" boolean DEFAULT false NOT NULL
);


--
-- Name: MasterSkillDefinitionSkill; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MasterSkillDefinitionSkill" (
    "MasterSkillDefinitionId" uuid NOT NULL,
    "SkillId" uuid NOT NULL
);


--
-- Name: MasterSkillRoot; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MasterSkillRoot" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "Name" text NOT NULL
);


--
-- Name: MiniGameChangeEvent; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MiniGameChangeEvent" (
    "Id" uuid NOT NULL,
    "TargetDefinitionId" uuid,
    "SpawnAreaId" uuid,
    "MiniGameDefinitionId" uuid,
    "Index" integer NOT NULL,
    "Description" text DEFAULT ''::text NOT NULL,
    "Message" text DEFAULT ''::text NOT NULL,
    "Target" integer NOT NULL,
    "MinimumTargetLevel" smallint,
    "NumberOfKills" smallint NOT NULL,
    "MultiplyKillsByPlayers" boolean NOT NULL
);


--
-- Name: MiniGameDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MiniGameDefinition" (
    "Id" uuid NOT NULL,
    "EntranceId" uuid,
    "TicketItemId" uuid,
    "GameConfigurationId" uuid,
    "Type" integer NOT NULL,
    "Name" text NOT NULL,
    "Description" text NOT NULL,
    "GameLevel" smallint NOT NULL,
    "MapCreationPolicy" integer NOT NULL,
    "EnterDuration" interval NOT NULL,
    "GameDuration" interval NOT NULL,
    "ExitDuration" interval NOT NULL,
    "MaximumPlayerCount" integer NOT NULL,
    "SaveRankingStatistics" boolean NOT NULL,
    "RequiresMasterClass" boolean NOT NULL,
    "MinimumCharacterLevel" integer NOT NULL,
    "MaximumCharacterLevel" integer NOT NULL,
    "MinimumSpecialCharacterLevel" integer NOT NULL,
    "MaximumSpecialCharacterLevel" integer NOT NULL,
    "TicketItemLevel" integer NOT NULL,
    "AllowParty" boolean DEFAULT false NOT NULL,
    "ArePlayerKillersAllowedToEnter" boolean DEFAULT false NOT NULL,
    "EntranceFee" integer DEFAULT 0 NOT NULL
);


--
-- Name: MiniGameReward; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MiniGameReward" (
    "Id" uuid NOT NULL,
    "ItemRewardId" uuid,
    "RequiredKillId" uuid,
    "MiniGameDefinitionId" uuid,
    "Rank" integer,
    "RewardType" integer NOT NULL,
    "RewardAmount" integer NOT NULL,
    "RequiredSuccess" integer NOT NULL
);


--
-- Name: MiniGameSpawnWave; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MiniGameSpawnWave" (
    "Id" uuid NOT NULL,
    "MiniGameDefinitionId" uuid,
    "WaveNumber" smallint NOT NULL,
    "Description" text DEFAULT ''::text NOT NULL,
    "Message" text DEFAULT ''::text NOT NULL,
    "StartTime" interval NOT NULL,
    "EndTime" interval NOT NULL
);


--
-- Name: MiniGameTerrainChange; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MiniGameTerrainChange" (
    "Id" uuid NOT NULL,
    "MiniGameChangeEventId" uuid,
    "TerrainAttribute" integer NOT NULL,
    "SetTerrainAttribute" boolean NOT NULL,
    "StartX" smallint NOT NULL,
    "StartY" smallint NOT NULL,
    "EndX" smallint NOT NULL,
    "EndY" smallint NOT NULL,
    "IsClientUpdateRequired" boolean DEFAULT false NOT NULL
);


--
-- Name: MonsterAttribute; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MonsterAttribute" (
    "Id" uuid NOT NULL,
    "AttributeDefinitionId" uuid,
    "MonsterDefinitionId" uuid,
    "Value" real NOT NULL
);


--
-- Name: MonsterDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MonsterDefinition" (
    "Id" uuid NOT NULL,
    "AttackSkillId" uuid,
    "MerchantStoreId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Designation" text NOT NULL,
    "MoveRange" smallint NOT NULL,
    "AttackRange" smallint NOT NULL,
    "ViewRange" smallint NOT NULL,
    "MoveDelay" interval NOT NULL,
    "AttackDelay" interval NOT NULL,
    "RespawnDelay" interval NOT NULL,
    "Attribute" smallint NOT NULL,
    "NumberOfMaximumItemDrops" integer NOT NULL,
    "NpcWindow" integer NOT NULL,
    "ObjectKind" integer NOT NULL,
    "IntelligenceTypeName" text
);


--
-- Name: MonsterDefinitionDropItemGroup; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MonsterDefinitionDropItemGroup" (
    "MonsterDefinitionId" uuid NOT NULL,
    "DropItemGroupId" uuid NOT NULL
);


--
-- Name: MonsterSpawnArea; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."MonsterSpawnArea" (
    "Id" uuid NOT NULL,
    "MonsterDefinitionId" uuid,
    "GameMapId" uuid,
    "X1" smallint NOT NULL,
    "Y1" smallint NOT NULL,
    "X2" smallint NOT NULL,
    "Y2" smallint NOT NULL,
    "Direction" integer NOT NULL,
    "Quantity" smallint NOT NULL,
    "SpawnTrigger" integer NOT NULL,
    "WaveNumber" smallint NOT NULL,
    "MaximumHealthOverride" integer
);


--
-- Name: PlugInConfiguration; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."PlugInConfiguration" (
    "Id" uuid NOT NULL,
    "GameConfigurationId" uuid,
    "TypeId" uuid NOT NULL,
    "IsActive" boolean NOT NULL,
    "CustomPlugInSource" text,
    "ExternalAssemblyName" text,
    "CustomConfiguration" text
);


--
-- Name: PowerUpDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."PowerUpDefinition" (
    "Id" uuid NOT NULL,
    "TargetAttributeId" uuid,
    "BoostId" uuid,
    "MagicEffectDefinitionId" uuid,
    "GameMapDefinitionId" uuid,
    "MagicEffectDefinitionId1" uuid
);


--
-- Name: PowerUpDefinitionValue; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."PowerUpDefinitionValue" (
    "Id" uuid NOT NULL,
    "Value" real NOT NULL,
    "AggregateType" integer NOT NULL,
    "MaximumValue" real
);


--
-- Name: QuestDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."QuestDefinition" (
    "Id" uuid NOT NULL,
    "QuestGiverId" uuid,
    "QualifiedCharacterId" uuid,
    "MonsterDefinitionId" uuid,
    "Name" text NOT NULL,
    "Group" smallint NOT NULL,
    "Number" smallint NOT NULL,
    "StartingNumber" smallint NOT NULL,
    "RefuseNumber" smallint NOT NULL,
    "Repeatable" boolean NOT NULL,
    "RequiresClientAction" boolean NOT NULL,
    "RequiredStartMoney" integer NOT NULL,
    "MinimumCharacterLevel" integer NOT NULL,
    "MaximumCharacterLevel" integer NOT NULL
);


--
-- Name: QuestItemRequirement; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."QuestItemRequirement" (
    "Id" uuid NOT NULL,
    "ItemId" uuid,
    "DropItemGroupId" uuid,
    "QuestDefinitionId" uuid,
    "MinimumNumber" integer NOT NULL
);


--
-- Name: QuestMonsterKillRequirement; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."QuestMonsterKillRequirement" (
    "Id" uuid NOT NULL,
    "MonsterId" uuid,
    "QuestDefinitionId" uuid,
    "MinimumNumber" integer NOT NULL
);


--
-- Name: QuestReward; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."QuestReward" (
    "Id" uuid NOT NULL,
    "ItemRewardId" uuid,
    "AttributeRewardId" uuid,
    "SkillRewardId" uuid,
    "QuestDefinitionId" uuid,
    "RewardType" integer NOT NULL,
    "Value" integer NOT NULL
);


--
-- Name: Rectangle; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."Rectangle" (
    "Id" uuid NOT NULL,
    "X1" smallint NOT NULL,
    "Y1" smallint NOT NULL,
    "X2" smallint NOT NULL,
    "Y2" smallint NOT NULL
);


--
-- Name: SimpleCraftingSettings; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."SimpleCraftingSettings" (
    "Id" uuid NOT NULL,
    "Money" integer NOT NULL,
    "MoneyPerFinalSuccessPercentage" integer NOT NULL,
    "SuccessPercent" smallint NOT NULL,
    "MaximumSuccessPercent" smallint NOT NULL,
    "MultipleAllowed" boolean NOT NULL,
    "ResultItemSelect" integer NOT NULL,
    "SuccessPercentageAdditionForLuck" integer CONSTRAINT "SimpleCraftingSettings_SuccessPercentageAdditionForLuc_not_null" NOT NULL,
    "SuccessPercentageAdditionForExcellentItem" integer CONSTRAINT "SimpleCraftingSettings_SuccessPercentageAdditionForExc_not_null" NOT NULL,
    "SuccessPercentageAdditionForAncientItem" integer CONSTRAINT "SimpleCraftingSettings_SuccessPercentageAdditionForAnc_not_null" NOT NULL,
    "SuccessPercentageAdditionForSocketItem" integer CONSTRAINT "SimpleCraftingSettings_SuccessPercentageAdditionForSoc_not_null" NOT NULL,
    "ResultItemLuckOptionChance" smallint NOT NULL,
    "ResultItemSkillChance" smallint NOT NULL,
    "ResultItemExcellentOptionChance" smallint NOT NULL,
    "ResultItemMaxExcOptionCount" smallint NOT NULL,
    "NpcPriceDivisor" integer DEFAULT 0 NOT NULL,
    "SuccessPercentageAdditionForGuardianItem" integer DEFAULT 0 CONSTRAINT "SimpleCraftingSettings_SuccessPercentageAdditionForGua_not_null" NOT NULL
);


--
-- Name: Skill; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."Skill" (
    "Id" uuid NOT NULL,
    "ElementalModifierTargetId" uuid,
    "MagicEffectDefId" uuid,
    "MasterDefinitionId" uuid,
    "GameConfigurationId" uuid,
    "Number" smallint NOT NULL,
    "Name" text NOT NULL,
    "Range" smallint NOT NULL,
    "DamageType" integer NOT NULL,
    "SkillType" integer NOT NULL,
    "Target" integer NOT NULL,
    "ImplicitTargetRange" smallint NOT NULL,
    "TargetRestriction" integer NOT NULL,
    "MovesToTarget" boolean NOT NULL,
    "MovesTarget" boolean NOT NULL,
    "AttackDamage" integer NOT NULL,
    "AreaSkillSettingsId" uuid,
    "NumberOfHitsPerAttack" smallint DEFAULT 0 NOT NULL,
    "SkipElementalModifier" boolean DEFAULT false NOT NULL
);


--
-- Name: SkillCharacterClass; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."SkillCharacterClass" (
    "SkillId" uuid NOT NULL,
    "CharacterClassId" uuid NOT NULL
);


--
-- Name: SkillComboDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."SkillComboDefinition" (
    "Id" uuid NOT NULL,
    "Name" text NOT NULL,
    "MaximumCompletionTime" interval NOT NULL
);


--
-- Name: SkillComboStep; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."SkillComboStep" (
    "Id" uuid NOT NULL,
    "SkillId" uuid,
    "SkillComboDefinitionId" uuid,
    "Order" integer NOT NULL,
    "IsFinalStep" boolean NOT NULL
);


--
-- Name: StatAttributeDefinition; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."StatAttributeDefinition" (
    "Id" uuid NOT NULL,
    "AttributeId" uuid,
    "CharacterClassId" uuid,
    "BaseValue" real NOT NULL,
    "IncreasableByPlayer" boolean NOT NULL
);


--
-- Name: SystemConfiguration; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."SystemConfiguration" (
    "Id" uuid NOT NULL,
    "IpResolver" integer NOT NULL,
    "IpResolverParameter" text,
    "AutoStart" boolean NOT NULL,
    "AutoUpdateSchema" boolean NOT NULL,
    "ReadConsoleInput" boolean NOT NULL
);


--
-- Name: WarpInfo; Type: TABLE; Schema: config; Owner: -
--

CREATE TABLE config."WarpInfo" (
    "Id" uuid NOT NULL,
    "GateId" uuid,
    "GameConfigurationId" uuid,
    "Index" integer NOT NULL,
    "Name" text NOT NULL,
    "Costs" integer NOT NULL,
    "LevelRequirement" integer NOT NULL
);


--
-- Name: Account; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."Account" (
    "Id" uuid NOT NULL,
    "VaultId" uuid,
    "LoginName" character varying(10) NOT NULL,
    "PasswordHash" text NOT NULL,
    "SecurityCode" text NOT NULL,
    "EMail" text NOT NULL,
    "RegistrationDate" timestamp with time zone NOT NULL,
    "State" integer NOT NULL,
    "TimeZone" smallint NOT NULL,
    "VaultPassword" text NOT NULL,
    "IsVaultExtended" boolean NOT NULL,
    "ChatBanUntil" timestamp with time zone,
    "IsTemplate" boolean DEFAULT false NOT NULL,
    "LanguageIsoCode" character varying(3) DEFAULT 'en'::character varying NOT NULL,
    "IsBot" boolean DEFAULT false NOT NULL
);


--
-- Name: AccountCharacterClass; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."AccountCharacterClass" (
    "AccountId" uuid NOT NULL,
    "CharacterClassId" uuid NOT NULL
);


--
-- Name: AppearanceData; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."AppearanceData" (
    "Id" uuid NOT NULL,
    "CharacterClassId" uuid,
    "Pose" smallint NOT NULL,
    "FullAncientSetEquipped" boolean NOT NULL
);


--
-- Name: Character; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."Character" (
    "Id" uuid NOT NULL,
    "CharacterClassId" uuid NOT NULL,
    "CurrentMapId" uuid,
    "InventoryId" uuid,
    "AccountId" uuid,
    "Name" character varying(10) NOT NULL,
    "CharacterSlot" smallint NOT NULL,
    "CreateDate" timestamp with time zone NOT NULL,
    "Experience" bigint NOT NULL,
    "MasterExperience" bigint NOT NULL,
    "LevelUpPoints" integer NOT NULL,
    "MasterLevelUpPoints" integer NOT NULL,
    "PositionX" smallint NOT NULL,
    "PositionY" smallint NOT NULL,
    "PlayerKillCount" integer NOT NULL,
    "StateRemainingSeconds" integer NOT NULL,
    "State" integer NOT NULL,
    "CharacterStatus" integer NOT NULL,
    "Pose" smallint NOT NULL,
    "UsedFruitPoints" integer NOT NULL,
    "UsedNegFruitPoints" integer NOT NULL,
    "InventoryExtensions" integer NOT NULL,
    "KeyConfiguration" bytea,
    "MuHelperConfiguration" bytea,
    "IsStoreOpened" boolean DEFAULT false NOT NULL,
    "StoreName" text
);


--
-- Name: CharacterDropItemGroup; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."CharacterDropItemGroup" (
    "CharacterId" uuid NOT NULL,
    "DropItemGroupId" uuid NOT NULL
);


--
-- Name: CharacterQuestState; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."CharacterQuestState" (
    "Id" uuid NOT NULL,
    "LastFinishedQuestId" uuid,
    "ActiveQuestId" uuid,
    "CharacterId" uuid,
    "Group" smallint NOT NULL,
    "ClientActionPerformed" boolean NOT NULL
);


--
-- Name: Item; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."Item" (
    "Id" uuid NOT NULL,
    "ItemStorageId" uuid,
    "DefinitionId" uuid,
    "ItemSlot" smallint NOT NULL,
    "Durability" double precision NOT NULL,
    "Level" smallint NOT NULL,
    "HasSkill" boolean NOT NULL,
    "SocketCount" integer NOT NULL,
    "StorePrice" integer,
    "PetExperience" integer DEFAULT 0 NOT NULL
);


--
-- Name: ItemAppearance; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."ItemAppearance" (
    "Id" uuid NOT NULL,
    "DefinitionId" uuid,
    "AppearanceDataId" uuid,
    "ItemSlot" smallint NOT NULL,
    "Level" smallint NOT NULL
);


--
-- Name: ItemAppearanceItemOptionType; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."ItemAppearanceItemOptionType" (
    "ItemAppearanceId" uuid NOT NULL,
    "ItemOptionTypeId" uuid NOT NULL
);


--
-- Name: ItemItemOfItemSet; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."ItemItemOfItemSet" (
    "ItemId" uuid NOT NULL,
    "ItemOfItemSetId" uuid NOT NULL
);


--
-- Name: ItemOptionLink; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."ItemOptionLink" (
    "Id" uuid NOT NULL,
    "ItemOptionId" uuid,
    "ItemId" uuid,
    "Level" integer NOT NULL,
    "Index" integer NOT NULL
);


--
-- Name: ItemStorage; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."ItemStorage" (
    "Id" uuid NOT NULL,
    "Money" integer NOT NULL
);


--
-- Name: LetterBody; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."LetterBody" (
    "Id" uuid NOT NULL,
    "HeaderId" uuid,
    "SenderAppearanceId" uuid,
    "Message" text NOT NULL,
    "Rotation" smallint NOT NULL,
    "Animation" smallint NOT NULL
);


--
-- Name: LetterHeader; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."LetterHeader" (
    "Id" uuid NOT NULL,
    "ReceiverId" uuid NOT NULL,
    "SenderName" text,
    "Subject" text,
    "LetterDate" timestamp with time zone NOT NULL,
    "ReadFlag" boolean NOT NULL,
    "CharacterId" uuid DEFAULT '00000000-0000-0000-0000-000000000000'::uuid NOT NULL
);


--
-- Name: MiniGameRankingEntry; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."MiniGameRankingEntry" (
    "Id" uuid NOT NULL,
    "CharacterId" uuid,
    "MiniGameId" uuid,
    "GameInstanceId" uuid NOT NULL,
    "Timestamp" timestamp with time zone,
    "Score" integer NOT NULL,
    "Rank" integer NOT NULL
);


--
-- Name: OpenMuWeb_News; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."OpenMuWeb_News" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    author text NOT NULL,
    "creationDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: QuestMonsterKillRequirementState; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."QuestMonsterKillRequirementState" (
    "Id" uuid NOT NULL,
    "RequirementId" uuid,
    "CharacterQuestStateId" uuid,
    "KillCount" integer NOT NULL
);


--
-- Name: SkillEntry; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."SkillEntry" (
    "Id" uuid NOT NULL,
    "SkillId" uuid,
    "CharacterId" uuid,
    "Level" integer NOT NULL
);


--
-- Name: StatAttribute; Type: TABLE; Schema: data; Owner: -
--

CREATE TABLE data."StatAttribute" (
    "Id" uuid NOT NULL,
    "DefinitionId" uuid,
    "CharacterId" uuid,
    "Value" real NOT NULL,
    "AccountId" uuid
);


--
-- Name: Friend; Type: TABLE; Schema: friend; Owner: -
--

CREATE TABLE friend."Friend" (
    "Id" uuid NOT NULL,
    "CharacterId" uuid NOT NULL,
    "FriendId" uuid NOT NULL,
    "Accepted" boolean NOT NULL,
    "RequestOpen" boolean NOT NULL
);


--
-- Name: Guild; Type: TABLE; Schema: guild; Owner: -
--

CREATE TABLE guild."Guild" (
    "Id" uuid NOT NULL,
    "HostilityId" uuid,
    "AllianceGuildId" uuid,
    "Name" character varying(8) NOT NULL,
    "Logo" bytea,
    "Score" integer NOT NULL,
    "Notice" text
);


--
-- Name: GuildMember; Type: TABLE; Schema: guild; Owner: -
--

CREATE TABLE guild."GuildMember" (
    "Id" uuid NOT NULL,
    "GuildId" uuid NOT NULL,
    "Status" smallint NOT NULL
);


--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Name: AreaSkillSettings PK_AreaSkillSettings; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AreaSkillSettings"
    ADD CONSTRAINT "PK_AreaSkillSettings" PRIMARY KEY ("Id");


--
-- Name: AttributeDefinition PK_AttributeDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeDefinition"
    ADD CONSTRAINT "PK_AttributeDefinition" PRIMARY KEY ("Id");


--
-- Name: AttributeRelationship PK_AttributeRelationship; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "PK_AttributeRelationship" PRIMARY KEY ("Id");


--
-- Name: AttributeRequirement PK_AttributeRequirement; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "PK_AttributeRequirement" PRIMARY KEY ("Id");


--
-- Name: BattleZoneDefinition PK_BattleZoneDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."BattleZoneDefinition"
    ADD CONSTRAINT "PK_BattleZoneDefinition" PRIMARY KEY ("Id");


--
-- Name: Buff PK_Buff; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Buff"
    ADD CONSTRAINT "PK_Buff" PRIMARY KEY ("Id");


--
-- Name: CharacterClass PK_CharacterClass; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CharacterClass"
    ADD CONSTRAINT "PK_CharacterClass" PRIMARY KEY ("Id");


--
-- Name: ChatServerDefinition PK_ChatServerDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ChatServerDefinition"
    ADD CONSTRAINT "PK_ChatServerDefinition" PRIMARY KEY ("Id");


--
-- Name: ChatServerEndpoint PK_ChatServerEndpoint; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ChatServerEndpoint"
    ADD CONSTRAINT "PK_ChatServerEndpoint" PRIMARY KEY ("Id");


--
-- Name: CombinationBonusRequirement PK_CombinationBonusRequirement; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CombinationBonusRequirement"
    ADD CONSTRAINT "PK_CombinationBonusRequirement" PRIMARY KEY ("Id");


--
-- Name: ConfigurationUpdate PK_ConfigurationUpdate; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConfigurationUpdate"
    ADD CONSTRAINT "PK_ConfigurationUpdate" PRIMARY KEY ("Id");


--
-- Name: ConfigurationUpdateState PK_ConfigurationUpdateState; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConfigurationUpdateState"
    ADD CONSTRAINT "PK_ConfigurationUpdateState" PRIMARY KEY ("Id");


--
-- Name: ConnectServerDefinition PK_ConnectServerDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConnectServerDefinition"
    ADD CONSTRAINT "PK_ConnectServerDefinition" PRIMARY KEY ("Id");


--
-- Name: ConstValueAttribute PK_ConstValueAttribute; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConstValueAttribute"
    ADD CONSTRAINT "PK_ConstValueAttribute" PRIMARY KEY ("Id");


--
-- Name: DropItemGroup PK_DropItemGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroup"
    ADD CONSTRAINT "PK_DropItemGroup" PRIMARY KEY ("Id");


--
-- Name: DropItemGroupItemDefinition PK_DropItemGroupItemDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroupItemDefinition"
    ADD CONSTRAINT "PK_DropItemGroupItemDefinition" PRIMARY KEY ("DropItemGroupId", "ItemDefinitionId");


--
-- Name: DuelArea PK_DuelArea; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelArea"
    ADD CONSTRAINT "PK_DuelArea" PRIMARY KEY ("Id");


--
-- Name: DuelConfiguration PK_DuelConfiguration; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelConfiguration"
    ADD CONSTRAINT "PK_DuelConfiguration" PRIMARY KEY ("Id");


--
-- Name: EnterGate PK_EnterGate; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."EnterGate"
    ADD CONSTRAINT "PK_EnterGate" PRIMARY KEY ("Id");


--
-- Name: ExitGate PK_ExitGate; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ExitGate"
    ADD CONSTRAINT "PK_ExitGate" PRIMARY KEY ("Id");


--
-- Name: GameClientDefinition PK_GameClientDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameClientDefinition"
    ADD CONSTRAINT "PK_GameClientDefinition" PRIMARY KEY ("Id");


--
-- Name: GameConfiguration PK_GameConfiguration; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameConfiguration"
    ADD CONSTRAINT "PK_GameConfiguration" PRIMARY KEY ("Id");


--
-- Name: GameMapDefinition PK_GameMapDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinition"
    ADD CONSTRAINT "PK_GameMapDefinition" PRIMARY KEY ("Id");


--
-- Name: GameMapDefinitionDropItemGroup PK_GameMapDefinitionDropItemGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinitionDropItemGroup"
    ADD CONSTRAINT "PK_GameMapDefinitionDropItemGroup" PRIMARY KEY ("GameMapDefinitionId", "DropItemGroupId");


--
-- Name: GameServerConfiguration PK_GameServerConfiguration; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerConfiguration"
    ADD CONSTRAINT "PK_GameServerConfiguration" PRIMARY KEY ("Id");


--
-- Name: GameServerConfigurationGameMapDefinition PK_GameServerConfigurationGameMapDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerConfigurationGameMapDefinition"
    ADD CONSTRAINT "PK_GameServerConfigurationGameMapDefinition" PRIMARY KEY ("GameServerConfigurationId", "GameMapDefinitionId");


--
-- Name: GameServerDefinition PK_GameServerDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerDefinition"
    ADD CONSTRAINT "PK_GameServerDefinition" PRIMARY KEY ("Id");


--
-- Name: GameServerEndpoint PK_GameServerEndpoint; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerEndpoint"
    ADD CONSTRAINT "PK_GameServerEndpoint" PRIMARY KEY ("Id");


--
-- Name: IncreasableItemOption PK_IncreasableItemOption; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."IncreasableItemOption"
    ADD CONSTRAINT "PK_IncreasableItemOption" PRIMARY KEY ("Id");


--
-- Name: ItemBasePowerUpDefinition PK_ItemBasePowerUpDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemBasePowerUpDefinition"
    ADD CONSTRAINT "PK_ItemBasePowerUpDefinition" PRIMARY KEY ("Id");


--
-- Name: ItemCrafting PK_ItemCrafting; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCrafting"
    ADD CONSTRAINT "PK_ItemCrafting" PRIMARY KEY ("Id");


--
-- Name: ItemCraftingRequiredItem PK_ItemCraftingRequiredItem; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItem"
    ADD CONSTRAINT "PK_ItemCraftingRequiredItem" PRIMARY KEY ("Id");


--
-- Name: ItemCraftingRequiredItemItemDefinition PK_ItemCraftingRequiredItemItemDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemDefinition"
    ADD CONSTRAINT "PK_ItemCraftingRequiredItemItemDefinition" PRIMARY KEY ("ItemCraftingRequiredItemId", "ItemDefinitionId");


--
-- Name: ItemCraftingRequiredItemItemOptionType PK_ItemCraftingRequiredItemItemOptionType; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemOptionType"
    ADD CONSTRAINT "PK_ItemCraftingRequiredItemItemOptionType" PRIMARY KEY ("ItemCraftingRequiredItemId", "ItemOptionTypeId");


--
-- Name: ItemCraftingResultItem PK_ItemCraftingResultItem; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingResultItem"
    ADD CONSTRAINT "PK_ItemCraftingResultItem" PRIMARY KEY ("Id");


--
-- Name: ItemDefinition PK_ItemDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinition"
    ADD CONSTRAINT "PK_ItemDefinition" PRIMARY KEY ("Id");


--
-- Name: ItemDefinitionCharacterClass PK_ItemDefinitionCharacterClass; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionCharacterClass"
    ADD CONSTRAINT "PK_ItemDefinitionCharacterClass" PRIMARY KEY ("ItemDefinitionId", "CharacterClassId");


--
-- Name: ItemDefinitionItemOptionDefinition PK_ItemDefinitionItemOptionDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemOptionDefinition"
    ADD CONSTRAINT "PK_ItemDefinitionItemOptionDefinition" PRIMARY KEY ("ItemDefinitionId", "ItemOptionDefinitionId");


--
-- Name: ItemDefinitionItemSetGroup PK_ItemDefinitionItemSetGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemSetGroup"
    ADD CONSTRAINT "PK_ItemDefinitionItemSetGroup" PRIMARY KEY ("ItemDefinitionId", "ItemSetGroupId");


--
-- Name: ItemDropItemGroup PK_ItemDropItemGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroup"
    ADD CONSTRAINT "PK_ItemDropItemGroup" PRIMARY KEY ("Id");


--
-- Name: ItemDropItemGroupItemDefinition PK_ItemDropItemGroupItemDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroupItemDefinition"
    ADD CONSTRAINT "PK_ItemDropItemGroupItemDefinition" PRIMARY KEY ("ItemDropItemGroupId", "ItemDefinitionId");


--
-- Name: ItemLevelBonusTable PK_ItemLevelBonusTable; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemLevelBonusTable"
    ADD CONSTRAINT "PK_ItemLevelBonusTable" PRIMARY KEY ("Id");


--
-- Name: ItemOfItemSet PK_ItemOfItemSet; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOfItemSet"
    ADD CONSTRAINT "PK_ItemOfItemSet" PRIMARY KEY ("Id");


--
-- Name: ItemOption PK_ItemOption; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOption"
    ADD CONSTRAINT "PK_ItemOption" PRIMARY KEY ("Id");


--
-- Name: ItemOptionCombinationBonus PK_ItemOptionCombinationBonus; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionCombinationBonus"
    ADD CONSTRAINT "PK_ItemOptionCombinationBonus" PRIMARY KEY ("Id");


--
-- Name: ItemOptionDefinition PK_ItemOptionDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionDefinition"
    ADD CONSTRAINT "PK_ItemOptionDefinition" PRIMARY KEY ("Id");


--
-- Name: ItemOptionOfLevel PK_ItemOptionOfLevel; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionOfLevel"
    ADD CONSTRAINT "PK_ItemOptionOfLevel" PRIMARY KEY ("Id");


--
-- Name: ItemOptionType PK_ItemOptionType; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionType"
    ADD CONSTRAINT "PK_ItemOptionType" PRIMARY KEY ("Id");


--
-- Name: ItemSetGroup PK_ItemSetGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemSetGroup"
    ADD CONSTRAINT "PK_ItemSetGroup" PRIMARY KEY ("Id");


--
-- Name: ItemSlotType PK_ItemSlotType; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemSlotType"
    ADD CONSTRAINT "PK_ItemSlotType" PRIMARY KEY ("Id");


--
-- Name: JewelMix PK_JewelMix; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."JewelMix"
    ADD CONSTRAINT "PK_JewelMix" PRIMARY KEY ("Id");


--
-- Name: LevelBonus PK_LevelBonus; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."LevelBonus"
    ADD CONSTRAINT "PK_LevelBonus" PRIMARY KEY ("Id");


--
-- Name: MagicEffectDefinition PK_MagicEffectDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "PK_MagicEffectDefinition" PRIMARY KEY ("Id");


--
-- Name: MasterSkillDefinition PK_MasterSkillDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinition"
    ADD CONSTRAINT "PK_MasterSkillDefinition" PRIMARY KEY ("Id");


--
-- Name: MasterSkillDefinitionSkill PK_MasterSkillDefinitionSkill; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinitionSkill"
    ADD CONSTRAINT "PK_MasterSkillDefinitionSkill" PRIMARY KEY ("MasterSkillDefinitionId", "SkillId");


--
-- Name: MasterSkillRoot PK_MasterSkillRoot; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillRoot"
    ADD CONSTRAINT "PK_MasterSkillRoot" PRIMARY KEY ("Id");


--
-- Name: MiniGameChangeEvent PK_MiniGameChangeEvent; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameChangeEvent"
    ADD CONSTRAINT "PK_MiniGameChangeEvent" PRIMARY KEY ("Id");


--
-- Name: MiniGameDefinition PK_MiniGameDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameDefinition"
    ADD CONSTRAINT "PK_MiniGameDefinition" PRIMARY KEY ("Id");


--
-- Name: MiniGameReward PK_MiniGameReward; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameReward"
    ADD CONSTRAINT "PK_MiniGameReward" PRIMARY KEY ("Id");


--
-- Name: MiniGameSpawnWave PK_MiniGameSpawnWave; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameSpawnWave"
    ADD CONSTRAINT "PK_MiniGameSpawnWave" PRIMARY KEY ("Id");


--
-- Name: MiniGameTerrainChange PK_MiniGameTerrainChange; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameTerrainChange"
    ADD CONSTRAINT "PK_MiniGameTerrainChange" PRIMARY KEY ("Id");


--
-- Name: MonsterAttribute PK_MonsterAttribute; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterAttribute"
    ADD CONSTRAINT "PK_MonsterAttribute" PRIMARY KEY ("Id");


--
-- Name: MonsterDefinition PK_MonsterDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinition"
    ADD CONSTRAINT "PK_MonsterDefinition" PRIMARY KEY ("Id");


--
-- Name: MonsterDefinitionDropItemGroup PK_MonsterDefinitionDropItemGroup; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinitionDropItemGroup"
    ADD CONSTRAINT "PK_MonsterDefinitionDropItemGroup" PRIMARY KEY ("MonsterDefinitionId", "DropItemGroupId");


--
-- Name: MonsterSpawnArea PK_MonsterSpawnArea; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterSpawnArea"
    ADD CONSTRAINT "PK_MonsterSpawnArea" PRIMARY KEY ("Id");


--
-- Name: PlugInConfiguration PK_PlugInConfiguration; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PlugInConfiguration"
    ADD CONSTRAINT "PK_PlugInConfiguration" PRIMARY KEY ("Id");


--
-- Name: PowerUpDefinition PK_PowerUpDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "PK_PowerUpDefinition" PRIMARY KEY ("Id");


--
-- Name: PowerUpDefinitionValue PK_PowerUpDefinitionValue; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinitionValue"
    ADD CONSTRAINT "PK_PowerUpDefinitionValue" PRIMARY KEY ("Id");


--
-- Name: QuestDefinition PK_QuestDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestDefinition"
    ADD CONSTRAINT "PK_QuestDefinition" PRIMARY KEY ("Id");


--
-- Name: QuestItemRequirement PK_QuestItemRequirement; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestItemRequirement"
    ADD CONSTRAINT "PK_QuestItemRequirement" PRIMARY KEY ("Id");


--
-- Name: QuestMonsterKillRequirement PK_QuestMonsterKillRequirement; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestMonsterKillRequirement"
    ADD CONSTRAINT "PK_QuestMonsterKillRequirement" PRIMARY KEY ("Id");


--
-- Name: QuestReward PK_QuestReward; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestReward"
    ADD CONSTRAINT "PK_QuestReward" PRIMARY KEY ("Id");


--
-- Name: Rectangle PK_Rectangle; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Rectangle"
    ADD CONSTRAINT "PK_Rectangle" PRIMARY KEY ("Id");


--
-- Name: SimpleCraftingSettings PK_SimpleCraftingSettings; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SimpleCraftingSettings"
    ADD CONSTRAINT "PK_SimpleCraftingSettings" PRIMARY KEY ("Id");


--
-- Name: Skill PK_Skill; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "PK_Skill" PRIMARY KEY ("Id");


--
-- Name: SkillCharacterClass PK_SkillCharacterClass; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillCharacterClass"
    ADD CONSTRAINT "PK_SkillCharacterClass" PRIMARY KEY ("SkillId", "CharacterClassId");


--
-- Name: SkillComboDefinition PK_SkillComboDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillComboDefinition"
    ADD CONSTRAINT "PK_SkillComboDefinition" PRIMARY KEY ("Id");


--
-- Name: SkillComboStep PK_SkillComboStep; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillComboStep"
    ADD CONSTRAINT "PK_SkillComboStep" PRIMARY KEY ("Id");


--
-- Name: StatAttributeDefinition PK_StatAttributeDefinition; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."StatAttributeDefinition"
    ADD CONSTRAINT "PK_StatAttributeDefinition" PRIMARY KEY ("Id");


--
-- Name: SystemConfiguration PK_SystemConfiguration; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SystemConfiguration"
    ADD CONSTRAINT "PK_SystemConfiguration" PRIMARY KEY ("Id");


--
-- Name: WarpInfo PK_WarpInfo; Type: CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."WarpInfo"
    ADD CONSTRAINT "PK_WarpInfo" PRIMARY KEY ("Id");


--
-- Name: OpenMuWeb_News OpenMuWeb_News_pkey; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."OpenMuWeb_News"
    ADD CONSTRAINT "OpenMuWeb_News_pkey" PRIMARY KEY (id);


--
-- Name: Account PK_Account; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Account"
    ADD CONSTRAINT "PK_Account" PRIMARY KEY ("Id");


--
-- Name: AccountCharacterClass PK_AccountCharacterClass; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."AccountCharacterClass"
    ADD CONSTRAINT "PK_AccountCharacterClass" PRIMARY KEY ("AccountId", "CharacterClassId");


--
-- Name: AppearanceData PK_AppearanceData; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."AppearanceData"
    ADD CONSTRAINT "PK_AppearanceData" PRIMARY KEY ("Id");


--
-- Name: Character PK_Character; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Character"
    ADD CONSTRAINT "PK_Character" PRIMARY KEY ("Id");


--
-- Name: CharacterDropItemGroup PK_CharacterDropItemGroup; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterDropItemGroup"
    ADD CONSTRAINT "PK_CharacterDropItemGroup" PRIMARY KEY ("CharacterId", "DropItemGroupId");


--
-- Name: CharacterQuestState PK_CharacterQuestState; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterQuestState"
    ADD CONSTRAINT "PK_CharacterQuestState" PRIMARY KEY ("Id");


--
-- Name: Item PK_Item; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Item"
    ADD CONSTRAINT "PK_Item" PRIMARY KEY ("Id");


--
-- Name: ItemAppearance PK_ItemAppearance; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearance"
    ADD CONSTRAINT "PK_ItemAppearance" PRIMARY KEY ("Id");


--
-- Name: ItemAppearanceItemOptionType PK_ItemAppearanceItemOptionType; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearanceItemOptionType"
    ADD CONSTRAINT "PK_ItemAppearanceItemOptionType" PRIMARY KEY ("ItemAppearanceId", "ItemOptionTypeId");


--
-- Name: ItemItemOfItemSet PK_ItemItemOfItemSet; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemItemOfItemSet"
    ADD CONSTRAINT "PK_ItemItemOfItemSet" PRIMARY KEY ("ItemId", "ItemOfItemSetId");


--
-- Name: ItemOptionLink PK_ItemOptionLink; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemOptionLink"
    ADD CONSTRAINT "PK_ItemOptionLink" PRIMARY KEY ("Id");


--
-- Name: ItemStorage PK_ItemStorage; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemStorage"
    ADD CONSTRAINT "PK_ItemStorage" PRIMARY KEY ("Id");


--
-- Name: LetterBody PK_LetterBody; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."LetterBody"
    ADD CONSTRAINT "PK_LetterBody" PRIMARY KEY ("Id");


--
-- Name: LetterHeader PK_LetterHeader; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."LetterHeader"
    ADD CONSTRAINT "PK_LetterHeader" PRIMARY KEY ("Id");


--
-- Name: MiniGameRankingEntry PK_MiniGameRankingEntry; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."MiniGameRankingEntry"
    ADD CONSTRAINT "PK_MiniGameRankingEntry" PRIMARY KEY ("Id");


--
-- Name: QuestMonsterKillRequirementState PK_QuestMonsterKillRequirementState; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."QuestMonsterKillRequirementState"
    ADD CONSTRAINT "PK_QuestMonsterKillRequirementState" PRIMARY KEY ("Id");


--
-- Name: SkillEntry PK_SkillEntry; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."SkillEntry"
    ADD CONSTRAINT "PK_SkillEntry" PRIMARY KEY ("Id");


--
-- Name: StatAttribute PK_StatAttribute; Type: CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."StatAttribute"
    ADD CONSTRAINT "PK_StatAttribute" PRIMARY KEY ("Id");


--
-- Name: Friend AK_Friend_CharacterId_FriendId; Type: CONSTRAINT; Schema: friend; Owner: -
--

ALTER TABLE ONLY friend."Friend"
    ADD CONSTRAINT "AK_Friend_CharacterId_FriendId" UNIQUE ("CharacterId", "FriendId");


--
-- Name: Friend PK_Friend; Type: CONSTRAINT; Schema: friend; Owner: -
--

ALTER TABLE ONLY friend."Friend"
    ADD CONSTRAINT "PK_Friend" PRIMARY KEY ("Id");


--
-- Name: Guild PK_Guild; Type: CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."Guild"
    ADD CONSTRAINT "PK_Guild" PRIMARY KEY ("Id");


--
-- Name: GuildMember PK_GuildMember; Type: CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."GuildMember"
    ADD CONSTRAINT "PK_GuildMember" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: IX_AttributeDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeDefinition_GameConfigurationId" ON config."AttributeDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_AttributeRelationship_CharacterClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_CharacterClassId" ON config."AttributeRelationship" USING btree ("CharacterClassId");


--
-- Name: IX_AttributeRelationship_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_GameConfigurationId" ON config."AttributeRelationship" USING btree ("GameConfigurationId");


--
-- Name: IX_AttributeRelationship_InputAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_InputAttributeId" ON config."AttributeRelationship" USING btree ("InputAttributeId");


--
-- Name: IX_AttributeRelationship_OperandAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_OperandAttributeId" ON config."AttributeRelationship" USING btree ("OperandAttributeId");


--
-- Name: IX_AttributeRelationship_PowerUpDefinitionValueId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_PowerUpDefinitionValueId" ON config."AttributeRelationship" USING btree ("PowerUpDefinitionValueId");


--
-- Name: IX_AttributeRelationship_SkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_SkillId" ON config."AttributeRelationship" USING btree ("SkillId");


--
-- Name: IX_AttributeRelationship_TargetAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRelationship_TargetAttributeId" ON config."AttributeRelationship" USING btree ("TargetAttributeId");


--
-- Name: IX_AttributeRequirement_AttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRequirement_AttributeId" ON config."AttributeRequirement" USING btree ("AttributeId");


--
-- Name: IX_AttributeRequirement_GameMapDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRequirement_GameMapDefinitionId" ON config."AttributeRequirement" USING btree ("GameMapDefinitionId");


--
-- Name: IX_AttributeRequirement_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRequirement_ItemDefinitionId" ON config."AttributeRequirement" USING btree ("ItemDefinitionId");


--
-- Name: IX_AttributeRequirement_SkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRequirement_SkillId" ON config."AttributeRequirement" USING btree ("SkillId");


--
-- Name: IX_AttributeRequirement_SkillId1; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_AttributeRequirement_SkillId1" ON config."AttributeRequirement" USING btree ("SkillId1");


--
-- Name: IX_BattleZoneDefinition_GroundId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_BattleZoneDefinition_GroundId" ON config."BattleZoneDefinition" USING btree ("GroundId");


--
-- Name: IX_BattleZoneDefinition_LeftGoalId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_BattleZoneDefinition_LeftGoalId" ON config."BattleZoneDefinition" USING btree ("LeftGoalId");


--
-- Name: IX_BattleZoneDefinition_RightGoalId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_BattleZoneDefinition_RightGoalId" ON config."BattleZoneDefinition" USING btree ("RightGoalId");


--
-- Name: IX_Buff_MagicEffectDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_Buff_MagicEffectDefinitionId" ON config."Buff" USING btree ("MagicEffectDefinitionId");


--
-- Name: IX_Buff_MonsterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_Buff_MonsterDefinitionId" ON config."Buff" USING btree ("MonsterDefinitionId");


--
-- Name: IX_CharacterClass_ComboDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_CharacterClass_ComboDefinitionId" ON config."CharacterClass" USING btree ("ComboDefinitionId");


--
-- Name: IX_CharacterClass_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_CharacterClass_GameConfigurationId" ON config."CharacterClass" USING btree ("GameConfigurationId");


--
-- Name: IX_CharacterClass_HomeMapId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_CharacterClass_HomeMapId" ON config."CharacterClass" USING btree ("HomeMapId");


--
-- Name: IX_CharacterClass_NextGenerationClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_CharacterClass_NextGenerationClassId" ON config."CharacterClass" USING btree ("NextGenerationClassId");


--
-- Name: IX_ChatServerEndpoint_ChatServerDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ChatServerEndpoint_ChatServerDefinitionId" ON config."ChatServerEndpoint" USING btree ("ChatServerDefinitionId");


--
-- Name: IX_ChatServerEndpoint_ClientId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ChatServerEndpoint_ClientId" ON config."ChatServerEndpoint" USING btree ("ClientId");


--
-- Name: IX_CombinationBonusRequirement_ItemOptionCombinationBonusId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_CombinationBonusRequirement_ItemOptionCombinationBonusId" ON config."CombinationBonusRequirement" USING btree ("ItemOptionCombinationBonusId");


--
-- Name: IX_CombinationBonusRequirement_OptionTypeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_CombinationBonusRequirement_OptionTypeId" ON config."CombinationBonusRequirement" USING btree ("OptionTypeId");


--
-- Name: IX_ConnectServerDefinition_ClientId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ConnectServerDefinition_ClientId" ON config."ConnectServerDefinition" USING btree ("ClientId");


--
-- Name: IX_ConstValueAttribute_CharacterClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ConstValueAttribute_CharacterClassId" ON config."ConstValueAttribute" USING btree ("CharacterClassId");


--
-- Name: IX_ConstValueAttribute_DefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ConstValueAttribute_DefinitionId" ON config."ConstValueAttribute" USING btree ("DefinitionId");


--
-- Name: IX_ConstValueAttribute_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ConstValueAttribute_GameConfigurationId" ON config."ConstValueAttribute" USING btree ("GameConfigurationId");


--
-- Name: IX_DropItemGroupItemDefinition_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DropItemGroupItemDefinition_ItemDefinitionId" ON config."DropItemGroupItemDefinition" USING btree ("ItemDefinitionId");


--
-- Name: IX_DropItemGroup_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DropItemGroup_GameConfigurationId" ON config."DropItemGroup" USING btree ("GameConfigurationId");


--
-- Name: IX_DropItemGroup_MonsterId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DropItemGroup_MonsterId" ON config."DropItemGroup" USING btree ("MonsterId");


--
-- Name: IX_DuelArea_DuelConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DuelArea_DuelConfigurationId" ON config."DuelArea" USING btree ("DuelConfigurationId");


--
-- Name: IX_DuelArea_FirstPlayerGateId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DuelArea_FirstPlayerGateId" ON config."DuelArea" USING btree ("FirstPlayerGateId");


--
-- Name: IX_DuelArea_SecondPlayerGateId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DuelArea_SecondPlayerGateId" ON config."DuelArea" USING btree ("SecondPlayerGateId");


--
-- Name: IX_DuelArea_SpectatorsGateId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DuelArea_SpectatorsGateId" ON config."DuelArea" USING btree ("SpectatorsGateId");


--
-- Name: IX_DuelConfiguration_ExitId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_DuelConfiguration_ExitId" ON config."DuelConfiguration" USING btree ("ExitId");


--
-- Name: IX_EnterGate_GameMapDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_EnterGate_GameMapDefinitionId" ON config."EnterGate" USING btree ("GameMapDefinitionId");


--
-- Name: IX_EnterGate_TargetGateId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_EnterGate_TargetGateId" ON config."EnterGate" USING btree ("TargetGateId");


--
-- Name: IX_ExitGate_MapId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ExitGate_MapId" ON config."ExitGate" USING btree ("MapId");


--
-- Name: IX_GameConfiguration_DuelConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_GameConfiguration_DuelConfigurationId" ON config."GameConfiguration" USING btree ("DuelConfigurationId");


--
-- Name: IX_GameMapDefinitionDropItemGroup_DropItemGroupId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameMapDefinitionDropItemGroup_DropItemGroupId" ON config."GameMapDefinitionDropItemGroup" USING btree ("DropItemGroupId");


--
-- Name: IX_GameMapDefinition_BattleZoneId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_GameMapDefinition_BattleZoneId" ON config."GameMapDefinition" USING btree ("BattleZoneId");


--
-- Name: IX_GameMapDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameMapDefinition_GameConfigurationId" ON config."GameMapDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_GameMapDefinition_SafezoneMapId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameMapDefinition_SafezoneMapId" ON config."GameMapDefinition" USING btree ("SafezoneMapId");


--
-- Name: IX_GameServerConfigurationGameMapDefinition_GameMapDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameServerConfigurationGameMapDefinition_GameMapDefinitionId" ON config."GameServerConfigurationGameMapDefinition" USING btree ("GameMapDefinitionId");


--
-- Name: IX_GameServerDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameServerDefinition_GameConfigurationId" ON config."GameServerDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_GameServerDefinition_ServerConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameServerDefinition_ServerConfigurationId" ON config."GameServerDefinition" USING btree ("ServerConfigurationId");


--
-- Name: IX_GameServerEndpoint_ClientId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameServerEndpoint_ClientId" ON config."GameServerEndpoint" USING btree ("ClientId");


--
-- Name: IX_GameServerEndpoint_GameServerDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_GameServerEndpoint_GameServerDefinitionId" ON config."GameServerEndpoint" USING btree ("GameServerDefinitionId");


--
-- Name: IX_IncreasableItemOption_ItemOptionDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_IncreasableItemOption_ItemOptionDefinitionId" ON config."IncreasableItemOption" USING btree ("ItemOptionDefinitionId");


--
-- Name: IX_IncreasableItemOption_OptionTypeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_IncreasableItemOption_OptionTypeId" ON config."IncreasableItemOption" USING btree ("OptionTypeId");


--
-- Name: IX_IncreasableItemOption_PowerUpDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_IncreasableItemOption_PowerUpDefinitionId" ON config."IncreasableItemOption" USING btree ("PowerUpDefinitionId");


--
-- Name: IX_ItemBasePowerUpDefinition_BonusPerLevelTableId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemBasePowerUpDefinition_BonusPerLevelTableId" ON config."ItemBasePowerUpDefinition" USING btree ("BonusPerLevelTableId");


--
-- Name: IX_ItemBasePowerUpDefinition_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemBasePowerUpDefinition_ItemDefinitionId" ON config."ItemBasePowerUpDefinition" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemBasePowerUpDefinition_TargetAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemBasePowerUpDefinition_TargetAttributeId" ON config."ItemBasePowerUpDefinition" USING btree ("TargetAttributeId");


--
-- Name: IX_ItemCraftingRequiredItemItemDefinition_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCraftingRequiredItemItemDefinition_ItemDefinitionId" ON config."ItemCraftingRequiredItemItemDefinition" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemCraftingRequiredItemItemOptionType_ItemOptionTypeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCraftingRequiredItemItemOptionType_ItemOptionTypeId" ON config."ItemCraftingRequiredItemItemOptionType" USING btree ("ItemOptionTypeId");


--
-- Name: IX_ItemCraftingRequiredItem_SimpleCraftingSettingsId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCraftingRequiredItem_SimpleCraftingSettingsId" ON config."ItemCraftingRequiredItem" USING btree ("SimpleCraftingSettingsId");


--
-- Name: IX_ItemCraftingResultItem_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCraftingResultItem_ItemDefinitionId" ON config."ItemCraftingResultItem" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemCraftingResultItem_SimpleCraftingSettingsId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCraftingResultItem_SimpleCraftingSettingsId" ON config."ItemCraftingResultItem" USING btree ("SimpleCraftingSettingsId");


--
-- Name: IX_ItemCrafting_MonsterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemCrafting_MonsterDefinitionId" ON config."ItemCrafting" USING btree ("MonsterDefinitionId");


--
-- Name: IX_ItemCrafting_SimpleCraftingSettingsId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_ItemCrafting_SimpleCraftingSettingsId" ON config."ItemCrafting" USING btree ("SimpleCraftingSettingsId");


--
-- Name: IX_ItemDefinitionCharacterClass_CharacterClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinitionCharacterClass_CharacterClassId" ON config."ItemDefinitionCharacterClass" USING btree ("CharacterClassId");


--
-- Name: IX_ItemDefinitionItemOptionDefinition_ItemOptionDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinitionItemOptionDefinition_ItemOptionDefinitionId" ON config."ItemDefinitionItemOptionDefinition" USING btree ("ItemOptionDefinitionId");


--
-- Name: IX_ItemDefinitionItemSetGroup_ItemSetGroupId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinitionItemSetGroup_ItemSetGroupId" ON config."ItemDefinitionItemSetGroup" USING btree ("ItemSetGroupId");


--
-- Name: IX_ItemDefinition_ConsumeEffectId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinition_ConsumeEffectId" ON config."ItemDefinition" USING btree ("ConsumeEffectId");


--
-- Name: IX_ItemDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinition_GameConfigurationId" ON config."ItemDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemDefinition_ItemSlotId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinition_ItemSlotId" ON config."ItemDefinition" USING btree ("ItemSlotId");


--
-- Name: IX_ItemDefinition_SkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDefinition_SkillId" ON config."ItemDefinition" USING btree ("SkillId");


--
-- Name: IX_ItemDropItemGroupItemDefinition_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDropItemGroupItemDefinition_ItemDefinitionId" ON config."ItemDropItemGroupItemDefinition" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemDropItemGroup_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDropItemGroup_ItemDefinitionId" ON config."ItemDropItemGroup" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemDropItemGroup_MonsterId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemDropItemGroup_MonsterId" ON config."ItemDropItemGroup" USING btree ("MonsterId");


--
-- Name: IX_ItemLevelBonusTable_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemLevelBonusTable_GameConfigurationId" ON config."ItemLevelBonusTable" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemOfItemSet_BonusOptionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOfItemSet_BonusOptionId" ON config."ItemOfItemSet" USING btree ("BonusOptionId");


--
-- Name: IX_ItemOfItemSet_ItemDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOfItemSet_ItemDefinitionId" ON config."ItemOfItemSet" USING btree ("ItemDefinitionId");


--
-- Name: IX_ItemOfItemSet_ItemSetGroupId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOfItemSet_ItemSetGroupId" ON config."ItemOfItemSet" USING btree ("ItemSetGroupId");


--
-- Name: IX_ItemOptionCombinationBonus_BonusId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_ItemOptionCombinationBonus_BonusId" ON config."ItemOptionCombinationBonus" USING btree ("BonusId");


--
-- Name: IX_ItemOptionCombinationBonus_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOptionCombinationBonus_GameConfigurationId" ON config."ItemOptionCombinationBonus" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemOptionDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOptionDefinition_GameConfigurationId" ON config."ItemOptionDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemOptionOfLevel_IncreasableItemOptionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOptionOfLevel_IncreasableItemOptionId" ON config."ItemOptionOfLevel" USING btree ("IncreasableItemOptionId");


--
-- Name: IX_ItemOptionOfLevel_PowerUpDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_ItemOptionOfLevel_PowerUpDefinitionId" ON config."ItemOptionOfLevel" USING btree ("PowerUpDefinitionId");


--
-- Name: IX_ItemOptionType_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOptionType_GameConfigurationId" ON config."ItemOptionType" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemOption_OptionTypeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemOption_OptionTypeId" ON config."ItemOption" USING btree ("OptionTypeId");


--
-- Name: IX_ItemOption_PowerUpDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_ItemOption_PowerUpDefinitionId" ON config."ItemOption" USING btree ("PowerUpDefinitionId");


--
-- Name: IX_ItemSetGroup_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemSetGroup_GameConfigurationId" ON config."ItemSetGroup" USING btree ("GameConfigurationId");


--
-- Name: IX_ItemSetGroup_OptionsId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemSetGroup_OptionsId" ON config."ItemSetGroup" USING btree ("OptionsId");


--
-- Name: IX_ItemSlotType_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_ItemSlotType_GameConfigurationId" ON config."ItemSlotType" USING btree ("GameConfigurationId");


--
-- Name: IX_JewelMix_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_JewelMix_GameConfigurationId" ON config."JewelMix" USING btree ("GameConfigurationId");


--
-- Name: IX_JewelMix_MixedJewelId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_JewelMix_MixedJewelId" ON config."JewelMix" USING btree ("MixedJewelId");


--
-- Name: IX_JewelMix_SingleJewelId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_JewelMix_SingleJewelId" ON config."JewelMix" USING btree ("SingleJewelId");


--
-- Name: IX_LevelBonus_ItemLevelBonusTableId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_LevelBonus_ItemLevelBonusTableId" ON config."LevelBonus" USING btree ("ItemLevelBonusTableId");


--
-- Name: IX_MagicEffectDefinition_ChanceId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MagicEffectDefinition_ChanceId" ON config."MagicEffectDefinition" USING btree ("ChanceId");


--
-- Name: IX_MagicEffectDefinition_ChancePvpId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MagicEffectDefinition_ChancePvpId" ON config."MagicEffectDefinition" USING btree ("ChancePvpId");


--
-- Name: IX_MagicEffectDefinition_DurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MagicEffectDefinition_DurationId" ON config."MagicEffectDefinition" USING btree ("DurationId");


--
-- Name: IX_MagicEffectDefinition_DurationPvpId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MagicEffectDefinition_DurationPvpId" ON config."MagicEffectDefinition" USING btree ("DurationPvpId");


--
-- Name: IX_MagicEffectDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MagicEffectDefinition_GameConfigurationId" ON config."MagicEffectDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_MasterSkillDefinitionSkill_SkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MasterSkillDefinitionSkill_SkillId" ON config."MasterSkillDefinitionSkill" USING btree ("SkillId");


--
-- Name: IX_MasterSkillDefinition_ReplacedSkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MasterSkillDefinition_ReplacedSkillId" ON config."MasterSkillDefinition" USING btree ("ReplacedSkillId");


--
-- Name: IX_MasterSkillDefinition_RootId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MasterSkillDefinition_RootId" ON config."MasterSkillDefinition" USING btree ("RootId");


--
-- Name: IX_MasterSkillDefinition_TargetAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MasterSkillDefinition_TargetAttributeId" ON config."MasterSkillDefinition" USING btree ("TargetAttributeId");


--
-- Name: IX_MasterSkillRoot_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MasterSkillRoot_GameConfigurationId" ON config."MasterSkillRoot" USING btree ("GameConfigurationId");


--
-- Name: IX_MiniGameChangeEvent_MiniGameDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameChangeEvent_MiniGameDefinitionId" ON config."MiniGameChangeEvent" USING btree ("MiniGameDefinitionId");


--
-- Name: IX_MiniGameChangeEvent_SpawnAreaId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MiniGameChangeEvent_SpawnAreaId" ON config."MiniGameChangeEvent" USING btree ("SpawnAreaId");


--
-- Name: IX_MiniGameChangeEvent_TargetDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameChangeEvent_TargetDefinitionId" ON config."MiniGameChangeEvent" USING btree ("TargetDefinitionId");


--
-- Name: IX_MiniGameDefinition_EntranceId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameDefinition_EntranceId" ON config."MiniGameDefinition" USING btree ("EntranceId");


--
-- Name: IX_MiniGameDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameDefinition_GameConfigurationId" ON config."MiniGameDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_MiniGameDefinition_TicketItemId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameDefinition_TicketItemId" ON config."MiniGameDefinition" USING btree ("TicketItemId");


--
-- Name: IX_MiniGameReward_ItemRewardId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameReward_ItemRewardId" ON config."MiniGameReward" USING btree ("ItemRewardId");


--
-- Name: IX_MiniGameReward_MiniGameDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameReward_MiniGameDefinitionId" ON config."MiniGameReward" USING btree ("MiniGameDefinitionId");


--
-- Name: IX_MiniGameReward_RequiredKillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameReward_RequiredKillId" ON config."MiniGameReward" USING btree ("RequiredKillId");


--
-- Name: IX_MiniGameSpawnWave_MiniGameDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameSpawnWave_MiniGameDefinitionId" ON config."MiniGameSpawnWave" USING btree ("MiniGameDefinitionId");


--
-- Name: IX_MiniGameTerrainChange_MiniGameChangeEventId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MiniGameTerrainChange_MiniGameChangeEventId" ON config."MiniGameTerrainChange" USING btree ("MiniGameChangeEventId");


--
-- Name: IX_MonsterAttribute_AttributeDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterAttribute_AttributeDefinitionId" ON config."MonsterAttribute" USING btree ("AttributeDefinitionId");


--
-- Name: IX_MonsterAttribute_MonsterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterAttribute_MonsterDefinitionId" ON config."MonsterAttribute" USING btree ("MonsterDefinitionId");


--
-- Name: IX_MonsterDefinitionDropItemGroup_DropItemGroupId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterDefinitionDropItemGroup_DropItemGroupId" ON config."MonsterDefinitionDropItemGroup" USING btree ("DropItemGroupId");


--
-- Name: IX_MonsterDefinition_AttackSkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterDefinition_AttackSkillId" ON config."MonsterDefinition" USING btree ("AttackSkillId");


--
-- Name: IX_MonsterDefinition_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterDefinition_GameConfigurationId" ON config."MonsterDefinition" USING btree ("GameConfigurationId");


--
-- Name: IX_MonsterDefinition_MerchantStoreId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_MonsterDefinition_MerchantStoreId" ON config."MonsterDefinition" USING btree ("MerchantStoreId");


--
-- Name: IX_MonsterSpawnArea_GameMapId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterSpawnArea_GameMapId" ON config."MonsterSpawnArea" USING btree ("GameMapId");


--
-- Name: IX_MonsterSpawnArea_MonsterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_MonsterSpawnArea_MonsterDefinitionId" ON config."MonsterSpawnArea" USING btree ("MonsterDefinitionId");


--
-- Name: IX_PlugInConfiguration_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_PlugInConfiguration_GameConfigurationId" ON config."PlugInConfiguration" USING btree ("GameConfigurationId");


--
-- Name: IX_PowerUpDefinition_BoostId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_PowerUpDefinition_BoostId" ON config."PowerUpDefinition" USING btree ("BoostId");


--
-- Name: IX_PowerUpDefinition_GameMapDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_PowerUpDefinition_GameMapDefinitionId" ON config."PowerUpDefinition" USING btree ("GameMapDefinitionId");


--
-- Name: IX_PowerUpDefinition_MagicEffectDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_PowerUpDefinition_MagicEffectDefinitionId" ON config."PowerUpDefinition" USING btree ("MagicEffectDefinitionId");


--
-- Name: IX_PowerUpDefinition_MagicEffectDefinitionId1; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_PowerUpDefinition_MagicEffectDefinitionId1" ON config."PowerUpDefinition" USING btree ("MagicEffectDefinitionId1");


--
-- Name: IX_PowerUpDefinition_TargetAttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_PowerUpDefinition_TargetAttributeId" ON config."PowerUpDefinition" USING btree ("TargetAttributeId");


--
-- Name: IX_QuestDefinition_MonsterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestDefinition_MonsterDefinitionId" ON config."QuestDefinition" USING btree ("MonsterDefinitionId");


--
-- Name: IX_QuestDefinition_QualifiedCharacterId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestDefinition_QualifiedCharacterId" ON config."QuestDefinition" USING btree ("QualifiedCharacterId");


--
-- Name: IX_QuestDefinition_QuestGiverId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestDefinition_QuestGiverId" ON config."QuestDefinition" USING btree ("QuestGiverId");


--
-- Name: IX_QuestItemRequirement_DropItemGroupId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestItemRequirement_DropItemGroupId" ON config."QuestItemRequirement" USING btree ("DropItemGroupId");


--
-- Name: IX_QuestItemRequirement_ItemId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestItemRequirement_ItemId" ON config."QuestItemRequirement" USING btree ("ItemId");


--
-- Name: IX_QuestItemRequirement_QuestDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestItemRequirement_QuestDefinitionId" ON config."QuestItemRequirement" USING btree ("QuestDefinitionId");


--
-- Name: IX_QuestMonsterKillRequirement_MonsterId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestMonsterKillRequirement_MonsterId" ON config."QuestMonsterKillRequirement" USING btree ("MonsterId");


--
-- Name: IX_QuestMonsterKillRequirement_QuestDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestMonsterKillRequirement_QuestDefinitionId" ON config."QuestMonsterKillRequirement" USING btree ("QuestDefinitionId");


--
-- Name: IX_QuestReward_AttributeRewardId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestReward_AttributeRewardId" ON config."QuestReward" USING btree ("AttributeRewardId");


--
-- Name: IX_QuestReward_ItemRewardId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_QuestReward_ItemRewardId" ON config."QuestReward" USING btree ("ItemRewardId");


--
-- Name: IX_QuestReward_QuestDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestReward_QuestDefinitionId" ON config."QuestReward" USING btree ("QuestDefinitionId");


--
-- Name: IX_QuestReward_SkillRewardId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_QuestReward_SkillRewardId" ON config."QuestReward" USING btree ("SkillRewardId");


--
-- Name: IX_SkillCharacterClass_CharacterClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_SkillCharacterClass_CharacterClassId" ON config."SkillCharacterClass" USING btree ("CharacterClassId");


--
-- Name: IX_SkillComboStep_SkillComboDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_SkillComboStep_SkillComboDefinitionId" ON config."SkillComboStep" USING btree ("SkillComboDefinitionId");


--
-- Name: IX_SkillComboStep_SkillId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_SkillComboStep_SkillId" ON config."SkillComboStep" USING btree ("SkillId");


--
-- Name: IX_Skill_AreaSkillSettingsId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_Skill_AreaSkillSettingsId" ON config."Skill" USING btree ("AreaSkillSettingsId");


--
-- Name: IX_Skill_ElementalModifierTargetId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_Skill_ElementalModifierTargetId" ON config."Skill" USING btree ("ElementalModifierTargetId");


--
-- Name: IX_Skill_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_Skill_GameConfigurationId" ON config."Skill" USING btree ("GameConfigurationId");


--
-- Name: IX_Skill_MagicEffectDefId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_Skill_MagicEffectDefId" ON config."Skill" USING btree ("MagicEffectDefId");


--
-- Name: IX_Skill_MasterDefinitionId; Type: INDEX; Schema: config; Owner: -
--

CREATE UNIQUE INDEX "IX_Skill_MasterDefinitionId" ON config."Skill" USING btree ("MasterDefinitionId");


--
-- Name: IX_StatAttributeDefinition_AttributeId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_StatAttributeDefinition_AttributeId" ON config."StatAttributeDefinition" USING btree ("AttributeId");


--
-- Name: IX_StatAttributeDefinition_CharacterClassId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_StatAttributeDefinition_CharacterClassId" ON config."StatAttributeDefinition" USING btree ("CharacterClassId");


--
-- Name: IX_WarpInfo_GameConfigurationId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_WarpInfo_GameConfigurationId" ON config."WarpInfo" USING btree ("GameConfigurationId");


--
-- Name: IX_WarpInfo_GateId; Type: INDEX; Schema: config; Owner: -
--

CREATE INDEX "IX_WarpInfo_GateId" ON config."WarpInfo" USING btree ("GateId");


--
-- Name: IX_AccountCharacterClass_CharacterClassId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_AccountCharacterClass_CharacterClassId" ON data."AccountCharacterClass" USING btree ("CharacterClassId");


--
-- Name: IX_Account_LoginName; Type: INDEX; Schema: data; Owner: -
--

CREATE UNIQUE INDEX "IX_Account_LoginName" ON data."Account" USING btree ("LoginName");


--
-- Name: IX_Account_VaultId; Type: INDEX; Schema: data; Owner: -
--

CREATE UNIQUE INDEX "IX_Account_VaultId" ON data."Account" USING btree ("VaultId");


--
-- Name: IX_AppearanceData_CharacterClassId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_AppearanceData_CharacterClassId" ON data."AppearanceData" USING btree ("CharacterClassId");


--
-- Name: IX_CharacterDropItemGroup_DropItemGroupId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_CharacterDropItemGroup_DropItemGroupId" ON data."CharacterDropItemGroup" USING btree ("DropItemGroupId");


--
-- Name: IX_CharacterQuestState_ActiveQuestId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_CharacterQuestState_ActiveQuestId" ON data."CharacterQuestState" USING btree ("ActiveQuestId");


--
-- Name: IX_CharacterQuestState_CharacterId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_CharacterQuestState_CharacterId" ON data."CharacterQuestState" USING btree ("CharacterId");


--
-- Name: IX_CharacterQuestState_LastFinishedQuestId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_CharacterQuestState_LastFinishedQuestId" ON data."CharacterQuestState" USING btree ("LastFinishedQuestId");


--
-- Name: IX_Character_AccountId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_Character_AccountId" ON data."Character" USING btree ("AccountId");


--
-- Name: IX_Character_CharacterClassId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_Character_CharacterClassId" ON data."Character" USING btree ("CharacterClassId");


--
-- Name: IX_Character_CurrentMapId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_Character_CurrentMapId" ON data."Character" USING btree ("CurrentMapId");


--
-- Name: IX_Character_InventoryId; Type: INDEX; Schema: data; Owner: -
--

CREATE UNIQUE INDEX "IX_Character_InventoryId" ON data."Character" USING btree ("InventoryId");


--
-- Name: IX_Character_Name; Type: INDEX; Schema: data; Owner: -
--

CREATE UNIQUE INDEX "IX_Character_Name" ON data."Character" USING btree ("Name");


--
-- Name: IX_ItemAppearanceItemOptionType_ItemOptionTypeId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemAppearanceItemOptionType_ItemOptionTypeId" ON data."ItemAppearanceItemOptionType" USING btree ("ItemOptionTypeId");


--
-- Name: IX_ItemAppearance_AppearanceDataId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemAppearance_AppearanceDataId" ON data."ItemAppearance" USING btree ("AppearanceDataId");


--
-- Name: IX_ItemAppearance_DefinitionId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemAppearance_DefinitionId" ON data."ItemAppearance" USING btree ("DefinitionId");


--
-- Name: IX_ItemItemOfItemSet_ItemOfItemSetId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemItemOfItemSet_ItemOfItemSetId" ON data."ItemItemOfItemSet" USING btree ("ItemOfItemSetId");


--
-- Name: IX_ItemOptionLink_ItemId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemOptionLink_ItemId" ON data."ItemOptionLink" USING btree ("ItemId");


--
-- Name: IX_ItemOptionLink_ItemOptionId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_ItemOptionLink_ItemOptionId" ON data."ItemOptionLink" USING btree ("ItemOptionId");


--
-- Name: IX_Item_DefinitionId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_Item_DefinitionId" ON data."Item" USING btree ("DefinitionId");


--
-- Name: IX_Item_ItemStorageId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_Item_ItemStorageId" ON data."Item" USING btree ("ItemStorageId");


--
-- Name: IX_LetterBody_HeaderId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_LetterBody_HeaderId" ON data."LetterBody" USING btree ("HeaderId");


--
-- Name: IX_LetterBody_SenderAppearanceId; Type: INDEX; Schema: data; Owner: -
--

CREATE UNIQUE INDEX "IX_LetterBody_SenderAppearanceId" ON data."LetterBody" USING btree ("SenderAppearanceId");


--
-- Name: IX_LetterHeader_ReceiverId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_LetterHeader_ReceiverId" ON data."LetterHeader" USING btree ("ReceiverId");


--
-- Name: IX_MiniGameRankingEntry_CharacterId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_MiniGameRankingEntry_CharacterId" ON data."MiniGameRankingEntry" USING btree ("CharacterId");


--
-- Name: IX_MiniGameRankingEntry_MiniGameId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_MiniGameRankingEntry_MiniGameId" ON data."MiniGameRankingEntry" USING btree ("MiniGameId");


--
-- Name: IX_QuestMonsterKillRequirementState_CharacterQuestStateId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_QuestMonsterKillRequirementState_CharacterQuestStateId" ON data."QuestMonsterKillRequirementState" USING btree ("CharacterQuestStateId");


--
-- Name: IX_QuestMonsterKillRequirementState_RequirementId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_QuestMonsterKillRequirementState_RequirementId" ON data."QuestMonsterKillRequirementState" USING btree ("RequirementId");


--
-- Name: IX_SkillEntry_CharacterId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_SkillEntry_CharacterId" ON data."SkillEntry" USING btree ("CharacterId");


--
-- Name: IX_SkillEntry_SkillId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_SkillEntry_SkillId" ON data."SkillEntry" USING btree ("SkillId");


--
-- Name: IX_StatAttribute_AccountId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_StatAttribute_AccountId" ON data."StatAttribute" USING btree ("AccountId");


--
-- Name: IX_StatAttribute_CharacterId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_StatAttribute_CharacterId" ON data."StatAttribute" USING btree ("CharacterId");


--
-- Name: IX_StatAttribute_DefinitionId; Type: INDEX; Schema: data; Owner: -
--

CREATE INDEX "IX_StatAttribute_DefinitionId" ON data."StatAttribute" USING btree ("DefinitionId");


--
-- Name: IX_GuildMember_GuildId; Type: INDEX; Schema: guild; Owner: -
--

CREATE INDEX "IX_GuildMember_GuildId" ON guild."GuildMember" USING btree ("GuildId");


--
-- Name: IX_Guild_AllianceGuildId; Type: INDEX; Schema: guild; Owner: -
--

CREATE INDEX "IX_Guild_AllianceGuildId" ON guild."Guild" USING btree ("AllianceGuildId");


--
-- Name: IX_Guild_HostilityId; Type: INDEX; Schema: guild; Owner: -
--

CREATE INDEX "IX_Guild_HostilityId" ON guild."Guild" USING btree ("HostilityId");


--
-- Name: IX_Guild_Name; Type: INDEX; Schema: guild; Owner: -
--

CREATE UNIQUE INDEX "IX_Guild_Name" ON guild."Guild" USING btree ("Name");


--
-- Name: AttributeDefinition FK_AttributeDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeDefinition"
    ADD CONSTRAINT "FK_AttributeDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRelationship FK_AttributeRelationship_AttributeDefinition_InputAttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_AttributeDefinition_InputAttributeId" FOREIGN KEY ("InputAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: AttributeRelationship FK_AttributeRelationship_AttributeDefinition_OperandAttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_AttributeDefinition_OperandAttributeId" FOREIGN KEY ("OperandAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: AttributeRelationship FK_AttributeRelationship_AttributeDefinition_TargetAttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_AttributeDefinition_TargetAttributeId" FOREIGN KEY ("TargetAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: AttributeRelationship FK_AttributeRelationship_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRelationship FK_AttributeRelationship_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRelationship FK_AttributeRelationship_PowerUpDefinitionValue_PowerUpDefinit~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_PowerUpDefinitionValue_PowerUpDefinit~" FOREIGN KEY ("PowerUpDefinitionValueId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRelationship FK_AttributeRelationship_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRelationship"
    ADD CONSTRAINT "FK_AttributeRelationship_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRequirement FK_AttributeRequirement_AttributeDefinition_AttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "FK_AttributeRequirement_AttributeDefinition_AttributeId" FOREIGN KEY ("AttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: AttributeRequirement FK_AttributeRequirement_GameMapDefinition_GameMapDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "FK_AttributeRequirement_GameMapDefinition_GameMapDefinitionId" FOREIGN KEY ("GameMapDefinitionId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRequirement FK_AttributeRequirement_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "FK_AttributeRequirement_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRequirement FK_AttributeRequirement_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "FK_AttributeRequirement_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id") ON DELETE CASCADE;


--
-- Name: AttributeRequirement FK_AttributeRequirement_Skill_SkillId1; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."AttributeRequirement"
    ADD CONSTRAINT "FK_AttributeRequirement_Skill_SkillId1" FOREIGN KEY ("SkillId1") REFERENCES config."Skill"("Id") ON DELETE CASCADE;


--
-- Name: BattleZoneDefinition FK_BattleZoneDefinition_Rectangle_GroundId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."BattleZoneDefinition"
    ADD CONSTRAINT "FK_BattleZoneDefinition_Rectangle_GroundId" FOREIGN KEY ("GroundId") REFERENCES config."Rectangle"("Id") ON DELETE CASCADE;


--
-- Name: BattleZoneDefinition FK_BattleZoneDefinition_Rectangle_LeftGoalId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."BattleZoneDefinition"
    ADD CONSTRAINT "FK_BattleZoneDefinition_Rectangle_LeftGoalId" FOREIGN KEY ("LeftGoalId") REFERENCES config."Rectangle"("Id") ON DELETE CASCADE;


--
-- Name: BattleZoneDefinition FK_BattleZoneDefinition_Rectangle_RightGoalId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."BattleZoneDefinition"
    ADD CONSTRAINT "FK_BattleZoneDefinition_Rectangle_RightGoalId" FOREIGN KEY ("RightGoalId") REFERENCES config."Rectangle"("Id") ON DELETE CASCADE;


--
-- Name: Buff FK_Buff_MagicEffectDefinition_MagicEffectDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Buff"
    ADD CONSTRAINT "FK_Buff_MagicEffectDefinition_MagicEffectDefinitionId" FOREIGN KEY ("MagicEffectDefinitionId") REFERENCES config."MagicEffectDefinition"("Id") ON DELETE CASCADE;


--
-- Name: Buff FK_Buff_MonsterDefinition_MonsterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Buff"
    ADD CONSTRAINT "FK_Buff_MonsterDefinition_MonsterDefinitionId" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id") ON DELETE CASCADE;


--
-- Name: CharacterClass FK_CharacterClass_CharacterClass_NextGenerationClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CharacterClass"
    ADD CONSTRAINT "FK_CharacterClass_CharacterClass_NextGenerationClassId" FOREIGN KEY ("NextGenerationClassId") REFERENCES config."CharacterClass"("Id");


--
-- Name: CharacterClass FK_CharacterClass_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CharacterClass"
    ADD CONSTRAINT "FK_CharacterClass_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: CharacterClass FK_CharacterClass_GameMapDefinition_HomeMapId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CharacterClass"
    ADD CONSTRAINT "FK_CharacterClass_GameMapDefinition_HomeMapId" FOREIGN KEY ("HomeMapId") REFERENCES config."GameMapDefinition"("Id");


--
-- Name: CharacterClass FK_CharacterClass_SkillComboDefinition_ComboDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CharacterClass"
    ADD CONSTRAINT "FK_CharacterClass_SkillComboDefinition_ComboDefinitionId" FOREIGN KEY ("ComboDefinitionId") REFERENCES config."SkillComboDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ChatServerEndpoint FK_ChatServerEndpoint_ChatServerDefinition_ChatServerDefinitio~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ChatServerEndpoint"
    ADD CONSTRAINT "FK_ChatServerEndpoint_ChatServerDefinition_ChatServerDefinitio~" FOREIGN KEY ("ChatServerDefinitionId") REFERENCES config."ChatServerDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ChatServerEndpoint FK_ChatServerEndpoint_GameClientDefinition_ClientId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ChatServerEndpoint"
    ADD CONSTRAINT "FK_ChatServerEndpoint_GameClientDefinition_ClientId" FOREIGN KEY ("ClientId") REFERENCES config."GameClientDefinition"("Id");


--
-- Name: CombinationBonusRequirement FK_CombinationBonusRequirement_ItemOptionCombinationBonus_Item~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CombinationBonusRequirement"
    ADD CONSTRAINT "FK_CombinationBonusRequirement_ItemOptionCombinationBonus_Item~" FOREIGN KEY ("ItemOptionCombinationBonusId") REFERENCES config."ItemOptionCombinationBonus"("Id") ON DELETE CASCADE;


--
-- Name: CombinationBonusRequirement FK_CombinationBonusRequirement_ItemOptionType_OptionTypeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."CombinationBonusRequirement"
    ADD CONSTRAINT "FK_CombinationBonusRequirement_ItemOptionType_OptionTypeId" FOREIGN KEY ("OptionTypeId") REFERENCES config."ItemOptionType"("Id");


--
-- Name: ConnectServerDefinition FK_ConnectServerDefinition_GameClientDefinition_ClientId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConnectServerDefinition"
    ADD CONSTRAINT "FK_ConnectServerDefinition_GameClientDefinition_ClientId" FOREIGN KEY ("ClientId") REFERENCES config."GameClientDefinition"("Id");


--
-- Name: ConstValueAttribute FK_ConstValueAttribute_AttributeDefinition_DefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConstValueAttribute"
    ADD CONSTRAINT "FK_ConstValueAttribute_AttributeDefinition_DefinitionId" FOREIGN KEY ("DefinitionId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: ConstValueAttribute FK_ConstValueAttribute_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConstValueAttribute"
    ADD CONSTRAINT "FK_ConstValueAttribute_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: ConstValueAttribute FK_ConstValueAttribute_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ConstValueAttribute"
    ADD CONSTRAINT "FK_ConstValueAttribute_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: DropItemGroupItemDefinition FK_DropItemGroupItemDefinition_DropItemGroup_DropItemGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroupItemDefinition"
    ADD CONSTRAINT "FK_DropItemGroupItemDefinition_DropItemGroup_DropItemGroupId" FOREIGN KEY ("DropItemGroupId") REFERENCES config."DropItemGroup"("Id") ON DELETE CASCADE;


--
-- Name: DropItemGroupItemDefinition FK_DropItemGroupItemDefinition_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroupItemDefinition"
    ADD CONSTRAINT "FK_DropItemGroupItemDefinition_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: DropItemGroup FK_DropItemGroup_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroup"
    ADD CONSTRAINT "FK_DropItemGroup_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: DropItemGroup FK_DropItemGroup_MonsterDefinition_MonsterId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DropItemGroup"
    ADD CONSTRAINT "FK_DropItemGroup_MonsterDefinition_MonsterId" FOREIGN KEY ("MonsterId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: DuelArea FK_DuelArea_DuelConfiguration_DuelConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelArea"
    ADD CONSTRAINT "FK_DuelArea_DuelConfiguration_DuelConfigurationId" FOREIGN KEY ("DuelConfigurationId") REFERENCES config."DuelConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: DuelArea FK_DuelArea_ExitGate_FirstPlayerGateId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelArea"
    ADD CONSTRAINT "FK_DuelArea_ExitGate_FirstPlayerGateId" FOREIGN KEY ("FirstPlayerGateId") REFERENCES config."ExitGate"("Id");


--
-- Name: DuelArea FK_DuelArea_ExitGate_SecondPlayerGateId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelArea"
    ADD CONSTRAINT "FK_DuelArea_ExitGate_SecondPlayerGateId" FOREIGN KEY ("SecondPlayerGateId") REFERENCES config."ExitGate"("Id");


--
-- Name: DuelArea FK_DuelArea_ExitGate_SpectatorsGateId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelArea"
    ADD CONSTRAINT "FK_DuelArea_ExitGate_SpectatorsGateId" FOREIGN KEY ("SpectatorsGateId") REFERENCES config."ExitGate"("Id");


--
-- Name: DuelConfiguration FK_DuelConfiguration_ExitGate_ExitId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."DuelConfiguration"
    ADD CONSTRAINT "FK_DuelConfiguration_ExitGate_ExitId" FOREIGN KEY ("ExitId") REFERENCES config."ExitGate"("Id");


--
-- Name: EnterGate FK_EnterGate_ExitGate_TargetGateId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."EnterGate"
    ADD CONSTRAINT "FK_EnterGate_ExitGate_TargetGateId" FOREIGN KEY ("TargetGateId") REFERENCES config."ExitGate"("Id");


--
-- Name: EnterGate FK_EnterGate_GameMapDefinition_GameMapDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."EnterGate"
    ADD CONSTRAINT "FK_EnterGate_GameMapDefinition_GameMapDefinitionId" FOREIGN KEY ("GameMapDefinitionId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ExitGate FK_ExitGate_GameMapDefinition_MapId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ExitGate"
    ADD CONSTRAINT "FK_ExitGate_GameMapDefinition_MapId" FOREIGN KEY ("MapId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: GameConfiguration FK_GameConfiguration_DuelConfiguration_DuelConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameConfiguration"
    ADD CONSTRAINT "FK_GameConfiguration_DuelConfiguration_DuelConfigurationId" FOREIGN KEY ("DuelConfigurationId") REFERENCES config."DuelConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: GameMapDefinitionDropItemGroup FK_GameMapDefinitionDropItemGroup_DropItemGroup_DropItemGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinitionDropItemGroup"
    ADD CONSTRAINT "FK_GameMapDefinitionDropItemGroup_DropItemGroup_DropItemGroupId" FOREIGN KEY ("DropItemGroupId") REFERENCES config."DropItemGroup"("Id") ON DELETE CASCADE;


--
-- Name: GameMapDefinitionDropItemGroup FK_GameMapDefinitionDropItemGroup_GameMapDefinition_GameMapDef~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinitionDropItemGroup"
    ADD CONSTRAINT "FK_GameMapDefinitionDropItemGroup_GameMapDefinition_GameMapDef~" FOREIGN KEY ("GameMapDefinitionId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: GameMapDefinition FK_GameMapDefinition_BattleZoneDefinition_BattleZoneId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinition"
    ADD CONSTRAINT "FK_GameMapDefinition_BattleZoneDefinition_BattleZoneId" FOREIGN KEY ("BattleZoneId") REFERENCES config."BattleZoneDefinition"("Id") ON DELETE CASCADE;


--
-- Name: GameMapDefinition FK_GameMapDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinition"
    ADD CONSTRAINT "FK_GameMapDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: GameMapDefinition FK_GameMapDefinition_GameMapDefinition_SafezoneMapId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameMapDefinition"
    ADD CONSTRAINT "FK_GameMapDefinition_GameMapDefinition_SafezoneMapId" FOREIGN KEY ("SafezoneMapId") REFERENCES config."GameMapDefinition"("Id");


--
-- Name: GameServerConfigurationGameMapDefinition FK_GameServerConfigurationGameMapDefinition_GameMapDefinition_~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerConfigurationGameMapDefinition"
    ADD CONSTRAINT "FK_GameServerConfigurationGameMapDefinition_GameMapDefinition_~" FOREIGN KEY ("GameMapDefinitionId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: GameServerConfigurationGameMapDefinition FK_GameServerConfigurationGameMapDefinition_GameServerConfigur~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerConfigurationGameMapDefinition"
    ADD CONSTRAINT "FK_GameServerConfigurationGameMapDefinition_GameServerConfigur~" FOREIGN KEY ("GameServerConfigurationId") REFERENCES config."GameServerConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: GameServerDefinition FK_GameServerDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerDefinition"
    ADD CONSTRAINT "FK_GameServerDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id");


--
-- Name: GameServerDefinition FK_GameServerDefinition_GameServerConfiguration_ServerConfigur~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerDefinition"
    ADD CONSTRAINT "FK_GameServerDefinition_GameServerConfiguration_ServerConfigur~" FOREIGN KEY ("ServerConfigurationId") REFERENCES config."GameServerConfiguration"("Id");


--
-- Name: GameServerEndpoint FK_GameServerEndpoint_GameClientDefinition_ClientId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerEndpoint"
    ADD CONSTRAINT "FK_GameServerEndpoint_GameClientDefinition_ClientId" FOREIGN KEY ("ClientId") REFERENCES config."GameClientDefinition"("Id");


--
-- Name: GameServerEndpoint FK_GameServerEndpoint_GameServerDefinition_GameServerDefinitio~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."GameServerEndpoint"
    ADD CONSTRAINT "FK_GameServerEndpoint_GameServerDefinition_GameServerDefinitio~" FOREIGN KEY ("GameServerDefinitionId") REFERENCES config."GameServerDefinition"("Id") ON DELETE CASCADE;


--
-- Name: IncreasableItemOption FK_IncreasableItemOption_ItemOptionDefinition_ItemOptionDefini~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."IncreasableItemOption"
    ADD CONSTRAINT "FK_IncreasableItemOption_ItemOptionDefinition_ItemOptionDefini~" FOREIGN KEY ("ItemOptionDefinitionId") REFERENCES config."ItemOptionDefinition"("Id") ON DELETE CASCADE;


--
-- Name: IncreasableItemOption FK_IncreasableItemOption_ItemOptionType_OptionTypeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."IncreasableItemOption"
    ADD CONSTRAINT "FK_IncreasableItemOption_ItemOptionType_OptionTypeId" FOREIGN KEY ("OptionTypeId") REFERENCES config."ItemOptionType"("Id");


--
-- Name: IncreasableItemOption FK_IncreasableItemOption_PowerUpDefinition_PowerUpDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."IncreasableItemOption"
    ADD CONSTRAINT "FK_IncreasableItemOption_PowerUpDefinition_PowerUpDefinitionId" FOREIGN KEY ("PowerUpDefinitionId") REFERENCES config."PowerUpDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemBasePowerUpDefinition FK_ItemBasePowerUpDefinition_AttributeDefinition_TargetAttribu~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemBasePowerUpDefinition"
    ADD CONSTRAINT "FK_ItemBasePowerUpDefinition_AttributeDefinition_TargetAttribu~" FOREIGN KEY ("TargetAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: ItemBasePowerUpDefinition FK_ItemBasePowerUpDefinition_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemBasePowerUpDefinition"
    ADD CONSTRAINT "FK_ItemBasePowerUpDefinition_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemBasePowerUpDefinition FK_ItemBasePowerUpDefinition_ItemLevelBonusTable_BonusPerLevel~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemBasePowerUpDefinition"
    ADD CONSTRAINT "FK_ItemBasePowerUpDefinition_ItemLevelBonusTable_BonusPerLevel~" FOREIGN KEY ("BonusPerLevelTableId") REFERENCES config."ItemLevelBonusTable"("Id");


--
-- Name: ItemCraftingRequiredItemItemDefinition FK_ItemCraftingRequiredItemItemDefinition_ItemCraftingRequired~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemDefinition"
    ADD CONSTRAINT "FK_ItemCraftingRequiredItemItemDefinition_ItemCraftingRequired~" FOREIGN KEY ("ItemCraftingRequiredItemId") REFERENCES config."ItemCraftingRequiredItem"("Id") ON DELETE CASCADE;


--
-- Name: ItemCraftingRequiredItemItemDefinition FK_ItemCraftingRequiredItemItemDefinition_ItemDefinition_ItemD~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemDefinition"
    ADD CONSTRAINT "FK_ItemCraftingRequiredItemItemDefinition_ItemDefinition_ItemD~" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemCraftingRequiredItemItemOptionType FK_ItemCraftingRequiredItemItemOptionType_ItemCraftingRequired~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemOptionType"
    ADD CONSTRAINT "FK_ItemCraftingRequiredItemItemOptionType_ItemCraftingRequired~" FOREIGN KEY ("ItemCraftingRequiredItemId") REFERENCES config."ItemCraftingRequiredItem"("Id") ON DELETE CASCADE;


--
-- Name: ItemCraftingRequiredItemItemOptionType FK_ItemCraftingRequiredItemItemOptionType_ItemOptionType_ItemO~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItemItemOptionType"
    ADD CONSTRAINT "FK_ItemCraftingRequiredItemItemOptionType_ItemOptionType_ItemO~" FOREIGN KEY ("ItemOptionTypeId") REFERENCES config."ItemOptionType"("Id") ON DELETE CASCADE;


--
-- Name: ItemCraftingRequiredItem FK_ItemCraftingRequiredItem_SimpleCraftingSettings_SimpleCraft~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingRequiredItem"
    ADD CONSTRAINT "FK_ItemCraftingRequiredItem_SimpleCraftingSettings_SimpleCraft~" FOREIGN KEY ("SimpleCraftingSettingsId") REFERENCES config."SimpleCraftingSettings"("Id") ON DELETE CASCADE;


--
-- Name: ItemCraftingResultItem FK_ItemCraftingResultItem_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingResultItem"
    ADD CONSTRAINT "FK_ItemCraftingResultItem_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: ItemCraftingResultItem FK_ItemCraftingResultItem_SimpleCraftingSettings_SimpleCraftin~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCraftingResultItem"
    ADD CONSTRAINT "FK_ItemCraftingResultItem_SimpleCraftingSettings_SimpleCraftin~" FOREIGN KEY ("SimpleCraftingSettingsId") REFERENCES config."SimpleCraftingSettings"("Id") ON DELETE CASCADE;


--
-- Name: ItemCrafting FK_ItemCrafting_MonsterDefinition_MonsterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCrafting"
    ADD CONSTRAINT "FK_ItemCrafting_MonsterDefinition_MonsterDefinitionId" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemCrafting FK_ItemCrafting_SimpleCraftingSettings_SimpleCraftingSettingsId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemCrafting"
    ADD CONSTRAINT "FK_ItemCrafting_SimpleCraftingSettings_SimpleCraftingSettingsId" FOREIGN KEY ("SimpleCraftingSettingsId") REFERENCES config."SimpleCraftingSettings"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionCharacterClass FK_ItemDefinitionCharacterClass_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionCharacterClass"
    ADD CONSTRAINT "FK_ItemDefinitionCharacterClass_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionCharacterClass FK_ItemDefinitionCharacterClass_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionCharacterClass"
    ADD CONSTRAINT "FK_ItemDefinitionCharacterClass_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionItemOptionDefinition FK_ItemDefinitionItemOptionDefinition_ItemDefinition_ItemDefin~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemOptionDefinition"
    ADD CONSTRAINT "FK_ItemDefinitionItemOptionDefinition_ItemDefinition_ItemDefin~" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionItemOptionDefinition FK_ItemDefinitionItemOptionDefinition_ItemOptionDefinition_Ite~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemOptionDefinition"
    ADD CONSTRAINT "FK_ItemDefinitionItemOptionDefinition_ItemOptionDefinition_Ite~" FOREIGN KEY ("ItemOptionDefinitionId") REFERENCES config."ItemOptionDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionItemSetGroup FK_ItemDefinitionItemSetGroup_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemSetGroup"
    ADD CONSTRAINT "FK_ItemDefinitionItemSetGroup_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinitionItemSetGroup FK_ItemDefinitionItemSetGroup_ItemSetGroup_ItemSetGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinitionItemSetGroup"
    ADD CONSTRAINT "FK_ItemDefinitionItemSetGroup_ItemSetGroup_ItemSetGroupId" FOREIGN KEY ("ItemSetGroupId") REFERENCES config."ItemSetGroup"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinition FK_ItemDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinition"
    ADD CONSTRAINT "FK_ItemDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemDefinition FK_ItemDefinition_ItemSlotType_ItemSlotId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinition"
    ADD CONSTRAINT "FK_ItemDefinition_ItemSlotType_ItemSlotId" FOREIGN KEY ("ItemSlotId") REFERENCES config."ItemSlotType"("Id");


--
-- Name: ItemDefinition FK_ItemDefinition_MagicEffectDefinition_ConsumeEffectId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinition"
    ADD CONSTRAINT "FK_ItemDefinition_MagicEffectDefinition_ConsumeEffectId" FOREIGN KEY ("ConsumeEffectId") REFERENCES config."MagicEffectDefinition"("Id");


--
-- Name: ItemDefinition FK_ItemDefinition_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDefinition"
    ADD CONSTRAINT "FK_ItemDefinition_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id");


--
-- Name: ItemDropItemGroupItemDefinition FK_ItemDropItemGroupItemDefinition_ItemDefinition_ItemDefiniti~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroupItemDefinition"
    ADD CONSTRAINT "FK_ItemDropItemGroupItemDefinition_ItemDefinition_ItemDefiniti~" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDropItemGroupItemDefinition FK_ItemDropItemGroupItemDefinition_ItemDropItemGroup_ItemDropI~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroupItemDefinition"
    ADD CONSTRAINT "FK_ItemDropItemGroupItemDefinition_ItemDropItemGroup_ItemDropI~" FOREIGN KEY ("ItemDropItemGroupId") REFERENCES config."ItemDropItemGroup"("Id") ON DELETE CASCADE;


--
-- Name: ItemDropItemGroup FK_ItemDropItemGroup_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroup"
    ADD CONSTRAINT "FK_ItemDropItemGroup_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemDropItemGroup FK_ItemDropItemGroup_MonsterDefinition_MonsterId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemDropItemGroup"
    ADD CONSTRAINT "FK_ItemDropItemGroup_MonsterDefinition_MonsterId" FOREIGN KEY ("MonsterId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: ItemLevelBonusTable FK_ItemLevelBonusTable_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemLevelBonusTable"
    ADD CONSTRAINT "FK_ItemLevelBonusTable_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemOfItemSet FK_ItemOfItemSet_IncreasableItemOption_BonusOptionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOfItemSet"
    ADD CONSTRAINT "FK_ItemOfItemSet_IncreasableItemOption_BonusOptionId" FOREIGN KEY ("BonusOptionId") REFERENCES config."IncreasableItemOption"("Id");


--
-- Name: ItemOfItemSet FK_ItemOfItemSet_ItemDefinition_ItemDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOfItemSet"
    ADD CONSTRAINT "FK_ItemOfItemSet_ItemDefinition_ItemDefinitionId" FOREIGN KEY ("ItemDefinitionId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: ItemOfItemSet FK_ItemOfItemSet_ItemSetGroup_ItemSetGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOfItemSet"
    ADD CONSTRAINT "FK_ItemOfItemSet_ItemSetGroup_ItemSetGroupId" FOREIGN KEY ("ItemSetGroupId") REFERENCES config."ItemSetGroup"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionCombinationBonus FK_ItemOptionCombinationBonus_GameConfiguration_GameConfigurat~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionCombinationBonus"
    ADD CONSTRAINT "FK_ItemOptionCombinationBonus_GameConfiguration_GameConfigurat~" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionCombinationBonus FK_ItemOptionCombinationBonus_PowerUpDefinition_BonusId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionCombinationBonus"
    ADD CONSTRAINT "FK_ItemOptionCombinationBonus_PowerUpDefinition_BonusId" FOREIGN KEY ("BonusId") REFERENCES config."PowerUpDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionDefinition FK_ItemOptionDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionDefinition"
    ADD CONSTRAINT "FK_ItemOptionDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionOfLevel FK_ItemOptionOfLevel_IncreasableItemOption_IncreasableItemOpti~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionOfLevel"
    ADD CONSTRAINT "FK_ItemOptionOfLevel_IncreasableItemOption_IncreasableItemOpti~" FOREIGN KEY ("IncreasableItemOptionId") REFERENCES config."IncreasableItemOption"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionOfLevel FK_ItemOptionOfLevel_PowerUpDefinition_PowerUpDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionOfLevel"
    ADD CONSTRAINT "FK_ItemOptionOfLevel_PowerUpDefinition_PowerUpDefinitionId" FOREIGN KEY ("PowerUpDefinitionId") REFERENCES config."PowerUpDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionType FK_ItemOptionType_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOptionType"
    ADD CONSTRAINT "FK_ItemOptionType_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemOption FK_ItemOption_ItemOptionType_OptionTypeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOption"
    ADD CONSTRAINT "FK_ItemOption_ItemOptionType_OptionTypeId" FOREIGN KEY ("OptionTypeId") REFERENCES config."ItemOptionType"("Id");


--
-- Name: ItemOption FK_ItemOption_PowerUpDefinition_PowerUpDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemOption"
    ADD CONSTRAINT "FK_ItemOption_PowerUpDefinition_PowerUpDefinitionId" FOREIGN KEY ("PowerUpDefinitionId") REFERENCES config."PowerUpDefinition"("Id") ON DELETE CASCADE;


--
-- Name: ItemSetGroup FK_ItemSetGroup_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemSetGroup"
    ADD CONSTRAINT "FK_ItemSetGroup_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: ItemSetGroup FK_ItemSetGroup_ItemOptionDefinition_OptionsId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemSetGroup"
    ADD CONSTRAINT "FK_ItemSetGroup_ItemOptionDefinition_OptionsId" FOREIGN KEY ("OptionsId") REFERENCES config."ItemOptionDefinition"("Id");


--
-- Name: ItemSlotType FK_ItemSlotType_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."ItemSlotType"
    ADD CONSTRAINT "FK_ItemSlotType_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: JewelMix FK_JewelMix_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."JewelMix"
    ADD CONSTRAINT "FK_JewelMix_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: JewelMix FK_JewelMix_ItemDefinition_MixedJewelId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."JewelMix"
    ADD CONSTRAINT "FK_JewelMix_ItemDefinition_MixedJewelId" FOREIGN KEY ("MixedJewelId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: JewelMix FK_JewelMix_ItemDefinition_SingleJewelId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."JewelMix"
    ADD CONSTRAINT "FK_JewelMix_ItemDefinition_SingleJewelId" FOREIGN KEY ("SingleJewelId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: LevelBonus FK_LevelBonus_ItemLevelBonusTable_ItemLevelBonusTableId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."LevelBonus"
    ADD CONSTRAINT "FK_LevelBonus_ItemLevelBonusTable_ItemLevelBonusTableId" FOREIGN KEY ("ItemLevelBonusTableId") REFERENCES config."ItemLevelBonusTable"("Id") ON DELETE CASCADE;


--
-- Name: MagicEffectDefinition FK_MagicEffectDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "FK_MagicEffectDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: MagicEffectDefinition FK_MagicEffectDefinition_PowerUpDefinitionValue_ChanceId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "FK_MagicEffectDefinition_PowerUpDefinitionValue_ChanceId" FOREIGN KEY ("ChanceId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: MagicEffectDefinition FK_MagicEffectDefinition_PowerUpDefinitionValue_ChancePvpId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "FK_MagicEffectDefinition_PowerUpDefinitionValue_ChancePvpId" FOREIGN KEY ("ChancePvpId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: MagicEffectDefinition FK_MagicEffectDefinition_PowerUpDefinitionValue_DurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "FK_MagicEffectDefinition_PowerUpDefinitionValue_DurationId" FOREIGN KEY ("DurationId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: MagicEffectDefinition FK_MagicEffectDefinition_PowerUpDefinitionValue_DurationPvpId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MagicEffectDefinition"
    ADD CONSTRAINT "FK_MagicEffectDefinition_PowerUpDefinitionValue_DurationPvpId" FOREIGN KEY ("DurationPvpId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: MasterSkillDefinitionSkill FK_MasterSkillDefinitionSkill_MasterSkillDefinition_MasterSkil~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinitionSkill"
    ADD CONSTRAINT "FK_MasterSkillDefinitionSkill_MasterSkillDefinition_MasterSkil~" FOREIGN KEY ("MasterSkillDefinitionId") REFERENCES config."MasterSkillDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MasterSkillDefinitionSkill FK_MasterSkillDefinitionSkill_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinitionSkill"
    ADD CONSTRAINT "FK_MasterSkillDefinitionSkill_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id") ON DELETE CASCADE;


--
-- Name: MasterSkillDefinition FK_MasterSkillDefinition_AttributeDefinition_TargetAttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinition"
    ADD CONSTRAINT "FK_MasterSkillDefinition_AttributeDefinition_TargetAttributeId" FOREIGN KEY ("TargetAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: MasterSkillDefinition FK_MasterSkillDefinition_MasterSkillRoot_RootId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinition"
    ADD CONSTRAINT "FK_MasterSkillDefinition_MasterSkillRoot_RootId" FOREIGN KEY ("RootId") REFERENCES config."MasterSkillRoot"("Id");


--
-- Name: MasterSkillDefinition FK_MasterSkillDefinition_Skill_ReplacedSkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillDefinition"
    ADD CONSTRAINT "FK_MasterSkillDefinition_Skill_ReplacedSkillId" FOREIGN KEY ("ReplacedSkillId") REFERENCES config."Skill"("Id");


--
-- Name: MasterSkillRoot FK_MasterSkillRoot_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MasterSkillRoot"
    ADD CONSTRAINT "FK_MasterSkillRoot_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameChangeEvent FK_MiniGameChangeEvent_MiniGameDefinition_MiniGameDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameChangeEvent"
    ADD CONSTRAINT "FK_MiniGameChangeEvent_MiniGameDefinition_MiniGameDefinitionId" FOREIGN KEY ("MiniGameDefinitionId") REFERENCES config."MiniGameDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameChangeEvent FK_MiniGameChangeEvent_MonsterDefinition_TargetDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameChangeEvent"
    ADD CONSTRAINT "FK_MiniGameChangeEvent_MonsterDefinition_TargetDefinitionId" FOREIGN KEY ("TargetDefinitionId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: MiniGameChangeEvent FK_MiniGameChangeEvent_MonsterSpawnArea_SpawnAreaId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameChangeEvent"
    ADD CONSTRAINT "FK_MiniGameChangeEvent_MonsterSpawnArea_SpawnAreaId" FOREIGN KEY ("SpawnAreaId") REFERENCES config."MonsterSpawnArea"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameDefinition FK_MiniGameDefinition_ExitGate_EntranceId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameDefinition"
    ADD CONSTRAINT "FK_MiniGameDefinition_ExitGate_EntranceId" FOREIGN KEY ("EntranceId") REFERENCES config."ExitGate"("Id");


--
-- Name: MiniGameDefinition FK_MiniGameDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameDefinition"
    ADD CONSTRAINT "FK_MiniGameDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameDefinition FK_MiniGameDefinition_ItemDefinition_TicketItemId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameDefinition"
    ADD CONSTRAINT "FK_MiniGameDefinition_ItemDefinition_TicketItemId" FOREIGN KEY ("TicketItemId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: MiniGameReward FK_MiniGameReward_DropItemGroup_ItemRewardId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameReward"
    ADD CONSTRAINT "FK_MiniGameReward_DropItemGroup_ItemRewardId" FOREIGN KEY ("ItemRewardId") REFERENCES config."DropItemGroup"("Id");


--
-- Name: MiniGameReward FK_MiniGameReward_MiniGameDefinition_MiniGameDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameReward"
    ADD CONSTRAINT "FK_MiniGameReward_MiniGameDefinition_MiniGameDefinitionId" FOREIGN KEY ("MiniGameDefinitionId") REFERENCES config."MiniGameDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameReward FK_MiniGameReward_MonsterDefinition_RequiredKillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameReward"
    ADD CONSTRAINT "FK_MiniGameReward_MonsterDefinition_RequiredKillId" FOREIGN KEY ("RequiredKillId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: MiniGameSpawnWave FK_MiniGameSpawnWave_MiniGameDefinition_MiniGameDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameSpawnWave"
    ADD CONSTRAINT "FK_MiniGameSpawnWave_MiniGameDefinition_MiniGameDefinitionId" FOREIGN KEY ("MiniGameDefinitionId") REFERENCES config."MiniGameDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameTerrainChange FK_MiniGameTerrainChange_MiniGameChangeEvent_MiniGameChangeEve~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MiniGameTerrainChange"
    ADD CONSTRAINT "FK_MiniGameTerrainChange_MiniGameChangeEvent_MiniGameChangeEve~" FOREIGN KEY ("MiniGameChangeEventId") REFERENCES config."MiniGameChangeEvent"("Id") ON DELETE CASCADE;


--
-- Name: MonsterAttribute FK_MonsterAttribute_AttributeDefinition_AttributeDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterAttribute"
    ADD CONSTRAINT "FK_MonsterAttribute_AttributeDefinition_AttributeDefinitionId" FOREIGN KEY ("AttributeDefinitionId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: MonsterAttribute FK_MonsterAttribute_MonsterDefinition_MonsterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterAttribute"
    ADD CONSTRAINT "FK_MonsterAttribute_MonsterDefinition_MonsterDefinitionId" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MonsterDefinitionDropItemGroup FK_MonsterDefinitionDropItemGroup_DropItemGroup_DropItemGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinitionDropItemGroup"
    ADD CONSTRAINT "FK_MonsterDefinitionDropItemGroup_DropItemGroup_DropItemGroupId" FOREIGN KEY ("DropItemGroupId") REFERENCES config."DropItemGroup"("Id") ON DELETE CASCADE;


--
-- Name: MonsterDefinitionDropItemGroup FK_MonsterDefinitionDropItemGroup_MonsterDefinition_MonsterDef~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinitionDropItemGroup"
    ADD CONSTRAINT "FK_MonsterDefinitionDropItemGroup_MonsterDefinition_MonsterDef~" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MonsterDefinition FK_MonsterDefinition_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinition"
    ADD CONSTRAINT "FK_MonsterDefinition_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: MonsterDefinition FK_MonsterDefinition_ItemStorage_MerchantStoreId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinition"
    ADD CONSTRAINT "FK_MonsterDefinition_ItemStorage_MerchantStoreId" FOREIGN KEY ("MerchantStoreId") REFERENCES data."ItemStorage"("Id") ON DELETE CASCADE;


--
-- Name: MonsterDefinition FK_MonsterDefinition_Skill_AttackSkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterDefinition"
    ADD CONSTRAINT "FK_MonsterDefinition_Skill_AttackSkillId" FOREIGN KEY ("AttackSkillId") REFERENCES config."Skill"("Id");


--
-- Name: MonsterSpawnArea FK_MonsterSpawnArea_GameMapDefinition_GameMapId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterSpawnArea"
    ADD CONSTRAINT "FK_MonsterSpawnArea_GameMapDefinition_GameMapId" FOREIGN KEY ("GameMapId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: MonsterSpawnArea FK_MonsterSpawnArea_MonsterDefinition_MonsterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."MonsterSpawnArea"
    ADD CONSTRAINT "FK_MonsterSpawnArea_MonsterDefinition_MonsterDefinitionId" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: PlugInConfiguration FK_PlugInConfiguration_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PlugInConfiguration"
    ADD CONSTRAINT "FK_PlugInConfiguration_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: PowerUpDefinition FK_PowerUpDefinition_AttributeDefinition_TargetAttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "FK_PowerUpDefinition_AttributeDefinition_TargetAttributeId" FOREIGN KEY ("TargetAttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: PowerUpDefinition FK_PowerUpDefinition_GameMapDefinition_GameMapDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "FK_PowerUpDefinition_GameMapDefinition_GameMapDefinitionId" FOREIGN KEY ("GameMapDefinitionId") REFERENCES config."GameMapDefinition"("Id") ON DELETE CASCADE;


--
-- Name: PowerUpDefinition FK_PowerUpDefinition_MagicEffectDefinition_MagicEffectDefiniti~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "FK_PowerUpDefinition_MagicEffectDefinition_MagicEffectDefiniti~" FOREIGN KEY ("MagicEffectDefinitionId") REFERENCES config."MagicEffectDefinition"("Id") ON DELETE CASCADE;


--
-- Name: PowerUpDefinition FK_PowerUpDefinition_MagicEffectDefinition_MagicEffectDefinit~1; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "FK_PowerUpDefinition_MagicEffectDefinition_MagicEffectDefinit~1" FOREIGN KEY ("MagicEffectDefinitionId1") REFERENCES config."MagicEffectDefinition"("Id") ON DELETE CASCADE;


--
-- Name: PowerUpDefinition FK_PowerUpDefinition_PowerUpDefinitionValue_BoostId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."PowerUpDefinition"
    ADD CONSTRAINT "FK_PowerUpDefinition_PowerUpDefinitionValue_BoostId" FOREIGN KEY ("BoostId") REFERENCES config."PowerUpDefinitionValue"("Id") ON DELETE CASCADE;


--
-- Name: QuestDefinition FK_QuestDefinition_CharacterClass_QualifiedCharacterId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestDefinition"
    ADD CONSTRAINT "FK_QuestDefinition_CharacterClass_QualifiedCharacterId" FOREIGN KEY ("QualifiedCharacterId") REFERENCES config."CharacterClass"("Id");


--
-- Name: QuestDefinition FK_QuestDefinition_MonsterDefinition_MonsterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestDefinition"
    ADD CONSTRAINT "FK_QuestDefinition_MonsterDefinition_MonsterDefinitionId" FOREIGN KEY ("MonsterDefinitionId") REFERENCES config."MonsterDefinition"("Id") ON DELETE CASCADE;


--
-- Name: QuestDefinition FK_QuestDefinition_MonsterDefinition_QuestGiverId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestDefinition"
    ADD CONSTRAINT "FK_QuestDefinition_MonsterDefinition_QuestGiverId" FOREIGN KEY ("QuestGiverId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: QuestItemRequirement FK_QuestItemRequirement_DropItemGroup_DropItemGroupId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestItemRequirement"
    ADD CONSTRAINT "FK_QuestItemRequirement_DropItemGroup_DropItemGroupId" FOREIGN KEY ("DropItemGroupId") REFERENCES config."DropItemGroup"("Id");


--
-- Name: QuestItemRequirement FK_QuestItemRequirement_ItemDefinition_ItemId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestItemRequirement"
    ADD CONSTRAINT "FK_QuestItemRequirement_ItemDefinition_ItemId" FOREIGN KEY ("ItemId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: QuestItemRequirement FK_QuestItemRequirement_QuestDefinition_QuestDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestItemRequirement"
    ADD CONSTRAINT "FK_QuestItemRequirement_QuestDefinition_QuestDefinitionId" FOREIGN KEY ("QuestDefinitionId") REFERENCES config."QuestDefinition"("Id") ON DELETE CASCADE;


--
-- Name: QuestMonsterKillRequirement FK_QuestMonsterKillRequirement_MonsterDefinition_MonsterId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestMonsterKillRequirement"
    ADD CONSTRAINT "FK_QuestMonsterKillRequirement_MonsterDefinition_MonsterId" FOREIGN KEY ("MonsterId") REFERENCES config."MonsterDefinition"("Id");


--
-- Name: QuestMonsterKillRequirement FK_QuestMonsterKillRequirement_QuestDefinition_QuestDefinition~; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestMonsterKillRequirement"
    ADD CONSTRAINT "FK_QuestMonsterKillRequirement_QuestDefinition_QuestDefinition~" FOREIGN KEY ("QuestDefinitionId") REFERENCES config."QuestDefinition"("Id") ON DELETE CASCADE;


--
-- Name: QuestReward FK_QuestReward_AttributeDefinition_AttributeRewardId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestReward"
    ADD CONSTRAINT "FK_QuestReward_AttributeDefinition_AttributeRewardId" FOREIGN KEY ("AttributeRewardId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: QuestReward FK_QuestReward_Item_ItemRewardId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestReward"
    ADD CONSTRAINT "FK_QuestReward_Item_ItemRewardId" FOREIGN KEY ("ItemRewardId") REFERENCES data."Item"("Id") ON DELETE CASCADE;


--
-- Name: QuestReward FK_QuestReward_QuestDefinition_QuestDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestReward"
    ADD CONSTRAINT "FK_QuestReward_QuestDefinition_QuestDefinitionId" FOREIGN KEY ("QuestDefinitionId") REFERENCES config."QuestDefinition"("Id") ON DELETE CASCADE;


--
-- Name: QuestReward FK_QuestReward_Skill_SkillRewardId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."QuestReward"
    ADD CONSTRAINT "FK_QuestReward_Skill_SkillRewardId" FOREIGN KEY ("SkillRewardId") REFERENCES config."Skill"("Id");


--
-- Name: SkillCharacterClass FK_SkillCharacterClass_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillCharacterClass"
    ADD CONSTRAINT "FK_SkillCharacterClass_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: SkillCharacterClass FK_SkillCharacterClass_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillCharacterClass"
    ADD CONSTRAINT "FK_SkillCharacterClass_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id") ON DELETE CASCADE;


--
-- Name: SkillComboStep FK_SkillComboStep_SkillComboDefinition_SkillComboDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillComboStep"
    ADD CONSTRAINT "FK_SkillComboStep_SkillComboDefinition_SkillComboDefinitionId" FOREIGN KEY ("SkillComboDefinitionId") REFERENCES config."SkillComboDefinition"("Id") ON DELETE CASCADE;


--
-- Name: SkillComboStep FK_SkillComboStep_Skill_SkillId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."SkillComboStep"
    ADD CONSTRAINT "FK_SkillComboStep_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id");


--
-- Name: Skill FK_Skill_AreaSkillSettings_AreaSkillSettingsId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "FK_Skill_AreaSkillSettings_AreaSkillSettingsId" FOREIGN KEY ("AreaSkillSettingsId") REFERENCES config."AreaSkillSettings"("Id") ON DELETE CASCADE;


--
-- Name: Skill FK_Skill_AttributeDefinition_ElementalModifierTargetId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "FK_Skill_AttributeDefinition_ElementalModifierTargetId" FOREIGN KEY ("ElementalModifierTargetId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: Skill FK_Skill_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "FK_Skill_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: Skill FK_Skill_MagicEffectDefinition_MagicEffectDefId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "FK_Skill_MagicEffectDefinition_MagicEffectDefId" FOREIGN KEY ("MagicEffectDefId") REFERENCES config."MagicEffectDefinition"("Id");


--
-- Name: Skill FK_Skill_MasterSkillDefinition_MasterDefinitionId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."Skill"
    ADD CONSTRAINT "FK_Skill_MasterSkillDefinition_MasterDefinitionId" FOREIGN KEY ("MasterDefinitionId") REFERENCES config."MasterSkillDefinition"("Id") ON DELETE CASCADE;


--
-- Name: StatAttributeDefinition FK_StatAttributeDefinition_AttributeDefinition_AttributeId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."StatAttributeDefinition"
    ADD CONSTRAINT "FK_StatAttributeDefinition_AttributeDefinition_AttributeId" FOREIGN KEY ("AttributeId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: StatAttributeDefinition FK_StatAttributeDefinition_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."StatAttributeDefinition"
    ADD CONSTRAINT "FK_StatAttributeDefinition_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: WarpInfo FK_WarpInfo_ExitGate_GateId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."WarpInfo"
    ADD CONSTRAINT "FK_WarpInfo_ExitGate_GateId" FOREIGN KEY ("GateId") REFERENCES config."ExitGate"("Id");


--
-- Name: WarpInfo FK_WarpInfo_GameConfiguration_GameConfigurationId; Type: FK CONSTRAINT; Schema: config; Owner: -
--

ALTER TABLE ONLY config."WarpInfo"
    ADD CONSTRAINT "FK_WarpInfo_GameConfiguration_GameConfigurationId" FOREIGN KEY ("GameConfigurationId") REFERENCES config."GameConfiguration"("Id") ON DELETE CASCADE;


--
-- Name: AccountCharacterClass FK_AccountCharacterClass_Account_AccountId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."AccountCharacterClass"
    ADD CONSTRAINT "FK_AccountCharacterClass_Account_AccountId" FOREIGN KEY ("AccountId") REFERENCES data."Account"("Id") ON DELETE CASCADE;


--
-- Name: AccountCharacterClass FK_AccountCharacterClass_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."AccountCharacterClass"
    ADD CONSTRAINT "FK_AccountCharacterClass_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: Account FK_Account_ItemStorage_VaultId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Account"
    ADD CONSTRAINT "FK_Account_ItemStorage_VaultId" FOREIGN KEY ("VaultId") REFERENCES data."ItemStorage"("Id") ON DELETE CASCADE;


--
-- Name: AppearanceData FK_AppearanceData_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."AppearanceData"
    ADD CONSTRAINT "FK_AppearanceData_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id");


--
-- Name: CharacterDropItemGroup FK_CharacterDropItemGroup_Character_CharacterId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterDropItemGroup"
    ADD CONSTRAINT "FK_CharacterDropItemGroup_Character_CharacterId" FOREIGN KEY ("CharacterId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: CharacterDropItemGroup FK_CharacterDropItemGroup_DropItemGroup_DropItemGroupId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterDropItemGroup"
    ADD CONSTRAINT "FK_CharacterDropItemGroup_DropItemGroup_DropItemGroupId" FOREIGN KEY ("DropItemGroupId") REFERENCES config."DropItemGroup"("Id") ON DELETE CASCADE;


--
-- Name: CharacterQuestState FK_CharacterQuestState_Character_CharacterId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterQuestState"
    ADD CONSTRAINT "FK_CharacterQuestState_Character_CharacterId" FOREIGN KEY ("CharacterId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: CharacterQuestState FK_CharacterQuestState_QuestDefinition_ActiveQuestId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterQuestState"
    ADD CONSTRAINT "FK_CharacterQuestState_QuestDefinition_ActiveQuestId" FOREIGN KEY ("ActiveQuestId") REFERENCES config."QuestDefinition"("Id");


--
-- Name: CharacterQuestState FK_CharacterQuestState_QuestDefinition_LastFinishedQuestId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."CharacterQuestState"
    ADD CONSTRAINT "FK_CharacterQuestState_QuestDefinition_LastFinishedQuestId" FOREIGN KEY ("LastFinishedQuestId") REFERENCES config."QuestDefinition"("Id");


--
-- Name: Character FK_Character_Account_AccountId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Character"
    ADD CONSTRAINT "FK_Character_Account_AccountId" FOREIGN KEY ("AccountId") REFERENCES data."Account"("Id") ON DELETE CASCADE;


--
-- Name: Character FK_Character_CharacterClass_CharacterClassId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Character"
    ADD CONSTRAINT "FK_Character_CharacterClass_CharacterClassId" FOREIGN KEY ("CharacterClassId") REFERENCES config."CharacterClass"("Id") ON DELETE CASCADE;


--
-- Name: Character FK_Character_GameMapDefinition_CurrentMapId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Character"
    ADD CONSTRAINT "FK_Character_GameMapDefinition_CurrentMapId" FOREIGN KEY ("CurrentMapId") REFERENCES config."GameMapDefinition"("Id");


--
-- Name: Character FK_Character_ItemStorage_InventoryId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Character"
    ADD CONSTRAINT "FK_Character_ItemStorage_InventoryId" FOREIGN KEY ("InventoryId") REFERENCES data."ItemStorage"("Id") ON DELETE CASCADE;


--
-- Name: ItemAppearanceItemOptionType FK_ItemAppearanceItemOptionType_ItemAppearance_ItemAppearanceId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearanceItemOptionType"
    ADD CONSTRAINT "FK_ItemAppearanceItemOptionType_ItemAppearance_ItemAppearanceId" FOREIGN KEY ("ItemAppearanceId") REFERENCES data."ItemAppearance"("Id") ON DELETE CASCADE;


--
-- Name: ItemAppearanceItemOptionType FK_ItemAppearanceItemOptionType_ItemOptionType_ItemOptionTypeId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearanceItemOptionType"
    ADD CONSTRAINT "FK_ItemAppearanceItemOptionType_ItemOptionType_ItemOptionTypeId" FOREIGN KEY ("ItemOptionTypeId") REFERENCES config."ItemOptionType"("Id") ON DELETE CASCADE;


--
-- Name: ItemAppearance FK_ItemAppearance_AppearanceData_AppearanceDataId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearance"
    ADD CONSTRAINT "FK_ItemAppearance_AppearanceData_AppearanceDataId" FOREIGN KEY ("AppearanceDataId") REFERENCES data."AppearanceData"("Id") ON DELETE CASCADE;


--
-- Name: ItemAppearance FK_ItemAppearance_ItemDefinition_DefinitionId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemAppearance"
    ADD CONSTRAINT "FK_ItemAppearance_ItemDefinition_DefinitionId" FOREIGN KEY ("DefinitionId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: ItemItemOfItemSet FK_ItemItemOfItemSet_ItemOfItemSet_ItemOfItemSetId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemItemOfItemSet"
    ADD CONSTRAINT "FK_ItemItemOfItemSet_ItemOfItemSet_ItemOfItemSetId" FOREIGN KEY ("ItemOfItemSetId") REFERENCES config."ItemOfItemSet"("Id") ON DELETE CASCADE;


--
-- Name: ItemItemOfItemSet FK_ItemItemOfItemSet_Item_ItemId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemItemOfItemSet"
    ADD CONSTRAINT "FK_ItemItemOfItemSet_Item_ItemId" FOREIGN KEY ("ItemId") REFERENCES data."Item"("Id") ON DELETE CASCADE;


--
-- Name: ItemOptionLink FK_ItemOptionLink_IncreasableItemOption_ItemOptionId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemOptionLink"
    ADD CONSTRAINT "FK_ItemOptionLink_IncreasableItemOption_ItemOptionId" FOREIGN KEY ("ItemOptionId") REFERENCES config."IncreasableItemOption"("Id");


--
-- Name: ItemOptionLink FK_ItemOptionLink_Item_ItemId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."ItemOptionLink"
    ADD CONSTRAINT "FK_ItemOptionLink_Item_ItemId" FOREIGN KEY ("ItemId") REFERENCES data."Item"("Id") ON DELETE CASCADE;


--
-- Name: Item FK_Item_ItemDefinition_DefinitionId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Item"
    ADD CONSTRAINT "FK_Item_ItemDefinition_DefinitionId" FOREIGN KEY ("DefinitionId") REFERENCES config."ItemDefinition"("Id");


--
-- Name: Item FK_Item_ItemStorage_ItemStorageId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."Item"
    ADD CONSTRAINT "FK_Item_ItemStorage_ItemStorageId" FOREIGN KEY ("ItemStorageId") REFERENCES data."ItemStorage"("Id") ON DELETE CASCADE;


--
-- Name: LetterBody FK_LetterBody_AppearanceData_SenderAppearanceId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."LetterBody"
    ADD CONSTRAINT "FK_LetterBody_AppearanceData_SenderAppearanceId" FOREIGN KEY ("SenderAppearanceId") REFERENCES data."AppearanceData"("Id") ON DELETE CASCADE;


--
-- Name: LetterBody FK_LetterBody_LetterHeader_HeaderId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."LetterBody"
    ADD CONSTRAINT "FK_LetterBody_LetterHeader_HeaderId" FOREIGN KEY ("HeaderId") REFERENCES data."LetterHeader"("Id");


--
-- Name: LetterHeader FK_LetterHeader_Character_ReceiverId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."LetterHeader"
    ADD CONSTRAINT "FK_LetterHeader_Character_ReceiverId" FOREIGN KEY ("ReceiverId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameRankingEntry FK_MiniGameRankingEntry_Character_CharacterId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."MiniGameRankingEntry"
    ADD CONSTRAINT "FK_MiniGameRankingEntry_Character_CharacterId" FOREIGN KEY ("CharacterId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: MiniGameRankingEntry FK_MiniGameRankingEntry_MiniGameDefinition_MiniGameId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."MiniGameRankingEntry"
    ADD CONSTRAINT "FK_MiniGameRankingEntry_MiniGameDefinition_MiniGameId" FOREIGN KEY ("MiniGameId") REFERENCES config."MiniGameDefinition"("Id") ON DELETE CASCADE;


--
-- Name: QuestMonsterKillRequirementState FK_QuestMonsterKillRequirementState_CharacterQuestState_Charac~; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."QuestMonsterKillRequirementState"
    ADD CONSTRAINT "FK_QuestMonsterKillRequirementState_CharacterQuestState_Charac~" FOREIGN KEY ("CharacterQuestStateId") REFERENCES data."CharacterQuestState"("Id") ON DELETE CASCADE;


--
-- Name: QuestMonsterKillRequirementState FK_QuestMonsterKillRequirementState_QuestMonsterKillRequiremen~; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."QuestMonsterKillRequirementState"
    ADD CONSTRAINT "FK_QuestMonsterKillRequirementState_QuestMonsterKillRequiremen~" FOREIGN KEY ("RequirementId") REFERENCES config."QuestMonsterKillRequirement"("Id");


--
-- Name: SkillEntry FK_SkillEntry_Character_CharacterId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."SkillEntry"
    ADD CONSTRAINT "FK_SkillEntry_Character_CharacterId" FOREIGN KEY ("CharacterId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: SkillEntry FK_SkillEntry_Skill_SkillId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."SkillEntry"
    ADD CONSTRAINT "FK_SkillEntry_Skill_SkillId" FOREIGN KEY ("SkillId") REFERENCES config."Skill"("Id");


--
-- Name: StatAttribute FK_StatAttribute_Account_AccountId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."StatAttribute"
    ADD CONSTRAINT "FK_StatAttribute_Account_AccountId" FOREIGN KEY ("AccountId") REFERENCES data."Account"("Id") ON DELETE CASCADE;


--
-- Name: StatAttribute FK_StatAttribute_AttributeDefinition_DefinitionId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."StatAttribute"
    ADD CONSTRAINT "FK_StatAttribute_AttributeDefinition_DefinitionId" FOREIGN KEY ("DefinitionId") REFERENCES config."AttributeDefinition"("Id");


--
-- Name: StatAttribute FK_StatAttribute_Character_CharacterId; Type: FK CONSTRAINT; Schema: data; Owner: -
--

ALTER TABLE ONLY data."StatAttribute"
    ADD CONSTRAINT "FK_StatAttribute_Character_CharacterId" FOREIGN KEY ("CharacterId") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: GuildMember FK_GuildMember_Character_Id; Type: FK CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."GuildMember"
    ADD CONSTRAINT "FK_GuildMember_Character_Id" FOREIGN KEY ("Id") REFERENCES data."Character"("Id") ON DELETE CASCADE;


--
-- Name: GuildMember FK_GuildMember_Guild_GuildId; Type: FK CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."GuildMember"
    ADD CONSTRAINT "FK_GuildMember_Guild_GuildId" FOREIGN KEY ("GuildId") REFERENCES guild."Guild"("Id") ON DELETE CASCADE;


--
-- Name: Guild FK_Guild_Guild_AllianceGuildId; Type: FK CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."Guild"
    ADD CONSTRAINT "FK_Guild_Guild_AllianceGuildId" FOREIGN KEY ("AllianceGuildId") REFERENCES guild."Guild"("Id");


--
-- Name: Guild FK_Guild_Guild_HostilityId; Type: FK CONSTRAINT; Schema: guild; Owner: -
--

ALTER TABLE ONLY guild."Guild"
    ADD CONSTRAINT "FK_Guild_Guild_HostilityId" FOREIGN KEY ("HostilityId") REFERENCES guild."Guild"("Id");


--
-- PostgreSQL database dump complete
--

\unrestrict MTy73cPha2c8Hec9OELVAOzRBvfD0a0NEwPzcIV2x5TdjQfa2IoEsImxy8A7zO7

