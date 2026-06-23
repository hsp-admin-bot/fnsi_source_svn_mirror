ALTER TABLE bbs_info 
ADD COLUMN title character varying,
ADD COLUMN notice_fac_cal_start_date timestamp(3),
ADD COLUMN notice_fac_cal_end_date timestamp(3),
ADD COLUMN is_disp_bbs character varying(1) default '0',
ADD COLUMN color character varying;



COMMENT ON COLUMN "bbs_info"."notice_fac_cal_start_date" IS E'施設カレンダーイベント開始日時';
COMMENT ON COLUMN "bbs_info"."notice_fac_cal_end_date" IS E'施設カレンダーイベント終了日時';
COMMENT ON COLUMN "bbs_info"."color" IS E'施設カレンダーイベント背景色';
COMMENT ON COLUMN "bbs_info"."is_disp_bbs" IS E'掲示板表示フラグ';
COMMENT ON COLUMN "bbs_info"."title" IS E'タイトル';