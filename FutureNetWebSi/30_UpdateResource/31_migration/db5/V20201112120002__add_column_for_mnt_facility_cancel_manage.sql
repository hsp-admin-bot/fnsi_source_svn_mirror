-- mnt_facility_cancel_manage に列を追加する
ALTER TABLE
  mnt_facility_cancel_manage
ADD COLUMN IF NOT EXISTS stats_nosql jsonb --統計情報(NoSQLDB)
;

COMMENT ON COLUMN "mnt_facility_cancel_manage"."stats_nosql" IS E'統計情報(NoSQLDB)';
