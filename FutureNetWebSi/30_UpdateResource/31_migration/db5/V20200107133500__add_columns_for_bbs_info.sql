ALTER TABLE bbs_info 
ADD COLUMN is_disp character varying(1) DEFAULT '1',
ADD COLUMN is_del character varying(1) DEFAULT '0';

COMMENT ON COLUMN "bbs_info"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "bbs_info"."is_del" IS E'削除フラグ';