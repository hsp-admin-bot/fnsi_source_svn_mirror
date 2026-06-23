-- 全施設マスタで施設コードの「not null」をキャンセルする。
ALTER TABLE ntss.sys_facility ALTER COLUMN facility_cd DROP NOT NULL;