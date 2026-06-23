ALTER TABLE sys_daily_no DROP COLUMN IF EXISTS coop_version;
ALTER TABLE sys_daily_no ADD COLUMN coop_version varchar(10) COLLATE "pg_catalog"."default" NOT NULL DEFAULT ''::character varying;

ALTER TABLE sys_daily_no DROP CONSTRAINT IF EXISTS unq_sys_daily_no_02;
ALTER TABLE sys_daily_no ADD CONSTRAINT "unq_sys_daily_no_02" UNIQUE ("facility_cd", "numbering_cd", "base_date", "is_del", "coop_version");

COMMENT ON COLUMN "ntss"."sys_daily_no"."coop_version" IS '連携版番号';