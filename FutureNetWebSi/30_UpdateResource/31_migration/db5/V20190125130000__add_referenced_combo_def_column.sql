ALTER TABLE
  sys_master_define
ADD COLUMN
  reference_combo_def jsonb
;
COMMENT ON COLUMN "sys_master_define"."reference_combo_def" IS '参照型コンボの構造データ';
