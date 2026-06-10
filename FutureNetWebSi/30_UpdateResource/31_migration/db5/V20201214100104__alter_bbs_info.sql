--「notice_start_date」「notice_end_date」の属性を「timestamp」から「8桁文字列」とする
ALTER TABLE ntss.bbs_info ALTER COLUMN notice_start_date TYPE character varying(8) USING (notice_start_date::character varying(8));
ALTER TABLE ntss.bbs_info ALTER COLUMN notice_end_date TYPE character varying(8) USING (notice_end_date::character varying(8));
--「notice_fac_cal_start_date」「notice_fac_cal_end_date」の属性を「timestamp」から「8桁文字列」とする
ALTER TABLE ntss.bbs_info ALTER COLUMN notice_fac_cal_start_date TYPE character varying(8) USING (notice_fac_cal_start_date::character varying(8));
ALTER TABLE ntss.bbs_info ALTER COLUMN notice_fac_cal_end_date TYPE character varying(8) USING (notice_fac_cal_end_date::character varying(8));
--新たに「notice_fac_cal_start_time」「notice_fac_cal_end_time」を追加し、4桁文字列とします
ALTER TABLE ntss.bbs_info ADD COLUMN notice_fac_cal_start_time character varying(4) DEFAULT NULL;
COMMENT ON COLUMN "ntss"."bbs_info"."notice_fac_cal_start_time" IS '施設カレンダーイベント開始時刻';
ALTER TABLE ntss.bbs_info ADD COLUMN notice_fac_cal_end_time character varying(4) DEFAULT NULL;
COMMENT ON COLUMN "ntss"."bbs_info"."notice_fac_cal_end_time" IS '施設カレンダーイベント終了時刻';
--新たに「is_time_start_flg」「is_time_end_flg」を追加し
ALTER TABLE ntss.bbs_info ADD COLUMN is_time_start_flg character varying(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying;
COMMENT ON COLUMN "ntss"."bbs_info"."is_time_start_flg" IS '施設カレンダーイベント開始時刻入力フラグ';
ALTER TABLE ntss.bbs_info ADD COLUMN is_time_end_flg character varying(1) COLLATE "pg_catalog"."default" DEFAULT '0'::character varying;
COMMENT ON COLUMN "ntss"."bbs_info"."is_time_end_flg" IS '施設カレンダーイベント終了時刻入力フラグ';
COMMENT ON COLUMN "ntss"."bbs_info"."notice_fac_cal_start_date" IS '施設カレンダーイベント開始日付';
COMMENT ON COLUMN "ntss"."bbs_info"."notice_fac_cal_end_date" IS '施設カレンダーイベント終了日付';
