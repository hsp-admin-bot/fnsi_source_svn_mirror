--sys_functionに列を追加
ALTER TABLE
  sys_function
  ADD COLUMN disp_order integer,  --表示順
  ADD COLUMN target_facility jsonb --対象施設
;

COMMENT ON COLUMN "sys_function"."disp_order" IS E'表示順';
COMMENT ON COLUMN "sys_function"."target_facility" IS E'対象施設';
