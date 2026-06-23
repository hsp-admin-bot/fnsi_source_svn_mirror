-- テーブル削除
DROP TABLE IF EXISTS mst_complaint;
-- テーブル作成
CREATE TABLE mst_complaint
(
    complaint_cd serial NOT NULL,  --愁訴コード
    facility_cd character varying(6) REFERENCES mst_facility(facility_cd),  --施設コード
    complaint_name character varying(256),  --愁訴名
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_complaint_01 PRIMARY KEY (complaint_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_complaint" IS E'愁訴マスタ';
COMMENT ON COLUMN "mst_complaint"."complaint_cd" IS E'愁訴コード';
COMMENT ON COLUMN "mst_complaint"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_complaint"."complaint_name" IS E'愁訴名';
COMMENT ON COLUMN "mst_complaint"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_complaint"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_complaint"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_complaint"."up_date" IS E'更新日時';
