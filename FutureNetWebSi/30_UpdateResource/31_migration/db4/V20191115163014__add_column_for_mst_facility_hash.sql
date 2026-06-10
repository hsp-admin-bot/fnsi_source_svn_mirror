--mst_facility_hashに列を追加
ALTER TABLE
  mst_facility_hash
ADD COLUMN system_use_setting character varying(1) default '1'  --システム利用設定
;

COMMENT ON COLUMN "mst_facility_hash"."system_use_setting" IS E'システム利用設定';
