-- #9147 2023.10.30 add 次患者情報2段組表示 TDC片口
ALTER TABLE mst_comsv_setting ADD COLUMN IF NOT EXISTS next_pat_splitarea character varying(1) DEFAULT '0';
comment on column mst_comsv_setting.next_pat_splitarea is '次患者情報2段組表示';
