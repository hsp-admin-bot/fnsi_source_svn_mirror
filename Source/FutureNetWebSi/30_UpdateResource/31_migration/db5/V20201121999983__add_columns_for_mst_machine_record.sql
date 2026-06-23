--装置記録マスタ 表示フラグを追加
ALTER TABLE ntss.mst_machine_record ADD disp_flg character varying(1) default '0';

COMMENT ON COLUMN ntss.mst_machine_record.disp_flg IS '表示フラグ';