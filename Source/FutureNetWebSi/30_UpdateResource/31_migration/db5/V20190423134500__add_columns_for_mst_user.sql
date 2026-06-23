--mst_userに列を追加
ALTER TABLE
  mst_user
ADD COLUMN is_disp character varying(1) DEFAULT '1',  --表示フラグ
ADD COLUMN is_del character varying(1) DEFAULT '0'  --削除フラグ
;

COMMENT ON COLUMN "mst_user"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_user"."is_del" IS E'削除フラグ';
