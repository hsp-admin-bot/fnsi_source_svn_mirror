ALTER TABLE mnt_mainte_main
ADD COLUMN IF NOT EXISTS fn_checkplan_no character varying(32);
COMMENT ON COLUMN "ntss"."mnt_mainte_main"."fn_checkplan_no" IS 'FNW+点検予定番号';