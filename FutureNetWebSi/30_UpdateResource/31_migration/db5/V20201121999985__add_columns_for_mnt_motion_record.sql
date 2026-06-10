--装置記録マスタ 表示フラグを追加
ALTER TABLE ntss.mnt_motion_record ADD report_disp_flg character varying(1) default '0';

COMMENT ON COLUMN ntss.mnt_motion_record.report_disp_flg IS '表示フラグ';