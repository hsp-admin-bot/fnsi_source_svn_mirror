--mst_facilityに列を追加
ALTER TABLE mst_facility 
  ADD COLUMN "vpn_set" varchar(1) --VPNセット
;

COMMENT ON COLUMN "mst_facility"."vpn_set" IS 'VPNセット';
