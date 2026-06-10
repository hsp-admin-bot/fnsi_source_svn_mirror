--sys_facility_settingに列を追加(一旦defaultに'2':FNSiをセット)
ALTER TABLE
  sys_facility_setting
  ADD COLUMN IF NOT EXISTS system_use_disp character varying(1) DEFAULT '2' NOT NULL;
;

--共通項目をUPDATE
UPDATE sys_facility_setting
SET system_use_disp = '3'
WHERE facility_setting_no IN ('1003','1036','1037','1038','1048');

--defaultを削除
ALTER TABLE sys_facility_setting ALTER COLUMN system_use_disp DROP DEFAULT;
COMMENT ON COLUMN "sys_facility_setting"."system_use_disp" IS E'システム利用表示区分';