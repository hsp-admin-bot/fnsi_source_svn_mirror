-- テーブル削除
DROP TABLE IF EXISTS mst_exam_item;
-- テーブル作成
CREATE TABLE mst_exam_item
(
    exam_item_cd bigserial NOT NULL,  --システムで管理する一意な検査項目コード
    facility_cd character varying(6) NOT NULL,  --施設コード
    fn_exam_item_cd character varying(10),  --FNW+で管理する施設内の一意な検査項目コード
    exam_item_name character varying(40),  --検査項目名
    data_type character varying(1),  --データ形式
    unit character varying(20),  --単位
    normal_value_class character varying(1) DEFAULT '0',  --正常値区分
    normal_value_upper numeric(8,2),  --正常値(上限)
    normal_value_lower numeric(8,2),  --正常値(下限)
    normal_value_upper_m numeric(8,2),  --正常値(男性上限)
    normal_value_lower_m numeric(8,2),  --正常値(男性下限)
    normal_value_upper_w numeric(8,2),  --正常値(女性上限)
    normal_value_lower_w numeric(8,2),  --正常値(女性下限)
    input_integer_figure numeric(2),  --入力整数部桁数
    input_decimal_figure numeric(2),  --入力小数部桁数
    input_upper numeric(8,2),  --入力上限値
    input_lower numeric(8,2),  --入力下限値
    graph_upper numeric(8,2),  --グラフ上限値
    graph_lower numeric(8,2),  --グラフ下限値
    console_class character varying(1) DEFAULT '1',  --仮想端末表示対象区分
    exam_class character varying(1) DEFAULT '0',  --検査使用区分
    in_hospital_cd1 character varying(20),  --院内コード1
    sbt_cd1 character varying(20),  --属性コード1
    in_hospital_cd2 character varying(20),  --院内コード2
    sbt_cd2 character varying(20),  --属性コード2
    in_hospital_cd3 character varying(20),  --院内コード3
    sbt_cd3 character varying(20),  --属性コード3
    spitz_cd bigint,  --採血管コード
    jlac10_cd character varying(17),  --JLAC10コード
    infection_cd integer,  --感染症コード
    default_calc_exam_item_cd character varying(2),  --システム標準計算検査項目
    free_calc character varying(1000),  --計算式領域
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_mst_exam_item_01 PRIMARY KEY (exam_item_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_exam_item" IS E'検査項目マスタ';
COMMENT ON COLUMN "mst_exam_item"."exam_item_cd" IS E'システムで管理する一意な検査項目コード';
COMMENT ON COLUMN "mst_exam_item"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_exam_item"."fn_exam_item_cd" IS E'FNW+で管理する施設内の一意な検査項目コード';
COMMENT ON COLUMN "mst_exam_item"."exam_item_name" IS E'検査項目名';
COMMENT ON COLUMN "mst_exam_item"."data_type" IS E'データ形式';
COMMENT ON COLUMN "mst_exam_item"."unit" IS E'単位';
COMMENT ON COLUMN "mst_exam_item"."normal_value_class" IS E'正常値区分';
COMMENT ON COLUMN "mst_exam_item"."normal_value_upper" IS E'正常値(上限)';
COMMENT ON COLUMN "mst_exam_item"."normal_value_lower" IS E'正常値(下限)';
COMMENT ON COLUMN "mst_exam_item"."normal_value_upper_m" IS E'正常値(男性上限)';
COMMENT ON COLUMN "mst_exam_item"."normal_value_lower_m" IS E'正常値(男性下限)';
COMMENT ON COLUMN "mst_exam_item"."normal_value_upper_w" IS E'正常値(女性上限)';
COMMENT ON COLUMN "mst_exam_item"."normal_value_lower_w" IS E'正常値(女性下限)';
COMMENT ON COLUMN "mst_exam_item"."input_integer_figure" IS E'入力整数部桁数';
COMMENT ON COLUMN "mst_exam_item"."input_decimal_figure" IS E'入力小数部桁数';
COMMENT ON COLUMN "mst_exam_item"."input_upper" IS E'入力上限値';
COMMENT ON COLUMN "mst_exam_item"."input_lower" IS E'入力下限値';
COMMENT ON COLUMN "mst_exam_item"."graph_upper" IS E'グラフ上限値';
COMMENT ON COLUMN "mst_exam_item"."graph_lower" IS E'グラフ下限値';
COMMENT ON COLUMN "mst_exam_item"."console_class" IS E'仮想端末表示対象区分';
COMMENT ON COLUMN "mst_exam_item"."exam_class" IS E'検査使用区分';
COMMENT ON COLUMN "mst_exam_item"."in_hospital_cd1" IS E'院内コード1';
COMMENT ON COLUMN "mst_exam_item"."sbt_cd1" IS E'属性コード1';
COMMENT ON COLUMN "mst_exam_item"."in_hospital_cd2" IS E'院内コード2';
COMMENT ON COLUMN "mst_exam_item"."sbt_cd2" IS E'属性コード2';
COMMENT ON COLUMN "mst_exam_item"."in_hospital_cd3" IS E'院内コード3';
COMMENT ON COLUMN "mst_exam_item"."sbt_cd3" IS E'属性コード3';
COMMENT ON COLUMN "mst_exam_item"."spitz_cd" IS E'採血管コード';
COMMENT ON COLUMN "mst_exam_item"."jlac10_cd" IS E'JLAC10コード';
COMMENT ON COLUMN "mst_exam_item"."infection_cd" IS E'感染症コード';
COMMENT ON COLUMN "mst_exam_item"."default_calc_exam_item_cd" IS E'システム標準計算検査項目';
COMMENT ON COLUMN "mst_exam_item"."free_calc" IS E'計算式領域';
COMMENT ON COLUMN "mst_exam_item"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_exam_item"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_exam_item"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_exam_item"."up_date" IS E'更新日時';
