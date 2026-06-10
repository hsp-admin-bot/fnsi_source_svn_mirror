-- テーブル削除
DROP TABLE IF EXISTS mst_self_measure_result;
-- テーブル作成
CREATE TABLE mst_self_measure_result
(
    self_measure_result_cd bigserial,  --自己診断判定コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    disp_machine_name character varying,  --対象機種
    machine_info jsonb,  --対象機種情報
    self_measure_result jsonb,  --自己診断情報
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_self_measure_result_01 PRIMARY KEY (self_measure_result_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_self_measure_result" IS E'自己診断判定マスタ';
COMMENT ON COLUMN "mst_self_measure_result"."self_measure_result_cd" IS E'自己診断判定コード';
COMMENT ON COLUMN "mst_self_measure_result"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_self_measure_result"."disp_machine_name" IS E'対象機種';
COMMENT ON COLUMN "mst_self_measure_result"."machine_info" IS E'対象機種情報';
COMMENT ON COLUMN "mst_self_measure_result"."self_measure_result" IS E'自己診断情報';
COMMENT ON COLUMN "mst_self_measure_result"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_self_measure_result"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_self_measure_result"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_self_measure_result"."up_date" IS E'更新日時';
