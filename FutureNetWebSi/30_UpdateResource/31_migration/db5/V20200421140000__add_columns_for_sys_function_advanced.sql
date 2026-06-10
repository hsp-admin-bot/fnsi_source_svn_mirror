--sys_function_advancedに列を追加
ALTER TABLE
  sys_function_advanced
  ADD COLUMN target_facility jsonb --対象施設
;
COMMENT ON COLUMN "sys_function_advanced"."target_facility" IS E'対象施設';
