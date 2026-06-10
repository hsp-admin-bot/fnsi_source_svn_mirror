--sys_function_advancedに列を追加する
ALTER TABLE
  sys_function_advanced
ADD COLUMN IF NOT EXISTS is_nkk character varying(1), --日機装フラグ
ADD COLUMN IF NOT EXISTS system_use_disp character varying(1) --システム利用設定区分
;

COMMENT ON COLUMN "sys_function_advanced"."is_nkk" IS E'日機装フラグ';
COMMENT ON COLUMN "sys_function_advanced"."system_use_disp" IS E'システム利用設定区分';
