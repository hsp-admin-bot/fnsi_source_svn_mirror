--ord_mainにインデックスを追加(施設コード,患者ID)
CREATE INDEX idx_ord_main_01
ON ord_main (facility_cd, pat_id);
