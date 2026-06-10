-- 型式マスタにover_nxseries追加
ALTER TABLE
  mst_machine_type
ADD COLUMN over_nxseries character varying(1);