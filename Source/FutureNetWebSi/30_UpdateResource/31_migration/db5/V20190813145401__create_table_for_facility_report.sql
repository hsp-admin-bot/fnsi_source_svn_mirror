-- 機能帳票マスタ
-- テーブル削除
DROP TABLE IF EXISTS mst_function_report;
-- テーブル作成
CREATE TABLE mst_function_report
(
    function_report_cd serial NOT NULL,  --機能帳票コード
    function_cd character varying(8) NOT NULL,  --機能コード
    facility_cd character varying(6) NOT NULL REFERENCES mst_facility(facility_cd) ,  --施設コード
    report_cd bigint NOT NULL REFERENCES mst_report(report_cd) ,  --レポートCD
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_function_report_01 PRIMARY KEY (function_report_cd)
)
WITH (
    OIDS=FALSE
)
;
-- コメント追加
COMMENT ON TABLE "mst_function_report" IS E'機能帳票マスタ';
COMMENT ON COLUMN "mst_function_report"."function_report_cd" IS E'機能帳票コード';
COMMENT ON COLUMN "mst_function_report"."function_cd" IS E'機能コード';
COMMENT ON COLUMN "mst_function_report"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_function_report"."report_cd" IS E'レポートCD';
COMMENT ON COLUMN "mst_function_report"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_function_report"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_function_report"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_function_report"."up_date" IS E'更新日時';
